<?php

namespace App\Filament\Resources\Staff\Pages;

use App\Actions\InviteStaff;
use App\Enums\UserRole;
use App\Filament\Resources\Staff\StaffResource;
use App\Models\User;
use Filament\Actions\Action;
use Filament\Forms\Components\Radio;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ManageRecords;
use Filament\Support\Icons\Heroicon;

class ManageStaff extends ManageRecords
{
    protected static string $resource = StaffResource::class;

    protected ?string $subheading = 'Each person signs in with their own email. They get a link to choose a password.';

    protected function getHeaderActions(): array
    {
        return [
            Action::make('invite')
                ->label('Invite staff')
                ->icon(Heroicon::OutlinedUserPlus)
                ->modalHeading('Invite a staff member')
                ->modalDescription('They get an email with a link to choose a password. If they already use the app with this email, they keep their points.')
                ->modalSubmitActionLabel('Send invite')
                ->schema([
                    TextInput::make('name')->required()->maxLength(80),
                    TextInput::make('email')
                        ->email()
                        ->required()
                        ->maxLength(255)
                        ->rule(fn () => function (string $attribute, $value, \Closure $fail) {
                            $user = User::where('email', strtolower(trim((string) $value)))->first();
                            if ($user?->role->isStaff()) {
                                $fail("{$user->email} is already on staff as a {$user->role->label()}.");
                            }
                        }),
                    Radio::make('role')
                        ->options(StaffResource::roleOptions())
                        ->descriptions(StaffResource::ROLE_HELP)
                        ->default(UserRole::Barista->value)
                        ->required(),
                ])
                ->action(function (array $data) {
                    $user = app(InviteStaff::class)->handle($data['email'], $data['name'], UserRole::from($data['role']), auth()->user());
                    Notification::make()
                        ->title("Invite sent to {$user->email}")
                        ->body('The link works for 24 hours.')
                        ->success()
                        ->send();
                }),
        ];
    }
}
