<?php

namespace Database\Seeders;

use App\Domain\Money;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

/**
 * Imports the website's data/menu.json (a copy lives in database/seeders/menu)
 * with its photos. Safe to run again: it updates by id instead of duplicating.
 */
class MenuSeeder extends Seeder
{
    /** Khmer option names from the website's I18n.js. */
    private const KHMER = [
        'Size' => 'ទំហំ',
        'Milk' => 'ទឹកដោះគោ',
        'Extra shot' => 'បន្ថែមអេសប្រេសូ',
        'Small' => 'តូច',
        'Medium' => 'មធ្យម',
        'Large' => 'ធំ',
        'None' => 'គ្មាន',
        'Whole' => 'ទឹកដោះគោស្រស់',
        'Skim' => 'ទឹកដោះគោគ្មានខ្លាញ់',
        'Oat' => 'ទឹកដោះអូត',
        'Almond' => 'ទឹកដោះអាល់ម៉ុន',
        'No' => 'មិនបន្ថែម',
        'Yes' => 'បន្ថែម',
    ];

    public function run(): void
    {
        $menu = json_decode(file_get_contents(__DIR__.'/menu/menu.json'), true, flags: JSON_THROW_ON_ERROR);

        foreach ($menu as $categorySort => $categoryData) {
            $category = Category::query()->updateOrCreate(
                ['slug' => Str::slug($categoryData['name'])],
                [
                    // "HOT COFFEE" becomes "Hot coffee": sentence case, as in the app design.
                    'name' => $this->translations(Str::ucfirst(Str::lower($categoryData['name'])), $categoryData['translations']['km']['name'] ?? null),
                    'sort' => $categorySort,
                ],
            );

            foreach ($categoryData['products'] as $productSort => $data) {
                Product::query()->updateOrCreate(['id' => $data['id']], [
                    'category_id' => $category->id,
                    'name' => $this->translations($data['name'], $data['translations']['km']['name'] ?? null),
                    'description' => $this->translations($data['description'] ?? '', $data['translations']['km']['description'] ?? null),
                    'price_cents' => Money::fromDollars($data['price']),
                    'drink' => $data['drink'] ?? false,
                    'image_path' => $this->storeImage($data['image'] ?? null),
                    'options' => array_map(fn (array $group) => [
                        'name' => $this->translations($group['name'], self::KHMER[$group['name']] ?? null),
                        'choices' => array_map(fn (array $choice) => [
                            'label' => $this->translations($choice['label'], self::KHMER[$choice['label']] ?? null),
                            'price_cents' => Money::fromDollars($choice['price'] ?? 0),
                        ], $group['choices']),
                    ], $data['options'] ?? []),
                    'sort' => $productSort,
                ]);
            }
        }
    }

    /** @return array{en: string, km?: string} */
    private function translations(string $english, ?string $khmer): array
    {
        return array_filter(['en' => $english, 'km' => $khmer], fn ($value) => $value !== null);
    }

    private function storeImage(?string $file): ?string
    {
        $source = $file ? __DIR__.'/menu/images/'.pathinfo($file, PATHINFO_FILENAME).'.webp' : null;
        if ($source === null || ! is_file($source)) {
            return null;
        }
        $path = 'products/'.basename($source);
        Storage::disk('public')->put($path, file_get_contents($source));

        return $path;
    }
}
