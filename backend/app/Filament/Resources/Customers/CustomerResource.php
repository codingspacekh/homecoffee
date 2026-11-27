<?php

namespace App\Filament\Resources\Customers;

use App\Actions\ChangePoints;
use App\Enums\PointReason;
use App\Enums\UserRole;
use App\Exceptions\ApiProblem;
use App\Filament\Resources\Customers\Pages\ListCustomers;
use App\Filament\Resources\Customers\Pages\ViewCustomer;
use App\Filament\Resources\Customers\RelationManagers\OrdersRelationManager;
use App\Filament\Resources\Customers\RelationManagers\PointEntriesRelationManager;
use App\Models\StoreSetting;
use App\Models\User;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\TextEntry;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

/** App customers: who they are, their orders and points, and a way to fix points. */
class CustomerResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $slug = 'customers';

    protected static ?string $modelLabel = 'customer';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUsers;

    protected static string|\UnitEnum|null $navigationGroup = 'Customers';

    protected static ?int $navigationSort = 1;

    protected static ?string $recordTitleAttribute = 'name';

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

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where('role', UserRole::Customer);
    }

    public static function getRecordTitle(?Model $record): string
    {
        return $record?->name ?? $record?->email ?? 'Customer';
    }

    public static function table(Table $table): Table
    {
        $timezone = StoreSetting::current()->timezone;

        return $table
            ->modifyQueryUsing(fn (Builder $query) => $query->withCount('orders'))
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('name')
                    ->placeholder('No name yet')
                    ->description(fn (User $record) => $record->email)
                    ->searchable(['name', 'email', 'phone', 'member_code']),
                TextColumn::make('phone')->placeholder('None'),
                TextColumn::make('points')->numeric()->sortable()->alignEnd(),
                TextColumn::make('orders_count')->label('Orders')->numeric()->sortable()->alignEnd(),
                TextColumn::make('created_at')->label('Joined')->date('j M Y', $timezone)->sortable(),
            ])
            ->recordActions([
                ViewAction::make(),
            ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        $timezone = StoreSetting::current()->timezone;

        return $schema->columns(1)->components([
            Section::make()->schema([
                Grid::make(['default' => 2, 'md' => 3, 'xl' => 6])->schema([
                    TextEntry::make('name')->placeholder('No name yet'),
                    TextEntry::make('email'),
                    TextEntry::make('phone')->placeholder('None'),
                    TextEntry::make('member_code')->label('Member code')->formatStateUsing(fn (User $record) => $record->memberCodeLabel()),
                    TextEntry::make('points')->weight('bold'),
                    TextEntry::make('created_at')->label('Joined')->date('j M Y', $timezone),
                ]),
            ]),
        ]);
    }

    /** Add or take away points by hand, with a note saying why. */
    public static function adjustPointsAction(): Action
    {
        return Action::make('adjustPoints')
            ->label('Adjust points')
            ->icon(Heroicon::OutlinedAdjustmentsHorizontal)
            ->modalDescription(fn (User $record) => "{$record->name} has {$record->points} points. The customer sees this in their points history as \"Adjusted\"; the note stays in the admin panel.")
            ->schema([
                TextInput::make('change')
                    ->label('Points to add')
                    ->helperText('Use a minus sign to take points away, for example -10.')
                    ->integer()
                    ->required()
                    ->notIn([0])
                    ->minValue(-1000)
                    ->maxValue(1000),
                TextInput::make('note')->label('Why')->required()->maxLength(200)
                    ->placeholder('Points missed on order #1042'),
            ])
            ->action(function (User $record, array $data, Action $action) {
                try {
                    app(ChangePoints::class)->handle($record, (int) $data['change'], PointReason::Adjustment, auth()->user(), $data['note']);
                    Notification::make()->title("{$record->name} now has {$record->points} points")->success()->send();
                } catch (ApiProblem) {
                    Notification::make()->title("{$record->name} has only {$record->points} points")->danger()->send();
                    $action->halt();
                }
            });
    }

    public static function getRelations(): array
    {
        return [
            PointEntriesRelationManager::class,
            OrdersRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListCustomers::route('/'),
            'view' => ViewCustomer::route('/{record}'),
        ];
    }
}
