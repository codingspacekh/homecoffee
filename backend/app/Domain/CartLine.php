<?php

namespace App\Domain;

final readonly class CartLine
{
    /** @param  array<string, string>  $options  group name => chosen label, every group filled in */
    public function __construct(
        public string $key,
        public Product $product,
        public array $options,
        public string $note,
        public int $unitCents,
        public int $quantity = 1,
    ) {}

    public function lineCents(): int
    {
        return $this->unitCents * $this->quantity;
    }
}
