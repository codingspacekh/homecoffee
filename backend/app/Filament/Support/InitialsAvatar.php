<?php

namespace App\Filament\Support;

use Filament\AvatarProviders\Contracts\AvatarProvider;
use Filament\Facades\Filament;
use Illuminate\Database\Eloquent\Model;

/**
 * Staff initials on a coffee-coloured circle, drawn here. Filament's default
 * loads the picture from ui-avatars.com, which would send staff names to
 * another company and breaks on a shop tablet without that site.
 */
class InitialsAvatar implements AvatarProvider
{
    public function get(Model $record): string
    {
        $name = trim(Filament::getNameForDefaultAvatar($record));
        $initials = collect(preg_split('/\s+/u', $name) ?: [])
            ->filter()
            ->take(2)
            ->map(fn (string $word) => mb_strtoupper(mb_substr($word, 0, 1)))
            ->implode('') ?: '?';

        $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
            .'<rect width="64" height="64" fill="#7a4a2a"/>'
            .'<text x="32" y="33" fill="#fff" font-family="Figtree, Arial, sans-serif" font-size="26" font-weight="600" text-anchor="middle" dominant-baseline="middle">'
            .htmlspecialchars($initials, ENT_XML1).'</text></svg>';

        return 'data:image/svg+xml;base64,'.base64_encode($svg);
    }
}
