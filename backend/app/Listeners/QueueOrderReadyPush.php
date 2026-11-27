<?php

namespace App\Listeners;

use App\Enums\OrderStatus;
use App\Events\OrderStatusChanged;
use App\Jobs\SendOrderReadyPush;

/** When the barista taps Ready, the customer's phone buzzes. */
class QueueOrderReadyPush
{
    public function handle(OrderStatusChanged $event): void
    {
        if ($event->order->status === OrderStatus::Ready) {
            SendOrderReadyPush::dispatch($event->order->id)->afterCommit();
        }
    }
}
