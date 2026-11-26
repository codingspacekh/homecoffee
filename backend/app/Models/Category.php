<?php

namespace App\Models;

use App\Models\Concerns\HasTranslatedFields;
use App\Support\MenuCache;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['slug', 'name', 'sort'])]
class Category extends Model
{
    use HasFactory, HasTranslatedFields;

    protected function casts(): array
    {
        return [
            'name' => 'array',
            'sort' => 'integer',
        ];
    }

    protected static function booted(): void
    {
        static::saved(fn () => MenuCache::forget());
        static::deleted(fn () => MenuCache::forget());
    }

    /** @return HasMany<Product, $this> */
    public function products(): HasMany
    {
        return $this->hasMany(Product::class)->orderBy('sort')->orderBy('id');
    }

    /** The category as the app reads it from GET /api/v1/menu. */
    public function toMenuArray(): array
    {
        return array_filter([
            'id' => $this->id,
            'name' => $this->translated('name'),
            'translations' => $this->translationsFor(['name']) ?: null,
            'products' => $this->products->map->toMenuArray()->all(),
        ], fn ($value) => $value !== null);
    }
}
