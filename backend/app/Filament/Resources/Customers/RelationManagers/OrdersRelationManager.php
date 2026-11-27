<?php

namespace App\Filament\Resources\Customers\RelationManagers;

use App\Domain\Money;
use App\Enums\OrderStatus;
use App\Filament\Resources\Orders\OrderResource;
use App\Models\Order;
use App\Models\StoreSetting;
use Filament\Actions\Action;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class OrdersRelationManager extends RelationManager
{
    protected static string $relationship = 'orders';

    public function table(Table $table): Table
    {
        $timezone = StoreSetting::current()->timezone;

        return $table
            ->defaultSort('id', 'desc')
            ->columns([
                TextColumn::make('id')->label('Order')->formatStateUsing(fn (Order $record) => "#{$record->number()}")->weight('bold'),
                TextColumn::make('created_at')->label('Placed')->dateTime('j M Y, g:i A', $timezone),
                TextColumn::make('status')->badge()
                    ->formatStateUsing(fn (OrderStatus $state) => ucfirst($state->value))
                    ->color(fn (OrderStatus $state) => OrderResource::statusColor($state)),
                TextColumn::make('total_cents')->label('Total')->formatStateUsing(fn (int $state) => Money::format($state))->alignEnd(),
            ])
            ->recordActions([
                Action::make('open')->label('View')->url(fn (Order $record) => OrderResource::getUrl('view', ['record' => $record])),
            ]);
    }
}
