<?php

namespace App\Actions;

use App\Enums\UserRole;
use App\Models\User;
use App\Notifications\StaffInvite;
use Filament\Facades\Filament;
use Illuminate\Support\Facades\Password;

/**
 * Adds a barista, manager or owner and emails them a link to choose a
 * password. Someone who already uses the app keeps their account, points
 * and orders, and becomes staff.
 */
class InviteStaff
{
    public function handle(string $email, ?string $name, UserRole $role, User $owner): User
    {
        $email = strtolower(trim($email));
        $user = User::firstOrNew(['email' => $email]);
        $user->name = filled($name) ? trim($name) : $user->name;
        $user->role = $role;
        $user->save();

        $this->sendLink($user, $owner);

        return $user;
    }

    public function sendLink(User $user, User $owner): void
    {
        $token = Password::broker('staff')->createToken($user);
        $url = Filament::getPanel('admin')->getResetPasswordUrl($token, $user);

        $user->notify(new StaffInvite($url, $user->role, $owner->name ?: $owner->email));
    }
}
