<?php

namespace App\Enums;

enum UserRole: string
{
    case Customer = 'customer';
    case Barista = 'barista';
    case Manager = 'manager';
    case Owner = 'owner';

    /** Staff can open the admin panel. Customers only use the mobile app. */
    public function isStaff(): bool
    {
        return $this !== self::Customer;
    }

    /** Managers and the owner edit the menu, promo codes and settings. */
    public function canManageShop(): bool
    {
        return $this === self::Manager || $this === self::Owner;
    }

    public function label(): string
    {
        return ucfirst($this->value);
    }
}
