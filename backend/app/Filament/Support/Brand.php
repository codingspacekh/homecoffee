<?php

namespace App\Filament\Support;

use Filament\Support\Colors\Color;

/** HomeCoffee's look in the admin panel, matching the app. */
final class Brand
{
    /**
     * The app's coffee brown as Filament shades (Material 3 tones of the
     * #7B4B2A seed). Filament's own generator turns brown into orange.
     *
     * @return array<int, string>
     */
    public static function primary(): array
    {
        return array_map(Color::convertToOklch(...), [
            50 => '#FFEDE4',
            100 => '#FFDBC7',
            200 => '#FAB88F',
            300 => '#DB9E76',
            400 => '#BE845E',
            500 => '#A16B47',
            600 => '#7B4B2A',
            700 => '#683C1C',
            800 => '#4D2608',
            900 => '#311300',
            950 => '#210B00',
        ]);
    }

    /** public/fonts/homecoffee: the app's own fonts, so no font service is needed. */
    public static function fontCss(): string
    {
        return asset('fonts/homecoffee/fonts.css');
    }

    /** Figtree for Latin text, with Noto Sans Khmer for Khmer names, as in the app. */
    public static function fontFallback(): string
    {
        return "<style>:root { --font-family: 'Figtree', 'Noto Sans Khmer', ui-sans-serif, system-ui, sans-serif; }</style>";
    }
}
