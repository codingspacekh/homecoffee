<?php

namespace App\Actions;

use App\Domain\CartLine;
use App\Enums\PointReason;
use App\Exceptions\ApiProblem;
use App\Models\Order;
use App\Models\StoreSetting;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\DB;

/**
 * Turns a checkout into an order. The total is worked out again here, and
 * points are spent inside the same transaction with the customer's row
 * locked, so two orders at once can't spend the same points twice.
 */
class PlaceOrder
{
    public function __construct(private readonly QuoteOrder $quoteOrder) {}

    /**
     * @param  array<string, mixed>  $input  validated PlaceOrderRequest data
     * @return array{Order, bool} the order, and false when the key matched an earlier order
     *
     * @throws ApiProblem
     */
    public function handle(User $user, array $input, string $idempotencyKey): array
    {
        if ($existing = $this->earlier($user, $idempotencyKey)) {
            return [$existing, false];
        }

        $store = StoreSetting::current();
        if (! $store->accepting_orders) {
            throw new ApiProblem('orders_paused', 'The shop has paused new orders for a moment.');
        }
        [$pickupAt, $readyAt] = $this->pickupTimes($store, (string) $input['pickup_at']);

        try {
            $order = DB::transaction(function () use ($user, $input, $idempotencyKey, $pickupAt, $readyAt) {
                $customer = User::whereKey($user->id)->lockForUpdate()->firstOrFail();
                $quote = $this->quoteOrder->handle($customer, $input);

                $order = $customer->orders()->create([
                    'customer_name' => trim($input['customer_name']),
                    'customer_phone' => $input['customer_phone'] ?? null,
                    'pickup_at' => $pickupAt,
                    'estimated_ready_at' => $readyAt,
                    'subtotal_cents' => $quote->totals->subtotal,
                    'discount_cents' => $quote->totals->discount,
                    'promo_code' => $quote->totals->promoAmount > 0 ? $quote->promoCode : null,
                    'promo_cents' => $quote->totals->promoAmount,
                    'total_cents' => $quote->totals->total,
                    'points_spent' => $quote->pointsSpent(),
                    'points_earned' => $quote->totals->pointsEarned(),
                    'idempotency_key' => $idempotencyKey,
                ]);

                $order->lines()->createMany(array_map(fn (CartLine $line) => [
                    'product_id' => $line->product->id,
                    'name' => $quote->products[$line->product->id]->name,
                    'options' => $line->options,
                    'choices' => [
                        'en' => $quote->choicesText($line, 'en'),
                        'km' => $quote->choicesText($line, 'km'),
                    ],
                    'note' => $line->note,
                    'unit_cents' => $line->unitCents,
                    'quantity' => $line->quantity,
                    'line_cents' => $line->lineCents(),
                ], $quote->lines));

                if ($quote->pointsSpent() > 0) {
                    $customer->decrement('points', $quote->pointsSpent());
                    $customer->pointEntries()->create([
                        'order_id' => $order->id,
                        'change' => -$quote->pointsSpent(),
                        'reason' => PointReason::Reward,
                    ]);
                }

                // Remember the name and phone for the next checkout
                $customer->update(array_filter([
                    'name' => trim($input['customer_name']),
                    'phone' => $input['customer_phone'] ?? null,
                ]));

                return $order;
            });
        } catch (UniqueConstraintViolationException) {
            // The same request arrived twice at the same moment
            return [$this->earlier($user, $idempotencyKey), false];
        }

        return [$order->load('lines'), true];
    }

    private function earlier(User $user, string $idempotencyKey): ?Order
    {
        return $user->orders()->where('idempotency_key', $idempotencyKey)->with('lines')->first();
    }

    /**
     * "asap" means ready after the prep time, and needs the shop open now.
     * A set time must be later today, inside opening hours, and leave the
     * barista at least the prep time.
     *
     * @return array{?CarbonImmutable, CarbonImmutable} pickup time (null for asap) and ready time
     */
    private function pickupTimes(StoreSetting $store, string $pickup): array
    {
        $now = CarbonImmutable::now();
        $earliest = $now->addMinutes($store->prep_minutes);

        if ($pickup === 'asap') {
            if (! $store->isOpenAt($now)) {
                throw new ApiProblem('store_closed', 'The shop is closed right now.');
            }

            return [null, $earliest];
        }

        $at = CarbonImmutable::parse($pickup)->setTimezone(config('app.timezone'))->startOfMinute();
        $local = fn (CarbonImmutable $moment) => $moment->setTimezone($store->timezone);
        $sameDay = $local($at)->isSameDay($local($now));
        $hours = $store->hoursOn($at);
        $closing = $hours ? $local($at)->setTimeFromTimeString($hours['close']) : null;

        // Ready by closing time at the latest, so the last pickup is closing time
        if (! $sameDay || $at->lt($earliest->startOfMinute()) || $closing === null
            || ! ($store->isOpenAt($at) || $local($at)->eq($closing))) {
            throw new ApiProblem('pickup_outside_hours', 'Pick a time later today, while the shop is open.', [
                'earliest' => $earliest->toIso8601String(),
            ]);
        }

        return [$at, $at];
    }
}
