<?php

namespace App\Policies;

use App\Models\Order;
use App\Models\PromoCode;
use App\Models\User;

/** Managers and the owner run promo codes. */
class PromoCodePolicy
{
    public function viewAny(User $user): bool
    {
        return $user->role->canManageShop();
    }

    public function create(User $user): bool
    {
        return $user->role->canManageShop();
    }

    public function update(User $user, PromoCode $promo): bool
    {
        return $user->role->canManageShop();
    }

    /** Only a code no order used yet; switch a used one off instead. */
    public function delete(User $user, PromoCode $promo): bool
    {
        return $user->role->canManageShop() && ! Order::where('promo_code', $promo->code)->exists();
    }
}
