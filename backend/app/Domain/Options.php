<?php

namespace App\Domain;

/** The website's services/Options.js, in PHP. Same rules as packages/domain in Dart. */
final class Options
{
    public const NOTE_MAX_LENGTH = 60;

    /**
     * Fills in defaults and drops choices the product doesn't offer.
     *
     * @param  array<string, string>  $selection
     * @return array<string, string>
     */
    public static function resolve(Product $product, array $selection = []): array
    {
        $resolved = [];
        foreach ($product->options as $group) {
            $resolved[$group->name] = ($group->find($selection[$group->name] ?? null) ?? $group->default())->label;
        }

        return $resolved;
    }

    /** @param  array<string, string>  $selection */
    public static function unitCents(Product $product, array $selection): int
    {
        $cents = $product->priceCents;
        foreach ($product->options as $group) {
            $cents += $group->find($selection[$group->name] ?? null)?->priceCents ?? 0;
        }

        return $cents;
    }

    /**
     * Same product, same choices and same note make the same cart line.
     *
     * @param  array<string, string>  $selection
     */
    public static function key(Product $product, array $selection, string $note = ''): string
    {
        $parts = [(string) $product->id];
        foreach ($product->options as $group) {
            $label = $selection[$group->name] ?? null;
            if ($label !== null && $label !== $group->default()->label) {
                $parts[] = "{$group->name}={$label}";
            }
        }
        if ($note !== '') {
            $parts[] = "note={$note}";
        }

        return implode('|', $parts);
    }

    public static function cleanNote(string $note): string
    {
        return mb_substr(trim($note), 0, self::NOTE_MAX_LENGTH);
    }

    /** @param  array<string, string>  $selection */
    public static function line(Product $product, array $selection = [], int $quantity = 1, string $note = ''): CartLine
    {
        $resolved = self::resolve($product, $selection);
        $cleaned = self::cleanNote($note);

        return new CartLine(
            key: self::key($product, $resolved, $cleaned),
            product: $product,
            options: $resolved,
            note: $cleaned,
            unitCents: self::unitCents($product, $resolved),
            quantity: $quantity,
        );
    }
}
