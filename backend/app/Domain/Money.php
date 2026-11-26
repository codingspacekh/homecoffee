<?php

namespace App\Domain;

/**
 * Prices are whole cents everywhere: in the database, in the API and in the app.
 * $3.75 is 375. Nothing is ever rounded after a sum.
 */
final class Money
{
    /** menu.json stores dollars (3.75). The app and the database use cents (375). */
    public static function fromDollars(float|int $dollars): int
    {
        return (int) round($dollars * 100);
    }

    public static function format(int $cents): string
    {
        $sign = $cents < 0 ? '−' : '';
        $abs = abs($cents);

        return sprintf('%s$%d.%02d', $sign, intdiv($abs, 100), $abs % 100);
    }
}
