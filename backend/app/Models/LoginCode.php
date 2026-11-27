<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\MassPrunable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['email', 'code_hash', 'expires_at'])]
class LoginCode extends Model
{
    use MassPrunable;

    public const MAX_ATTEMPTS = 5;

    public const VALID_MINUTES = 10;

    /** Codes a day past their expiry are removed every night by model:prune. */
    public function prunable(): Builder
    {
        return static::where('expires_at', '<', now()->subDay());
    }

    protected function casts(): array
    {
        return [
            'attempts' => 'integer',
            'expires_at' => 'datetime',
        ];
    }
}
