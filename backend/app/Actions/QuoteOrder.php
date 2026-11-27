<?php

namespace App\Actions;

use App\Domain\Loyalty;
use App\Domain\Options;
use App\Domain\OrderTotals;
use App\Domain\Promo;
use App\Domain\PromoProblem;
use App\Exceptions\ApiProblem;
use App\Models\Product;
use App\Models\User;

/**
 * Prices a cart with the same rules as the app (app/Domain), from the
 * products table, never from prices the app sent.
 */
class QuoteOrder
{
    /**
     * @param  array{lines: list<array{product_id: int, options?: array<string, string>, quantity?: int, note?: ?string}>, promo_code?: ?string, use_free_drink?: bool}  $input
     *
     * @throws ApiProblem item_unavailable, not_enough_points, promo_invalid or promo_minimum
     */
    public function handle(User $user, array $input): Quote
    {
        $products = Product::whereIn('id', array_column($input['lines'], 'product_id'))->get()->keyBy('id')->all();

        $lines = [];
        foreach ($input['lines'] as $line) {
            $product = $products[$line['product_id']] ?? null;
            if ($product === null || ! $product->available) {
                throw new ApiProblem('item_unavailable', 'An item in the cart is sold out or no longer on the menu.', [
                    'product_id' => (int) $line['product_id'],
                ]);
            }
            $lines[] = Options::line(
                $product->toDomain(),
                $line['options'] ?? [],
                (int) ($line['quantity'] ?? 1),
                (string) ($line['note'] ?? ''),
            );
        }

        $useReward = (bool) ($input['use_free_drink'] ?? false);
        if ($useReward && ! Loyalty::hasReward($user->points)) {
            throw new ApiProblem('not_enough_points', 'A free drink needs '.Loyalty::REWARD_POINTS.' points.', [
                'points' => $user->points,
            ]);
        }

        $promoCode = filled($input['promo_code'] ?? null) ? Promo::normalize($input['promo_code']) : null;
        $totals = OrderTotals::for($lines, $user->points, $useReward, $promoCode ?? '');
        if ($promoCode !== null) {
            match (Promo::problem($promoCode, $totals->subtotal - $totals->discount)) {
                PromoProblem::Unknown => throw new ApiProblem('promo_invalid', "{$promoCode} is not a valid code."),
                PromoProblem::Minimum => throw new ApiProblem('promo_minimum', "{$promoCode} needs a bigger order.", [
                    'minimum_cents' => Promo::minimum($promoCode),
                ]),
                PromoProblem::None => null,
            };
        }

        return new Quote($lines, $products, $totals, $promoCode);
    }
}
