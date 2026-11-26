<?php

namespace App\Filament\Resources\Categories\Schemas;

use App\Filament\Support\Fields;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Illuminate\Support\Str;

class CategoryForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema->components([
            Section::make('Category')
                ->columnSpanFull()
                ->schema([
                    Fields::translated('name', 'Name'),
                    TextInput::make('slug')
                        ->label('Short name for links')
                        ->helperText('Lowercase letters and dashes, for example hot-coffee. Leave empty to make it from the English name.')
                        ->alphaDash()
                        ->maxLength(60)
                        ->unique(ignoreRecord: true)
                        ->dehydrateStateUsing(fn (?string $state, $get) => Str::slug(filled($state) ? $state : (string) $get('name.en'))),
                ]),
        ]);
    }
}
