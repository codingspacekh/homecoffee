<?php

namespace App\Policies;

use App\Models\Order;
use App\Models\User;

/**
 * In the app, customers see and cancel only their own orders. In the admin
 * panel, managers and the owner see every order.
 */
class OrderPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->role->canManageShop();
    }

    public function view(User $user, Order $order): bool
    {
        return $order->user_id === $user->id || $user->role->canManageShop();
    }

    public function cancel(User $user, Order $order): bool
    {
        return $order->user_id === $user->id;
    }
}
