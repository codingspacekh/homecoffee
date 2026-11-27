<?php

namespace App\Actions;

use App\Enums\PointReason;
use App\Models\Order;
use App\Models\User;
use Illuminate\Support\Facades\DB;

/** Adds an order's points to the customer once it is collected. Safe to run twice. */
class AwardPoints
{
    public function handle(Order $order): void
    {
        if ($order->user_id === null || $order->points_earned <= 0) {
            return;
        }

        DB::transaction(function () use ($order) {
            $customer = User::whereKey($order->user_id)->lockForUpdate()->first();
            $already = $customer?->pointEntries()
                ->where('order_id', $order->id)
                ->where('reason', PointReason::Order)
                ->exists();
            if ($customer === null || $already) {
                return;
            }
            $customer->increment('points', $order->points_earned);
            $customer->pointEntries()->create([
                'order_id' => $order->id,
                'change' => $order->points_earned,
                'reason' => PointReason::Order,
            ]);
        });
    }
}
