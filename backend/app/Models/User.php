<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Domain\Loyalty;
use App\Enums\UserRole;
use Database\Factories\UserFactory;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'email', 'password', 'phone', 'language'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable implements FilamentUser
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * New accounts are customers. Only the owner gives out staff roles.
     * Points change only through PlaceOrder, CancelOrder and AwardPoints.
     */
    protected $attributes = [
        'role' => 'customer',
        'language' => 'en',
        'points' => 0,
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'role' => UserRole::class,
            'points' => 'integer',
        ];
    }

    /** Only baristas, managers and the owner can open the admin panel. */
    public function canAccessPanel(Panel $panel): bool
    {
        return $this->role->isStaff();
    }

    /** @return HasMany<Order, $this> */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    /** @return BelongsToMany<Product, $this> */
    public function favourites(): BelongsToMany
    {
        return $this->belongsToMany(Product::class, 'favourites')->withTimestamps();
    }

    /** @return HasMany<PointEntry, $this> */
    public function pointEntries(): HasMany
    {
        return $this->hasMany(PointEntry::class);
    }

    /** The profile as the app reads it from GET /api/v1/me. */
    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'language' => $this->language,
            'points' => $this->points,
            'reward_points' => Loyalty::REWARD_POINTS,
            'has_reward' => Loyalty::hasReward($this->points),
        ];
    }
}
