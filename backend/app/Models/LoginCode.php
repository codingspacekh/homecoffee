<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['email', 'code_hash', 'expires_at'])]
class LoginCode extends Model
{
    public const MAX_ATTEMPTS = 5;

    public const VALID_MINUTES = 10;

    protected function casts(): array
    {
        return [
            'attempts' => 'integer',
            'expires_at' => 'datetime',
        ];
    }
}
