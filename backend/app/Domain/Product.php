<?php

namespace App\Domain;

/** What the price rules need to know about a menu item. */
final readonly class Product
{
    /** @param  list<OptionGroup>  $options */
    public function __construct(
        public int $id,
        public int $priceCents,
        public bool $drink = false,
        public array $options = [],
    ) {}

    /** @param  array<string, mixed>  $data  one product from the website's menu.json */
    public static function fromMenuJson(array $data): self
    {
        return new self(
            id: $data['id'],
            priceCents: Money::fromDollars($data['price']),
            drink: $data['drink'] ?? false,
            options: array_map(OptionGroup::fromMenuJson(...), $data['options'] ?? []),
        );
    }
}
