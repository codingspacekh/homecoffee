<?php

namespace App\Domain;

/**
 * The website's services/Promo.js. Codes are hard-coded for now, as on the website.
 * They move to the promo_codes table in Phase 4.
 */
final class Promo
{
    /** @var array<string, array{percent?: int, amount?: int, minimum?: int}> */
    private const CODES = [
        'WELCOME10' => ['percent' => 10],
        'SAVE2' => ['amount' => 200, 'minimum' => 1000],
    ];

    public static function normalize(string $code): string
    {
        return strtoupper(trim($code));
    }

    public static function problem(string $code, int $amountCents): PromoProblem
    {
        $promo = self::CODES[self::normalize($code)] ?? null;
        if ($promo === null) {
            return PromoProblem::Unknown;
        }

        return $amountCents < ($promo['minimum'] ?? 0) ? PromoProblem::Minimum : PromoProblem::None;
    }

    /** Never more than the amount, so a total can't go below zero. */
    public static function discount(string $code, int $amountCents): int
    {
        if (trim($code) === '' || self::problem($code, $amountCents) !== PromoProblem::None) {
            return 0;
        }
        $promo = self::CODES[self::normalize($code)];
        // Half a cent rounds up: 10% of $10.05 is $1.01.
        $discount = isset($promo['percent'])
            ? intdiv($amountCents * $promo['percent'] + 50, 100)
            : $promo['amount'];

        return min($discount, $amountCents);
    }
}
