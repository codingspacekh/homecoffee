<?php

namespace App\Models;

use App\Models\Concerns\HasTranslatedFields;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['product_id', 'name', 'options', 'choices', 'note', 'unit_cents', 'quantity', 'line_cents'])]
class OrderLine extends Model
{
    use HasTranslatedFields;

    public $timestamps = false;

    protected function casts(): array
    {
        return [
            'name' => 'array',
            'options' => 'array',
            'choices' => 'array',
            'unit_cents' => 'integer',
            'quantity' => 'integer',
            'line_cents' => 'integer',
        ];
    }

    /** @return BelongsTo<Order, $this> */
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    /** In the same shape as a cart line: English, with Khmer under translations. */
    public function toApiArray(): array
    {
        return array_filter([
            'product_id' => $this->product_id,
            'name' => $this->translated('name'),
            'options' => (object) $this->options,
            'choices' => $this->translated('choices') ?? '',
            'note' => $this->note,
            'unit_cents' => $this->unit_cents,
            'quantity' => $this->quantity,
            'line_cents' => $this->line_cents,
            'translations' => $this->translationsFor(['name', 'choices']) ?: null,
        ], fn ($value) => $value !== null);
    }
}
