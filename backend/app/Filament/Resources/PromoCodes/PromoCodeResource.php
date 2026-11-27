<?php

namespace App\Filament\Resources\PromoCodes;

use App\Domain\Money;
use App\Domain\Promo;
use App\Enums\OrderStatus;
use App\Filament\Resources\PromoCodes\Pages\ManagePromoCodes;
use App\Filament\Support\Fields;
use App\Models\Order;
use App\Models\PromoCode;
use App\Models\StoreSetting;
use BackedEnum;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Components\ToggleButtons;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class PromoCodeResource extends Resource
{
    protected static ?string $model = PromoCode::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedTicket;

    protected static string|\UnitEnum|null $navigationGroup = 'Customers';

    protected static ?int $navigationSort = 3;

    protected static ?string $navigationLabel = 'Promo codes';

    protected static ?string $recordTitleAttribute = 'code';

    public static function form(Schema $schema): Schema
    {
        $timezone = StoreSetting::current()->timezone;

        return $schema->columns(1)->components([
            TextInput::make('code')
                ->required()
                ->maxLength(20)
                ->regex('/^[A-Za-z0-9]+$/')
                ->validationMessages(['regex' => 'Use only letters and numbers.'])
                // Same code in other capitals counts as taken, on any database
                ->rule(fn (?PromoCode $record) => function (string $attribute, $value, \Closure $fail) use ($record) {
                    $taken = PromoCode::where('code', Promo::normalize((string) $value))
                        ->when($record, fn (Builder $query) => $query->whereKeyNot($record->getKey()))
                        ->exists();
                    if ($taken) {
                        $fail('There is already a code called '.Promo::normalize((string) $value).'.');
                    }
                })
                ->helperText('Letters and numbers. Customers type it at checkout, in capitals or not.')
                ->extraInputAttributes(['style' => 'text-transform: uppercase']),
            ToggleButtons::make('kind')
                ->label('Discount')
                ->options(['percent' => 'Percent off', 'amount' => 'Amount off'])
                ->inline()
                ->default('percent')
                ->live()
                ->dehydrated(false)
                ->afterStateHydrated(fn (ToggleButtons $component, ?PromoCode $record) => $component->state($record?->amount_cents !== null ? 'amount' : 'percent')),
            Grid::make(['default' => 1, 'md' => 2])->schema([
                TextInput::make('percent')
                    ->label('Percent off')
                    ->suffix('%')
                    ->integer()
                    ->minValue(1)
                    ->maxValue(100)
                    ->required(fn (Get $get) => $get('kind') === 'percent')
                    ->visible(fn (Get $get) => $get('kind') === 'percent')
                    ->dehydratedWhenHidden()
                    ->dehydrateStateUsing(fn ($state, Get $get) => $get('kind') === 'percent' ? (int) $state : null),
                Fields::price('amount_cents', 'Amount off')
                    ->default(null)
                    ->minValue(0.01)
                    ->required(fn (Get $get) => $get('kind') === 'amount')
                    ->visible(fn (Get $get) => $get('kind') === 'amount')
                    ->dehydratedWhenHidden()
                    ->dehydrateStateUsing(fn ($state, Get $get) => $get('kind') === 'amount' ? Money::fromDollars((float) $state) : null),
                Fields::price('minimum_cents', 'Smallest order')
                    ->helperText('After any free drink. 0 means any order.'),
            ]),
            Grid::make(['default' => 1, 'md' => 2])->schema([
                DateTimePicker::make('starts_at')->label('Starts')->seconds(false)->timezone($timezone)
                    ->helperText('Empty means it works now.'),
                DateTimePicker::make('ends_at')->label('Ends')->seconds(false)->timezone($timezone)
                    ->after('starts_at')
                    ->helperText('Empty means it never ends.'),
                TextInput::make('max_uses')->label('Uses in total')->integer()->minValue(1)
                    ->helperText('Across all customers. Empty means no limit.'),
            ]),
            Toggle::make('once_per_customer')->label('Once per customer'),
            Toggle::make('active')->label('On')->default(true)
                ->helperText('Turn off to stop the code at once without deleting it.'),
        ]);
    }

    public static function table(Table $table): Table
    {
        $timezone = StoreSetting::current()->timezone;

        return $table
            ->modifyQueryUsing(fn (Builder $query) => $query->addSelect([
                'uses' => Order::selectRaw('count(*)')
                    ->whereColumn('orders.promo_code', 'promo_codes.code')
                    ->where('status', '!=', OrderStatus::Cancelled),
            ]))
            ->defaultSort('code')
            ->columns([
                TextColumn::make('code')->searchable()->sortable()->weight('bold'),
                TextColumn::make('discount')
                    ->state(fn (PromoCode $record) => $record->toDomain()->label())
                    ->description(fn (PromoCode $record) => $record->minimum_cents > 0 ? 'Orders from '.Money::format($record->minimum_cents) : null),
                TextColumn::make('uses')
                    ->label('Used')
                    ->numeric()
                    ->sortable()
                    ->formatStateUsing(fn (PromoCode $record) => $record->max_uses === null ? (string) $record->uses : "{$record->uses} of {$record->max_uses}")
                    ->description(fn (PromoCode $record) => $record->once_per_customer ? 'Once per customer' : null),
                TextColumn::make('starts_at')->label('Starts')->dateTime('j M Y, g:i A', $timezone)->placeholder('Now'),
                TextColumn::make('ends_at')->label('Ends')->dateTime('j M Y, g:i A', $timezone)->placeholder('Never'),
                ToggleColumn::make('active')->label('On'),
            ])
            ->filters([
                TernaryFilter::make('active')->label('On'),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ManagePromoCodes::route('/'),
        ];
    }
}
