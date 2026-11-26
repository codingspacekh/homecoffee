<?php

namespace App\Domain;

/** The website's services/Loyalty.js. */
final class Loyalty
{
    public const REWARD_POINTS = 50;

    /** One point per whole dollar paid. */
    public static function pointsFor(int $totalCents): int
    {
        return intdiv(max($totalCents, 0), 100);
    }

    public static function hasReward(int $points): bool
    {
        return $points >= self::REWARD_POINTS;
    }

    /**
     * The most expensive drink in the cart, or null when there is no drink.
     *
     * @param  list<CartLine>  $cart
     */
    public static function rewardLine(array $cart): ?CartLine
    {
        $best = null;
        foreach ($cart as $line) {
            if ($line->product->drink && ($best === null || $line->unitCents > $best->unitCents)) {
                $best = $line;
            }
        }

        return $best;
    }

    /** @param  list<CartLine>  $cart */
    public static function rewardDiscount(array $cart, int $points): int
    {
        return self::hasReward($points) ? (self::rewardLine($cart)?->unitCents ?? 0) : 0;
    }
}
