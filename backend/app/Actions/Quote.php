<?php

namespace App\Actions;

use App\Domain\CartLine;
use App\Domain\Loyalty;
use App\Domain\OrderTotals;
use App\Models\Product;

/** The server's answer to a cart: every line priced, and the totals. */
final readonly class Quote
{
    /**
     * @param  list<CartLine>  $lines
     * @param  array<int, Product>  $products  by id
     */
    public function __construct(
        public array $lines,
        public array $products,
        public OrderTotals $totals,
        public ?string $promoCode,
    ) {}

    /** A free drink costs the full 50 points, and only when it takes something off. */
    public function pointsSpent(): int
    {
        return $this->totals->discount > 0 ? Loyalty::REWARD_POINTS : 0;
    }

    /** The non-default choices as text: "Large, Oat". */
    public function choicesText(CartLine $line, string $language): string
    {
        $product = $this->products[$line->product->id];
        $parts = [];
        foreach ($product->options ?? [] as $group) {
            $chosen = $line->options[$group['name']['en']] ?? null;
            foreach (array_slice($group['choices'], 1) as $choice) {
                if ($choice['label']['en'] === $chosen) {
                    $parts[] = filled($choice['label'][$language] ?? null) ? $choice['label'][$language] : $choice['label']['en'];
                }
            }
        }

        return implode(', ', $parts);
    }

    public function toApiArray(): array
    {
        return [
            'subtotal_cents' => $this->totals->subtotal,
            'discount_cents' => $this->totals->discount,
            'promo_code' => $this->promoCode,
            'promo_cents' => $this->totals->promoAmount,
            'total_cents' => $this->totals->total,
            'points_spent' => $this->pointsSpent(),
            'points_earned' => $this->totals->pointsEarned(),
            'lines' => array_map(fn (CartLine $line) => [
                'product_id' => $line->product->id,
                'options' => (object) $line->options,
                'note' => $line->note,
                'quantity' => $line->quantity,
                'unit_cents' => $line->unitCents,
                'line_cents' => $line->lineCents(),
            ], $this->lines),
        ];
    }
}
