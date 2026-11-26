<?php

namespace App\Domain;

final readonly class Choice
{
    public function __construct(
        public string $label,
        public int $priceCents = 0,
    ) {}

    /** @param  array{label: string, price?: float|int}  $data */
    public static function fromMenuJson(array $data): self
    {
        return new self($data['label'], Money::fromDollars($data['price'] ?? 0));
    }
}
