<?php

namespace App\Domain;

final readonly class Choice
{
    public function __construct(
        public string $label,
        public int $priceCents = 0,
    ) {}

    /** @param  array{label: string, price_cents?: int}  $data */
    public static function fromArray(array $data): self
    {
        return new self($data['label'], (int) ($data['price_cents'] ?? 0));
    }
}
