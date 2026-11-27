<?php

use App\Models\Order;
use App\Models\User;
use Illuminate\Support\Facades\Broadcast;

// A customer hears status changes for their own orders only.
Broadcast::channel('orders.{order}', fn (User $user, Order $order) => $order->user_id === $user->id);
