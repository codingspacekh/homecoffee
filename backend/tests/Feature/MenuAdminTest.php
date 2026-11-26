<?php

use App\Filament\Resources\Categories\Pages\ListCategories;
use App\Filament\Resources\Products\Pages\CreateProduct;
use App\Filament\Resources\Products\Pages\EditProduct;
use App\Filament\Resources\Products\Pages\ListProducts;
use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Database\Seeders\MenuSeeder;
use Filament\Facades\Filament;
use Illuminate\Support\Facades\Storage;

use function Pest\Livewire\livewire;

beforeEach(function () {
    Storage::fake('public');
    $this->seed(MenuSeeder::class);
    Filament::setCurrentPanel('admin');
});

it('lets a manager edit a price in dollars and stores cents', function () {
    $this->actingAs(User::factory()->manager()->create());

    livewire(EditProduct::class, ['record' => 12])
        ->assertSchemaStateSet(['price_cents' => '3.75'])
        ->fillForm(['price_cents' => '4.10', 'name.km' => 'កាពូឈីណូ'])
        ->call('save')
        ->assertHasNoFormErrors();

    expect(Product::find(12)->price_cents)->toBe(410);
});

it('lets a manager add a product with options in English and Khmer', function () {
    $this->actingAs(User::factory()->owner()->create());

    livewire(CreateProduct::class)
        ->fillForm([
            'name' => ['en' => 'Iced latte', 'km' => 'ឡាតេទឹកកក'],
            'description' => ['en' => 'Espresso, cold milk and ice.'],
            'category_id' => Category::firstWhere('slug', 'iced-coffee')->id,
            'price_cents' => '3.50',
            'drink' => true,
            'options' => [
                ['name' => ['en' => 'Size', 'km' => 'ទំហំ'], 'choices' => [
                    ['label' => ['en' => 'Small'], 'price_cents' => '0'],
                    ['label' => ['en' => 'Large'], 'price_cents' => '1.00'],
                ]],
            ],
        ])
        ->call('create')
        ->assertHasNoFormErrors();

    $latte = Product::query()->where('name->en', 'Iced latte')->firstOrFail();
    expect($latte->price_cents)->toBe(350)
        ->and(array_values($latte->options)[0]['name'])->toBe(['en' => 'Size', 'km' => 'ទំហំ'])
        ->and(array_column(array_values(array_values($latte->options)[0]['choices']), 'price_cents'))->toBe([0, 100]);
    $this->getJson('/api/v1/menu')->assertJsonFragment(['name' => 'Iced latte', 'price_cents' => 350]);
});

it('lets a barista see products and mark one sold out, but not edit it', function () {
    $barista = User::factory()->barista()->create();
    $this->actingAs($barista);

    livewire(ListProducts::class)
        ->assertCanSeeTableRecords(Product::all())
        ->call('updateTableColumnState', 'available', '41', false);

    expect(Product::find(41)->available)->toBeFalse()
        ->and($barista->can('update', Product::find(41)))->toBeFalse()
        ->and($barista->can('viewAny', Category::class))->toBeFalse();
    $this->get('/admin/products/12/edit')->assertForbidden();
    $this->get('/admin/categories')->assertForbidden();
});

it('lists categories in menu order for managers', function () {
    $this->actingAs(User::factory()->manager()->create());

    livewire(ListCategories::class)
        ->assertCanSeeTableRecords(Category::orderBy('sort')->get(), inOrder: true);
});

it('does not delete a category that still has products', function () {
    $manager = User::factory()->manager()->create();

    expect($manager->can('delete', Category::first()))->toBeFalse()
        ->and($manager->can('delete', Category::create(['slug' => 'empty', 'name' => ['en' => 'Empty']])))->toBeTrue();
});
