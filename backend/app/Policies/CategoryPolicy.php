<?php

namespace App\Policies;

use App\Models\Category;
use App\Models\User;

/** Managers and the owner edit menu categories. */
class CategoryPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->role->canManageShop();
    }

    public function create(User $user): bool
    {
        return $user->role->canManageShop();
    }

    public function update(User $user, Category $category): bool
    {
        return $user->role->canManageShop();
    }

    /** Only an empty category can go, so no product is left without one. */
    public function delete(User $user, Category $category): bool
    {
        return $user->role->canManageShop() && ! $category->products()->exists();
    }

    public function deleteAny(User $user): bool
    {
        return false;
    }
}
