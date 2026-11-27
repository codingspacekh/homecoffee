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

    /** Changed by a manager in the admin panel. */
    case Adjustment = 'adjustment';
}
