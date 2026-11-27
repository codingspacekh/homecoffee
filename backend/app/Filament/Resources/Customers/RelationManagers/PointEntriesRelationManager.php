<?php

namespace App\Filament\Resources\Customers\RelationManagers;

use App\Enums\PointReason;
use App\Models\PointEntry;
use App\Models\StoreSetting;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Livewire\Attributes\On;

class PointEntriesRelationManager extends RelationManager
{
    protected static string $relationship = 'pointEntries';

    protected static ?string $title = 'Points history';

    #[On('refresh-points-history')]
    public function refreshHistory(): void
    {
        $this->resetTable();
    }

    public function table(Table $table): Table
    {
        $timezone = StoreSetting::current()->timezone;

        return $table
            ->modifyQueryUsing(fn ($query) => $query->with(['order', 'staff']))
            ->defaultSort('id', 'desc')
            ->columns([
                TextColumn::make('created_at')->label('When')->dateTime('j M Y, g:i A', $timezone),
                TextColumn::make('reason')
                    ->formatStateUsing(fn (PointReason $state) => $state->label())
                    ->description(fn (PointEntry $record) => $record->order ? "Order #{$record->order->number()}" : null),
                TextColumn::make('change')
                    ->label('Points')
                    ->formatStateUsing(fn (int $state) => $state > 0 ? "+{$state}" : (string) $state)
                    ->color(fn (int $state) => $state > 0 ? 'success' : 'danger')
                    ->alignEnd(),
                TextColumn::make('note')
                    ->placeholder('')
                    ->description(fn (PointEntry $record) => $record->staff ? "By {$record->staff->name}" : null)
                    ->wrap(),
            ]);
    }
}
