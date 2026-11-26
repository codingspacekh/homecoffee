<?php

namespace App\Support;

use App\Models\Category;
use Illuminate\Support\Facades\Cache;

/**
 * The menu changes a few times a week and is read on every app start, so the
 * JSON is built once and kept until a category or product is saved.
 */
final class MenuCache
{
    private const KEY = 'api.v1.menu';

    /** @return array{json: string, etag: string} */
    public static function get(): array
    {
        return Cache::rememberForever(self::KEY, function () {
            $categories = Category::query()
                ->with('products')
                ->orderBy('sort')
                ->orderBy('id')
                ->get()
                ->map->toMenuArray()
                ->values()
                ->all();
            $json = json_encode(['categories' => $categories], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);

            return ['json' => $json, 'etag' => '"'.md5($json).'"'];
        });
    }

    public static function forget(): void
    {
        Cache::forget(self::KEY);
    }
}
