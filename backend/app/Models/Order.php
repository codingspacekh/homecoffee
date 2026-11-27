<?php

namespace App\Models;

use App\Enums\OrderStatus;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable([
    'user_id', 'status', 'customer_name', 'customer_phone', 'payment_method',
    'pickup_at', 'estimated_ready_at', 'subtotal_cents', 'discount_cents',
    'promo_code', 'promo_cents', 'total_cents', 'points_spent', 'points_earned',
    'idempotency_key',
])]
class Order extends Model
{
    /** Order numbers start at 1001, so the first order doesn't look like a test. */
    public const NUMBER_OFFSET = 1000;

    protected $attributes = [
        'status' => 'received',
        'payment_method' => 'counter',
    ];

    protected function casts(): array
    {
        return [
            'status' => OrderStatus::class,
            'pickup_at' => 'datetime',
            'estimated_ready_at' => 'datetime',
            'preparing_at' => 'datetime',
            'ready_at' => 'datetime',
            'collected_at' => 'datetime',
            'cancelled_at' => 'datetime',
            'subtotal_cents' => 'integer',
            'discount_cents' => 'integer',
            'promo_cents' => 'integer',
            'total_cents' => 'integer',
            'points_spent' => 'integer',
            'points_earned' => 'integer',
        ];
    }

    /** The number the customer shows at the counter. */
    public function number(): int
    {
        return self::NUMBER_OFFSET + $this->id;
    }

    /** @return BelongsTo<User, $this> */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /** @return HasMany<OrderLine, $this> */
    public function lines(): HasMany
    {
        return $this->hasMany(OrderLine::class);
    }

    /** The order as the app reads it. */
    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'number' => $this->number(),
            'status' => $this->status->value,
            'customer_name' => $this->customer_name,
            'payment_method' => $this->payment_method,
            'pickup_at' => $this->pickup_at?->toIso8601String(),
            'estimated_ready_at' => $this->estimated_ready_at->toIso8601String(),
            'created_at' => $this->created_at->toIso8601String(),
            'preparing_at' => $this->preparing_at?->toIso8601String(),
            'ready_at' => $this->ready_at?->toIso8601String(),
            'collected_at' => $this->collected_at?->toIso8601String(),
            'cancelled_at' => $this->cancelled_at?->toIso8601String(),
            'subtotal_cents' => $this->subtotal_cents,
            'discount_cents' => $this->discount_cents,
            'promo_code' => $this->promo_code,
            'promo_cents' => $this->promo_cents,
            'total_cents' => $this->total_cents,
            'points_spent' => $this->points_spent,
            'points_earned' => $this->points_earned,
            'can_cancel' => $this->status === OrderStatus::Received,
            'lines' => $this->lines->map->toApiArray()->all(),
        ];
    }
}
