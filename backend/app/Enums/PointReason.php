<?php

namespace App\Enums;

enum PointReason: string
{
    /** Earned when an order is collected. */
    case Order = 'order';

    /** Spent on a free drink. */
    case Reward = 'reward';

    /** A free drink given back because its order was cancelled. */
    case Refund = 'refund';

    /** Earned at the counter, for a purchase not made in the app. */
    case Counter = 'counter';

    /** Changed by a manager in the admin panel. */
    case Adjustment = 'adjustment';

    public function label(): string
    {
        return match ($this) {
            self::Order => 'App order',
            self::Reward => 'Free drink',
            self::Refund => 'Free drink given back',
            self::Counter => 'At the counter',
            self::Adjustment => 'Adjusted',
        };
    }
}
