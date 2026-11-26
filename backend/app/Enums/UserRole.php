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

    public function label(): string
    {
        return ucfirst($this->value);
    }
}
