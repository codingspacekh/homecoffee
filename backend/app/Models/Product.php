<?php

namespace App\Models;

use App\Domain\Product as DomainProduct;
use App\Models\Concerns\HasTranslatedFields;
use App\Support\MenuCache;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

/**
 * Options are stored as a list of groups, the first choice being the default:
 * [{"name": {"en": "Size", "km": "ទំហំ"},
 *   "choices": [{"label": {"en": "Small", "km": "តូច"}, "price_cents": 0}, ...]}]
 */
#[Fillable(['category_id', 'name', 'description', 'price_cents', 'drink', 'image_path', 'options', 'available', 'sort'])]
class Product extends Model
{
    use HasFactory, HasTranslatedFields;

    protected $attributes = [
        'available' => true,
        'drink' => false,
    ];

    protected function casts(): array
    {
        return [
            'name' => 'array',
            'description' => 'array',
            'options' => 'array',
            'price_cents' => 'integer',
            'drink' => 'boolean',
            'available' => 'boolean',
            'sort' => 'integer',
        ];
    }

    protected static function booted(): void
    {
        static::saved(fn () => MenuCache::forget());
        static::deleted(fn () => MenuCache::forget());
    }

    /** @return BelongsTo<Category, $this> */
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function imageUrl(): ?string
    {
        return $this->image_path ? Storage::disk('public')->url($this->image_path) : null;
    }

    /** The product as the app reads it from GET /api/v1/menu. Prices in cents. */
    public function toMenuArray(): array
    {
        return array_filter([
            'id' => $this->id,
            'name' => $this->translated('name'),
            'description' => $this->translated('description') ?? '',
            'price_cents' => $this->price_cents,
            'drink' => $this->drink,
            'available' => $this->available,
            'image_url' => $this->imageUrl(),
            'options' => array_map(fn (array $group) => array_filter([
                'name' => $group['name']['en'],
                'translations' => filled($group['name']['km'] ?? null) ? ['km' => ['name' => $group['name']['km']]] : null,
                'choices' => array_map(fn (array $choice) => array_filter([
                    'label' => $choice['label']['en'],
                    'price_cents' => (int) ($choice['price_cents'] ?? 0),
                    'translations' => filled($choice['label']['km'] ?? null) ? ['km' => ['label' => $choice['label']['km']]] : null,
                ], fn ($value) => $value !== null), $group['choices']),
            ], fn ($value) => $value !== null), $this->options ?? []),
            'translations' => $this->translationsFor(['name', 'description']) ?: null,
        ], fn ($value) => $value !== null);
    }

    /** What the price rules need, for quotes and orders on the server. */
    public function toDomain(): DomainProduct
    {
        return DomainProduct::fromArray($this->toMenuArray());
    }
}
