<?php

namespace App\Domain;

/** orderTotals() from the website's services/Order.js: free drink first, then the promo on what is left. */
final readonly class OrderTotals
{
    public function __construct(
        public int $subtotal,
        public int $discount,
        public int $promoAmount,
        public int $total,
    ) {}

    /** @param  list<CartLine>  $cart */
    public static function for(array $cart, int $points = 0, bool $useReward = false, ?Promo $promo = null): self
    {
        $subtotal = array_sum(array_map(fn (CartLine $line) => $line->lineCents(), $cart));
        $discount = $useReward ? Loyalty::rewardDiscount($cart, $points) : 0;
        $afterReward = $subtotal - $discount;
        $promoAmount = $promo?->discount($afterReward) ?? 0;

        return new self($subtotal, $discount, $promoAmount, $afterReward - $promoAmount);
    }

    public function pointsEarned(): int
    {
        return Loyalty::pointsFor($this->total);
    }
}
