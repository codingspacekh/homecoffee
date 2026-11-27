<?php

namespace App\Domain;

/**
 * The website's services/Promo.js: a percentage or an amount off, with an
 * optional smallest order. Which codes exist, and whether one can still be
 * used, comes from the promo_codes table (App\Models\PromoCode).
 */
final readonly class Promo
{
    /**
     * The website's two codes. The shared price cases use them, and the
     * database seeder adds them to promo_codes.
     *
     * @var array<string, array{percent?: int, amount?: int, minimum?: int}>
     */
    public const WEBSITE = [
        'WELCOME10' => ['percent' => 10],
        'SAVE2' => ['amount' => 200, 'minimum' => 1000],
    ];

    public function __construct(
        public string $code,
        public ?int $percent = null,
        public ?int $amount = null,
        public int $minimum = 0,
    ) {}

    public static function normalize(string $code): string
    {
        return strtoupper(trim($code));
    }

    /** One of the website's codes, or null. */
    public static function website(string $code): ?self
    {
        $code = self::normalize($code);
        $rule = self::WEBSITE[$code] ?? null;

        return $rule === null ? null : new self($code, $rule['percent'] ?? null, $rule['amount'] ?? null, $rule['minimum'] ?? 0);
    }

    public function problem(int $amountCents): PromoProblem
    {
        return $amountCents < $this->minimum ? PromoProblem::Minimum : PromoProblem::None;
    }

    /** Never more than the amount, so a total can't go below zero. */
    public function discount(int $amountCents): int
    {
        if ($this->problem($amountCents) !== PromoProblem::None) {
            return 0;
        }
        // Half a cent rounds up: 10% of $10.05 is $1.01.
        $discount = $this->percent !== null
            ? intdiv($amountCents * $this->percent + 50, 100)
            : (int) $this->amount;

        return min($discount, $amountCents);
    }

    /** "10% off" or "$2.00 off". */
    public function label(): string
    {
        return $this->percent !== null ? "{$this->percent}% off" : Money::format((int) $this->amount).' off';
    }
}
