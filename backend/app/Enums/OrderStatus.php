<?php

namespace App\Enums;

/** An order only ever moves forward: received, preparing, ready, collected. */
enum OrderStatus: string
{
    case Received = 'received';
    case Preparing = 'preparing';
    case Ready = 'ready';
    case Collected = 'collected';
    case Cancelled = 'cancelled';

    public function next(): ?self
    {
        return match ($this) {
            self::Received => self::Preparing,
            self::Preparing => self::Ready,
            self::Ready => self::Collected,
            default => null,
        };
    }

    public function isOpen(): bool
    {
        return in_array($this, [self::Received, self::Preparing, self::Ready], true);
    }

    /** The column that records when the order reached this status. */
    public function timestampColumn(): ?string
    {
        return match ($this) {
            self::Preparing => 'preparing_at',
            self::Ready => 'ready_at',
            self::Collected => 'collected_at',
            self::Cancelled => 'cancelled_at',
            default => null,
        };
    }
}
