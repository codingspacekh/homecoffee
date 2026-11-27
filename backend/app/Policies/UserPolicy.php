<?php

namespace App\Policies;

use App\Enums\UserRole;
use App\Models\User;

/**
 * Accounts in the admin panel. Managers and the owner see customers; only
 * the owner adds, changes or removes staff (the Staff page narrows this
 * further to owners).
 */
class UserPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->role->canManageShop();
    }

    public function view(User $user, User $account): bool
    {
        return $user->role->canManageShop();
    }

    public function create(User $user): bool
    {
        return $user->role === UserRole::Owner;
    }

    public function update(User $user, User $account): bool
    {
        return $user->role === UserRole::Owner;
    }

    public function delete(User $user, User $account): bool
    {
        return false;
    }

    public function deleteAny(User $user): bool
    {
        return false;
    }
}
