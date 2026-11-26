<?php

namespace App\Filament\Resources\Products\Tables;

use App\Domain\Money;
use App\Models\Category;
use App\Models\Product;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class ProductsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            // In menu order: by category, then by product.
            ->defaultSort(fn (Builder $query) => $query
                ->orderBy(Category::select('sort')->whereColumn('categories.id', 'products.category_id'))
                ->orderBy('sort'))
            ->reorderable('sort', fn () => auth()->user()?->can('create', Product::class))
            ->paginated([25, 50, 100])
            ->defaultPaginationPageOption(50)
            ->columns([
                ImageColumn::make('image_path')->label('')->disk('public')->square()->imageSize(48),
                TextColumn::make('name.en')
                    ->label('Name')
                    ->description(fn (Product $record) => $record->name['km'] ?? null)
                    ->searchable(query: fn (Builder $query, string $search) => $query
                        ->where('name->en', 'like', "%{$search}%")
                        ->orWhere('name->km', 'like', "%{$search}%")),
                TextColumn::make('category.name.en')->label('Category'),
                TextColumn::make('price_cents')
                    ->label('Price')
                    ->formatStateUsing(fn (int $state) => Money::format($state))
                    ->alignEnd(),
                ToggleColumn::make('available')
                    ->label('Available')
                    ->disabled(fn () => ! auth()->user()?->can('toggleAvailability', Product::class)),
            ])
            ->filters([
                SelectFilter::make('category_id')
                    ->label('Category')
                    ->options(fn () => Category::query()->orderBy('sort')->get()->mapWithKeys(fn (Category $c) => [$c->id => $c->translated('name')])),
                TernaryFilter::make('available')->label('Available'),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
