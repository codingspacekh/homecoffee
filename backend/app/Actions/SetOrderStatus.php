<?php

namespace App\Actions;

use App\Enums\OrderStatus;
use App\Events\OrderStatusChanged;
use App\Models\Order;
use DomainException;

/**
 * Moves an order one step forward: received, preparing, ready, collected.
 * The orders board in the admin panel calls this (Phase 3).
 */
class SetOrderStatus
{
    public function __construct(private readonly AwardPoints $awardPoints) {}

    public function handle(Order $order, OrderStatus $to): Order
    {
        if ($order->status->next() !== $to) {
            throw new DomainException("Order {$order->number()} can't go from {$order->status->value} to {$to->value}.");
        }

        $order->status = $to;
        $order->{$to->timestampColumn()} = now();
        $order->save();

        if ($to === OrderStatus::Collected) {
            $this->awardPoints->handle($order);
        }
        OrderStatusChanged::dispatch($order);

        return $order;
    }
}
