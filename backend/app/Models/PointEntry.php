<?php

namespace App\Models;

use App\Enums\PointReason;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** One line of a customer's points history. */
#[Fillable(['user_id', 'order_id', 'change', 'reason'])]
class PointEntry extends Model
{
    public const UPDATED_AT = null;

    protected function casts(): array
    {
        return [
            'change' => 'integer',
            'reason' => PointReason::class,
        ];
    }

    /** @return BelongsTo<Order, $this> */
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'change' => $this->change,
            'reason' => $this->reason->value,
            'order_number' => $this->order?->number(),
            'created_at' => $this->created_at->toIso8601String(),
        ];
    }
}
