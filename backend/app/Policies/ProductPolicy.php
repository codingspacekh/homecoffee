<?php

namespace App\Policies;

use App\Models\Product;
use App\Models\User;

/**
 * Every staff member sees the products and can mark one sold out.
 * Only managers and the owner change names, prices, options and photos.
 */
class ProductPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->role->isStaff();
    }

    public function toggleAvailability(User $user): bool
    {
        return $user->role->isStaff();
    }

    public function create(User $user): bool
    {
        return $user->role->canManageShop();
    }

    public function update(User $user, Product $product): bool
    {
        return $user->role->canManageShop();
    }

    public function delete(User $user, Product $product): bool
    {
        return $user->role->canManageShop();
    }

    public function deleteAny(User $user): bool
    {
        return $user->role->canManageShop();
    }
}
