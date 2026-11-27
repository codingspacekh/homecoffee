<?php

namespace App\Filament\Resources\Orders;

use App\Actions\CancelOrder;
use App\Domain\Money;
use App\Enums\OrderStatus;
use App\Exceptions\ApiProblem;
use App\Filament\Resources\Orders\Pages\ListOrders;
use App\Filament\Resources\Orders\Pages\ViewOrder;
use App\Models\Order;
use App\Models\OrderLine;
use App\Models\StoreSetting;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Textarea;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

/** Every order, past and open, for managers: find one, see what was in it, cancel it. */
class OrderResource extends Resource
{
    protected static ?string $model = Order::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedReceiptPercent;

    protected static ?int $navigationSort = -5;

    protected static ?string $recordTitleAttribute = 'id';

    public static function canViewAny(): bool
    {
        return auth()->user()?->role->canManageShop() ?? false;
    }

    public static function canView(Model $record): bool
    {
        return static::canViewAny();
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function getRecordTitle(?Model $record): string
    {
        return $record ? "Order #{$record->number()}" : 'Order';
    }

    public static function statusColor(OrderStatus $status): string
    {
        return match ($status) {
            OrderStatus::Received => 'warning',
            OrderStatus::Preparing => 'primary',
            OrderStatus::Ready => 'success',
            OrderStatus::Collected => 'gray',
            OrderStatus::Cancelled => 'danger',
        };
    }

    public static function table(Table $table): Table
    {
        $timezone = StoreSetting::current()->timezone;

        return $table
            ->modifyQueryUsing(fn (Builder $query) => $query->withCount('lines'))
            ->defaultSort('id', 'desc')
            ->columns([
                TextColumn::make('id')
                    ->label('Order')
                    ->formatStateUsing(fn (Order $record) => "#{$record->number()}")
                    ->weight('bold')
                    ->sortable()
                    ->searchable(query: fn (Builder $query, string $search) => $query
                        ->when(ctype_digit(ltrim($search, '#')), fn (Builder $q) => $q->orWhere('id', (int) ltrim($search, '#') - Order::NUMBER_OFFSET))),
                TextColumn::make('created_at')->label('Placed')->dateTime('j M, g:i A', $timezone)->sortable(),
                TextColumn::make('customer_name')
                    ->label('Customer')
                    ->description(fn (Order $record) => $record->customer_phone)
                    ->searchable(['customer_name', 'customer_phone']),
                TextColumn::make('status')
                    ->badge()
                    ->formatStateUsing(fn (OrderStatus $state) => ucfirst($state->value))
                    ->color(fn (OrderStatus $state) => self::statusColor($state)),
                TextColumn::make('lines_count')->label('Items')->numeric()->alignEnd(),
                TextColumn::make('promo_code')->label('Promo')->placeholder('None')->toggleable(),
                TextColumn::make('total_cents')
                    ->label('Total')
                    ->formatStateUsing(fn (int $state) => Money::format($state))
                    ->alignEnd()
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->multiple()
                    ->options(collect(OrderStatus::cases())->mapWithKeys(fn (OrderStatus $s) => [$s->value => ucfirst($s->value)])),
                Filter::make('day')
                    ->schema([DatePicker::make('day')->label('Day')->native(false)->displayFormat('j M Y')])
                    ->query(function (Builder $query, array $data) use ($timezone) {
                        if (blank($data['day'] ?? null)) {
                            return $query;
                        }
                        $start = Carbon::parse($data['day'], $timezone)->startOfDay();

                        return $query->where('created_at', '>=', $start->copy()->utc())
                            ->where('created_at', '<', $start->copy()->addDay()->utc());
                    })
                    ->indicateUsing(fn (array $data) => filled($data['day'] ?? null) ? 'Day: '.Carbon::parse($data['day'])->format('j M Y') : null),
            ])
            ->recordActions([
                ViewAction::make(),
                self::cancelAction(),
            ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        $timezone = StoreSetting::current()->timezone;
        $time = fn (string $column) => TextEntry::make($column)->dateTime('j M Y, g:i A', $timezone)->placeholder('Not yet');

        return $schema->columns(1)->components([
            Grid::make(['default' => 1, 'lg' => 3])->schema([
                Section::make('Order')->columnSpan(['lg' => 2])->schema([
                    Grid::make(['default' => 2, 'md' => 4])->schema([
                        TextEntry::make('status')->badge()
                            ->formatStateUsing(fn (OrderStatus $state) => ucfirst($state->value))
                            ->color(fn (OrderStatus $state) => self::statusColor($state)),
                        TextEntry::make('customer_name')->label('Customer'),
                        TextEntry::make('customer_phone')->label('Phone')->placeholder('None'),
                        TextEntry::make('user.email')->label('Account')->placeholder('Removed'),
                    ]),
                    RepeatableEntry::make('lines')
                        ->label('What they ordered')
                        ->schema([
                            TextEntry::make('name')
                                ->hiddenLabel()
                                ->state(fn (OrderLine $record) => "{$record->quantity} × {$record->translated('name')}")
                                ->weight('bold')
                                ->helperText(fn (OrderLine $record) => collect([$record->translated('choices'), filled($record->note) ? "Note: {$record->note}" : null])->filter()->implode('. ') ?: null),
                            TextEntry::make('line_cents')->hiddenLabel()->formatStateUsing(fn (int $state) => Money::format($state))->alignEnd(),
                        ])
                        ->columns(2)
                        ->contained(false),
                    Grid::make(['default' => 2, 'md' => 4])->schema([
                        TextEntry::make('subtotal_cents')->label('Subtotal')->formatStateUsing(fn (int $state) => Money::format($state)),
                        TextEntry::make('discount_cents')->label('Free drink')->formatStateUsing(fn (int $state) => $state > 0 ? '−'.Money::format($state) : 'None'),
                        TextEntry::make('promo_cents')->label('Promo')
                            ->formatStateUsing(fn (Order $record) => $record->promo_cents > 0 ? "{$record->promo_code}, −".Money::format($record->promo_cents) : 'None'),
                        TextEntry::make('total_cents')->label('Paid at the counter')->weight('bold')->formatStateUsing(fn (int $state) => Money::format($state)),
                    ]),
                ]),
                Section::make('Times')->columnSpan(1)->schema([
                    $time('created_at')->label('Placed'),
                    $time('pickup_at')->label('Pickup time')->placeholder('As soon as possible'),
                    $time('preparing_at')->label('Started'),
                    $time('ready_at')->label('Ready'),
                    $time('collected_at')->label('Picked up'),
                    $time('cancelled_at')->label('Cancelled')->visible(fn (Order $record) => $record->cancelled_at !== null),
                    TextEntry::make('cancel_reason')->label('Why')->visible(fn (Order $record) => $record->cancelled_at !== null),
                    TextEntry::make('points_earned')->label('Points')
                        ->formatStateUsing(fn (Order $record) => collect([
                            $record->points_earned > 0 ? "+{$record->points_earned} earned" : null,
                            $record->points_spent > 0 ? "−{$record->points_spent} for a free drink" : null,
                        ])->filter()->implode(', ') ?: 'None'),
                ]),
            ]),
        ]);
    }

    /** Cancel an open order with a reason the customer reads in the app. */
    public static function cancelAction(): Action
    {
        return Action::make('cancel')
            ->label('Cancel')
            ->icon(Heroicon::OutlinedXCircle)
            ->color('danger')
            ->visible(fn (Order $record) => $record->status->isOpen())
            ->modalHeading(fn (Order $record) => "Cancel order #{$record->number()}")
            ->modalDescription('The customer sees the reason in the app. A free drink they used goes back to their points.')
            ->modalSubmitActionLabel('Cancel order')
            ->modalCancelActionLabel('Keep order')
            ->schema([
                Textarea::make('reason')->label('Reason')->required()->maxLength(200),
            ])
            ->action(function (Order $record, array $data) {
                try {
                    app(CancelOrder::class)->handle($record, byCustomer: false, reason: $data['reason']);
                    Notification::make()->title("Order #{$record->number()} cancelled")->success()->send();
                } catch (ApiProblem) {
                    Notification::make()->title("Order #{$record->number()} is already finished")->warning()->send();
                }
            });
    }

    public static function getPages(): array
    {
        return [
            'index' => ListOrders::route('/'),
            'view' => ViewOrder::route('/{record}'),
        ];
    }
}
