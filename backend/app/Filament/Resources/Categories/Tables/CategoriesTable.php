<?php

namespace App\Filament\Resources\Categories\Tables;

use App\Models\Category;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class CategoriesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('sort')
            ->reorderable('sort')
            ->paginated(false)
            ->columns([
                TextColumn::make('name.en')
                    ->label('Name')
                    ->description(fn (Category $record) => $record->name['km'] ?? null),
                TextColumn::make('products_count')->counts('products')->label('Products')->alignEnd(),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make()->tooltip('Only empty categories can be deleted.'),
            ]);
    }
}
