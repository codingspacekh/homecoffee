<?php

use App\Domain\Options;
use App\Models\Category;
use App\Models\Product;
use App\Models\StoreSetting;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Storage;

beforeEach(function () {
    Storage::fake('public');
    $this->seed(DatabaseSeeder::class);
});

it('imports the website menu with prices in cents and Khmer names', function () {
    expect(Category::count())->toBe(4)
        ->and(Product::count())->toBe(11);

    $cappuccino = Product::find(12);
    expect($cappuccino->price_cents)->toBe(375)
        ->and($cappuccino->translated('name', 'km'))->toBe('កាពូឈីណូ')
        ->and($cappuccino->options[0]['choices'][2])->toBe(['label' => ['en' => 'Large', 'km' => 'ធំ'], 'price_cents' => 100]);
    Storage::disk('public')->assertExists('products/cappuccino.webp');
});

it('can run the seeder twice without duplicates', function () {
    $this->seed(DatabaseSeeder::class);

    expect(Product::count())->toBe(11)->and(Category::count())->toBe(4);
});

it('serves the menu in the app format', function () {
    $response = $this->getJson('/api/v1/menu')->assertOk();

    expect($response->json('categories.0'))
        ->toMatchArray(['name' => 'Hot coffee', 'translations' => ['km' => ['name' => 'កាហ្វេក្តៅ']]])
        ->and($response->json('categories.0.products.1'))->toMatchArray([
            'id' => 12,
            'name' => 'Cappuccino',
            'price_cents' => 375,
            'drink' => true,
            'available' => true,
        ])
        ->and($response->json('categories.0.products.1.options.0'))->toBe([
            'name' => 'Size',
            'translations' => ['km' => ['name' => 'ទំហំ']],
            'choices' => [
                ['label' => 'Small', 'price_cents' => 0, 'translations' => ['km' => ['label' => 'តូច']]],
                ['label' => 'Medium', 'price_cents' => 50, 'translations' => ['km' => ['label' => 'មធ្យម']]],
                ['label' => 'Large', 'price_cents' => 100, 'translations' => ['km' => ['label' => 'ធំ']]],
            ],
        ])
        ->and($response->json('categories.3.products.0.image_url'))->toEndWith('/storage/products/croissant.webp');
});

it('answers 304 when the app already has this menu, and a new ETag after an edit', function () {
    $etag = $this->get('/api/v1/menu')->headers->get('ETag');

    $this->withHeaders(['If-None-Match' => $etag])->get('/api/v1/menu')->assertStatus(304);

    Product::find(12)->update(['available' => false]);

    $fresh = $this->withHeaders(['If-None-Match' => $etag])->get('/api/v1/menu')->assertOk();
    expect($fresh->headers->get('ETag'))->not->toBe($etag)
        ->and($fresh->json('categories.0.products.1.available'))->toBeFalse();
});

it('keeps sold out products on the menu', function () {
    Product::find(41)->update(['available' => false]);

    $this->getJson('/api/v1/menu')
        ->assertJsonPath('categories.3.products.0.id', 41)
        ->assertJsonPath('categories.3.products.0.available', false);
});

it('prices server orders with the same rules as the app', function () {
    $cappuccino = Product::find(12)->toDomain();

    expect(Options::line($cappuccino, ['Size' => 'Large', 'Milk' => 'Oat', 'Extra shot' => 'Yes'])->unitCents)
        ->toBe(375 + 100 + 60 + 80);
});

it('tells the app the opening hours and whether it can order now', function () {
    Carbon::setTestNow(Carbon::parse('2026-12-01 09:30', 'Asia/Phnom_Penh'));
    $this->getJson('/api/v1/store')
        ->assertOk()
        ->assertJson(['prep_minutes' => 7, 'accepting_orders' => true, 'open_now' => true, 'can_order_now' => true]);

    Carbon::setTestNow(Carbon::parse('2026-12-01 18:00', 'Asia/Phnom_Penh'));
    $this->getJson('/api/v1/store')->assertJson(['open_now' => false, 'can_order_now' => false]);

    Carbon::setTestNow(Carbon::parse('2026-12-01 10:00', 'Asia/Phnom_Penh'));
    StoreSetting::current()->update(['accepting_orders' => false]);
    $this->getJson('/api/v1/store')->assertJson(['open_now' => true, 'can_order_now' => false]);
});

it('limits how often one phone can call the API', function () {
    foreach (range(1, 120) as $i) {
        $this->get('/api/v1/store');
    }

    $this->get('/api/v1/store')->assertStatus(429);
});
