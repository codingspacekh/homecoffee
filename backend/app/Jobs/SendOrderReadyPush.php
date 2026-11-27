<?php

namespace App\Jobs;

use App\Models\Order;
use App\Push\PushMessage;
use App\Push\PushResult;
use App\Push\PushSender;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use RuntimeException;

/**
 * "Order #1042 is ready" to every phone of the customer that turned on
 * order alerts, in the customer's language.
 */
class SendOrderReadyPush implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    /** @var list<int> */
    public array $backoff = [10, 60];

    public function __construct(public readonly int $orderId) {}

    public function handle(PushSender $sender): void
    {
        $order = Order::with('user.devices')->find($this->orderId);
        $user = $order?->user;
        if ($user === null || $user->devices->isEmpty()) {
            return;
        }

        $number = $order->number();
        [$title, $body] = $user->language === 'km'
            ? ["ការបញ្ជាទិញ #{$number} រួចរាល់ហើយ", 'សូមអញ្ជើញមកយកនៅបញ្ជរ។']
            : ["Order #{$number} is ready", 'Come and pick it up at the counter.'];

        $failed = 0;
        foreach ($user->devices as $device) {
            $result = $sender->send(new PushMessage($device->token, $title, $body, [
                'type' => 'order_ready',
                'order_id' => (string) $order->id,
            ]));
            match ($result) {
                PushResult::InvalidToken => $device->delete(),
                PushResult::Failed => $failed++,
                PushResult::Sent => null,
            };
        }

        if ($failed > 0) {
            throw new RuntimeException("Firebase did not take {$failed} order-ready push(es) for order {$number}.");
        }
    }
}
