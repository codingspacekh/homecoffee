<?php

namespace App\Filament\Support;

use App\Domain\Money;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;

/** Form fields shared by the menu forms. */
final class Fields
{
    /** English and Khmer side by side. English is required, Khmer falls back to English in the app. */
    public static function translated(string $name, string $label, bool $long = false, bool $required = true, bool $hint = true): Grid
    {
        $field = fn (string $language) => ($long ? Textarea::make("{$name}.{$language}")->rows(3) : TextInput::make("{$name}.{$language}"))
            ->maxLength($long ? 500 : 80);

        return Grid::make(['default' => 1, 'md' => 2])->schema([
            $field('en')->label("{$label} in English")->required($required),
            $field('km')->label("{$label} in Khmer")->helperText($hint ? 'Leave empty to show the English one.' : null),
        ]);
    }

    /** Typed in dollars ("3.75"), stored in cents (375). */
    public static function price(string $name, string $label = 'Price'): TextInput
    {
        return TextInput::make($name)
            ->label($label)
            ->prefix('$')
            ->numeric()
            ->inputMode('decimal')
            ->step('0.01')
            ->minValue(0)
            ->maxValue(1000)
            ->default(0)
            ->required()
            ->formatStateUsing(fn ($state) => $state === null ? null : number_format($state / 100, 2, '.', ''))
            ->dehydrateStateUsing(fn ($state) => Money::fromDollars((float) $state));
    }
}
