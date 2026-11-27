<?php

namespace App\Filament\Resources\Staff;

use App\Actions\InviteStaff;
use App\Enums\UserRole;
use App\Filament\Resources\Staff\Pages\ManageStaff;
use App\Models\User;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Forms\Components\Radio;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

/**
 * Who can open the admin panel, for the owner only. Baristas run the board
 * and counter points; managers also edit the menu, promo codes, settings
 * and see reports; owners also manage staff.
 */
class StaffResource extends Resource
{
    public const ROLE_HELP = [
        'barista' => 'Orders board, sold out and counter points',
        'manager' => 'Also the menu, promo codes, orders, customers, settings and reports',
        'owner' => 'Everything, including this staff page',
    ];

    protected static ?string $model = User::class;

    protected static ?string $slug = 'staff';

    protected static ?string $modelLabel = 'staff member';

    protected static ?string $pluralModelLabel = 'staff';

    protected static ?string $navigationLabel = 'Staff';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedIdentification;

    protected static ?int $navigationSort = 60;

    public static function isOwner(): bool
    {
        return auth()->user()?->role === UserRole::Owner;
    }

    public static function canViewAny(): bool
    {
        return self::isOwner();
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(Model $record): bool
    {
        return false;
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where('role', '!=', UserRole::Customer);
    }

    /** @return array<string, string> */
    public static function roleOptions(): array
    {
        return collect([UserRole::Barista, UserRole::Manager, UserRole::Owner])
            ->mapWithKeys(fn (UserRole $role) => [$role->value => $role->label()])
            ->all();
    }

    public static function roleColor(UserRole $role): string
    {
        return match ($role) {
            UserRole::Owner => 'danger',
            UserRole::Manager => 'warning',
            default => 'gray',
        };
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('name')
            ->columns([
                TextColumn::make('name')
                    ->searchable()
                    ->sortable()
                    ->description(fn (User $record) => $record->is(auth()->user()) ? 'You' : null),
                TextColumn::make('email')->searchable(),
                TextColumn::make('role')
                    ->badge()
                    ->formatStateUsing(fn (UserRole $state) => $state->label())
                    ->color(fn (UserRole $state) => self::roleColor($state)),
                TextColumn::make('password')
                    ->label('Signed in')
                    ->state(fn (User $record) => $record->password === null ? 'Invite sent' : 'Has a password')
                    ->badge()
                    ->color(fn (User $record) => $record->password === null ? 'warning' : 'success'),
            ])
            ->recordActions([
                Action::make('role')
                    ->label('Change role')
                    ->icon(Heroicon::OutlinedArrowsUpDown)
                    ->hidden(fn (User $record) => $record->is(auth()->user()))
                    ->fillForm(fn (User $record) => ['role' => $record->role->value])
                    ->schema([
                        Radio::make('role')
                            ->options(self::roleOptions())
                            ->descriptions(self::ROLE_HELP)
                            ->required(),
                    ])
                    ->action(function (User $record, array $data) {
                        $record->role = UserRole::from($data['role']);
                        $record->save();
                        Notification::make()->title(($record->name ?: $record->email)." is now a {$record->role->label()}")->success()->send();
                    }),
                Action::make('resend')
                    ->label('Send invite again')
                    ->icon(Heroicon::OutlinedEnvelope)
                    ->visible(fn (User $record) => $record->password === null)
                    ->action(function (User $record) {
                        app(InviteStaff::class)->sendLink($record, auth()->user());
                        Notification::make()->title("Invite sent to {$record->email}")->success()->send();
                    }),
                Action::make('remove')
                    ->label('Remove')
                    ->icon(Heroicon::OutlinedUserMinus)
                    ->color('danger')
                    ->hidden(fn (User $record) => $record->is(auth()->user()))
                    ->requiresConfirmation()
                    ->modalHeading(fn (User $record) => 'Remove '.($record->name ?: $record->email).' from staff?')
                    ->modalDescription('They are signed out of the admin panel now. If they use the app, their account, points and orders stay.')
                    ->modalSubmitActionLabel('Remove from staff')
                    ->action(function (User $record) {
                        $record->role = UserRole::Customer;
                        $record->save();
                        // Sign them out of the admin panel on every device
                        DB::table(config('session.table', 'sessions'))->where('user_id', $record->id)->delete();
                        Notification::make()->title(($record->name ?: $record->email).' removed from staff')->success()->send();
                    }),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ManageStaff::route('/'),
        ];
    }
}
