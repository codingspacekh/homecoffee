<?php

namespace App\Actions;

use App\Enums\OrderStatus;
use App\Enums\PointReason;
use App\Events\OrderStatusChanged;
use App\Exceptions\ApiProblem;
use App\Models\Order;
use App\Models\User;
use Illuminate\Support\Facades\DB;

/**
 * Cancels an order and gives back a free drink's points. Customers can
 * cancel until the barista starts; staff can cancel any open order.
 */
class CancelOrder
{
    public function handle(Order $order, bool $byCustomer, ?string $reason = null): Order
    {
        $order = DB::transaction(function () use ($order, $byCustomer, $reason) {
            $order = Order::whereKey($order->id)->lockForUpdate()->firstOrFail();
            $allowed = $byCustomer ? $order->status === OrderStatus::Received : $order->status->isOpen();
            if (! $allowed) {
                throw new ApiProblem('order_not_cancellable', 'This order is already being made, so it can no longer be cancelled.', [
                    'status' => $order->status->value,
                ]);
            }

            $order->forceFill([
                'status' => OrderStatus::Cancelled,
                'cancelled_at' => now(),
                'cancel_reason' => $reason ?? ($byCustomer ? 'Cancelled by the customer' : null),
            ])->save();

            if ($order->points_spent > 0 && $order->user_id !== null) {
                $customer = User::whereKey($order->user_id)->lockForUpdate()->firstOrFail();
                $customer->increment('points', $order->points_spent);
                $customer->pointEntries()->create([
                    'order_id' => $order->id,
                    'change' => $order->points_spent,
                    'reason' => PointReason::Refund,
                ]);
            }

            return $order;
        });

        OrderStatusChanged::dispatch($order);

        return $order;
    }
}
