<?php

use App\Actions\CancelOrder;
use App\Actions\SetOrderStatus;
use App\Enums\OrderStatus;
use App\Enums\PointReason;
use App\Events\OrderStatusChanged;
use App\Models\Order;
use App\Models\Product;
use App\Models\StoreSetting;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Broadcasting\BroadcastManager;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Storage;
use Illuminate\Testing\TestResponse;
use Laravel\Sanctum\Sanctum;

beforeEach(function () {
    Storage::fake('public');
    $this->seed(DatabaseSeeder::class);
    // A Wednesday, 9 in the morning in Phnom Penh: the shop is open 7 to 6
    $this->travelTo(Carbon::parse('2026-12-02 09:00', 'Asia/Phnom_Penh'));
    $this->customer = User::factory()->create(['name' => null, 'phone' => null]);
    Sanctum::actingAs($this->customer);
});

function cart(array $overrides = []): array
{
    return [
        'lines' => [
            ['product_id' => 12, 'options' => ['Size' => 'Large', 'Milk' => 'Oat'], 'quantity' => 2, 'note' => ' extra hot '],
            ['product_id' => 41],
        ],
        ...$overrides,
    ];
}

function checkout(array $overrides = []): array
{
    return cart(['pickup_at' => 'asap', 'customer_name' => 'Dara', 'customer_phone' => '012 345 678', ...$overrides]);
}

function placeOrder(array $overrides = [], string $key = 'order-key-0001'): TestResponse
{
    return test()->withHeader('Idempotency-Key', $key)->postJson('/api/v1/orders', checkout($overrides));
}

function setPoints(User $user, int $points): void
{
    $user->forceFill(['points' => $points])->save();
}

describe('quote', function () {
    it('prices the cart from the products table', function () {
        $this->postJson('/api/v1/checkout/quote', cart(['promo_code' => ' welcome10 ']))
            ->assertOk()
            ->assertJson([
                'subtotal_cents' => 1350, // 2 x 5.35 + 2.80
                'discount_cents' => 0,
                'promo_code' => 'WELCOME10',
                'promo_cents' => 135,
                'total_cents' => 1215,
                'points_earned' => 12,
                'lines' => [
                    ['product_id' => 12, 'options' => ['Size' => 'Large', 'Milk' => 'Oat', 'Extra shot' => 'No'], 'note' => 'extra hot', 'unit_cents' => 535, 'line_cents' => 1070],
                    ['product_id' => 41, 'unit_cents' => 280],
                ],
            ]);
    });

    it('ignores any price the app sends', function () {
        $this->postJson('/api/v1/checkout/quote', ['lines' => [['product_id' => 41, 'unit_cents' => 1, 'price_cents' => 1]]])
            ->assertOk()->assertJsonPath('total_cents', 280);
    });

    it('agrees with every order case in fixtures/pricing.json', function (array $case) {
        setPoints($this->customer, $case['points']);

        $response = $this->postJson('/api/v1/checkout/quote', [
            'lines' => $case['lines'],
            'use_free_drink' => $case['use_reward'] && $case['points'] >= 50,
            'promo_code' => $case['promo_code'],
        ]);

        // A code that takes nothing off is a problem the app shows, not a silent zero
        if ($case['promo_code'] !== '' && $case['expected']['promo_amount'] === 0) {
            $response->assertStatus(422)->assertJsonPath('code', 'promo_minimum');

            return;
        }
        $response->assertOk()->assertJson([
            'subtotal_cents' => $case['expected']['subtotal'],
            'discount_cents' => $case['expected']['discount'],
            'promo_cents' => $case['expected']['promo_amount'],
            'total_cents' => $case['expected']['total'],
            'points_earned' => $case['expected']['points_earned'],
        ]);
    })->with(fn () => array_map(
        fn (array $case) => [$case],
        json_decode(file_get_contents(dirname(__DIR__, 3).'/fixtures/pricing.json'), true)['order_cases'],
    ));

    it('answers rule problems with a code the app translates', function (array $input, int $points, string $code) {
        setPoints($this->customer, $points);
        Product::find(42)->update(['available' => false]);

        $this->postJson('/api/v1/checkout/quote', $input)->assertStatus(422)->assertJsonPath('code', $code);
    })->with([
        'sold out' => [['lines' => [['product_id' => 42]]], 0, 'item_unavailable'],
        'not on the menu' => [['lines' => [['product_id' => 999]]], 0, 'item_unavailable'],
        'unknown promo' => [['lines' => [['product_id' => 41]], 'promo_code' => 'NOPE'], 0, 'promo_invalid'],
        'promo minimum' => [['lines' => [['product_id' => 41]], 'promo_code' => 'SAVE2'], 0, 'promo_minimum'],
        'not enough points' => [['lines' => [['product_id' => 12]], 'use_free_drink' => true], 49, 'not_enough_points'],
    ]);

    it('says which product is sold out and the promo minimum', function () {
        Product::find(42)->update(['available' => false]);
        $this->postJson('/api/v1/checkout/quote', ['lines' => [['product_id' => 41], ['product_id' => 42]]])
            ->assertJsonPath('product_id', 42);
        $this->postJson('/api/v1/checkout/quote', ['lines' => [['product_id' => 41]], 'promo_code' => 'save2'])
            ->assertJsonPath('minimum_cents', 1000);
    });
});

describe('placing an order', function () {
    it('saves the order with copies of names and prices', function () {
        $response = placeOrder(['promo_code' => 'WELCOME10'])->assertCreated();

        $order = Order::sole();
        expect($response->json())->toMatchArray([
            'id' => $order->id,
            'number' => 1000 + $order->id,
            'status' => 'received',
            'customer_name' => 'Dara',
            'total_cents' => 1215,
            'points_earned' => 12,
            'can_cancel' => true,
            'pickup_at' => null,
        ])->and($response->json('estimated_ready_at'))->toBe(now()->addMinutes(7)->toIso8601String())
            ->and($response->json('lines.0'))->toMatchArray([
                'product_id' => 12,
                'name' => 'Cappuccino',
                'choices' => 'Large, Oat',
                'note' => 'extra hot',
                'quantity' => 2,
                'line_cents' => 1070,
                'translations' => ['km' => ['name' => 'កាពូឈីណូ', 'choices' => 'ធំ, ទឹកដោះអូត']],
            ]);

        // A later price change never rewrites the receipt
        Product::find(12)->update(['price_cents' => 999]);
        $this->getJson("/api/v1/orders/{$order->id}")->assertJsonPath('lines.0.unit_cents', 535);
        expect($this->customer->refresh())->toMatchArray(['name' => 'Dara', 'phone' => '012 345 678', 'points' => 0]);
    });

    it('names a yes-or-no choice by its group on the receipt', function () {
        placeOrder(['lines' => [['product_id' => 14, 'options' => ['Extra shot' => 'Yes']]]])->assertCreated()
            ->assertJsonPath('lines.0.choices', 'Extra shot')
            ->assertJsonPath('lines.0.translations.km.choices', Product::find(14)->options[2]['name']['km']);
    });

    it('makes one order when the same request arrives twice', function () {
        $first = placeOrder()->assertCreated();
        $again = placeOrder()->assertOk();

        expect($again->json('id'))->toBe($first->json('id'))->and(Order::count())->toBe(1);
        placeOrder(key: 'order-key-0002')->assertCreated();
        expect(Order::count())->toBe(2);
    });

    it('needs an Idempotency-Key header', function () {
        $this->postJson('/api/v1/orders', checkout())->assertStatus(400)->assertJsonPath('code', 'idempotency_key_missing');
    });

    it('spends 50 points on the most expensive drink, once', function () {
        setPoints($this->customer, 60);

        placeOrder(['use_free_drink' => true])->assertCreated()
            ->assertJson(['discount_cents' => 535, 'points_spent' => 50, 'total_cents' => 815]);

        expect($this->customer->refresh()->points)->toBe(10)
            ->and($this->customer->pointEntries()->sole()->only('change', 'reason'))->toBe(['change' => -50, 'reason' => PointReason::Reward]);
        placeOrder(['use_free_drink' => true], 'order-key-0002')->assertStatus(422)->assertJsonPath('code', 'not_enough_points');
    });

    it('refuses orders when the shop is closed or paused', function () {
        $this->travelTo(Carbon::parse('2026-12-02 19:30', 'Asia/Phnom_Penh'));
        placeOrder()->assertStatus(422)->assertJsonPath('code', 'store_closed');

        $this->travelTo(Carbon::parse('2026-12-02 09:00', 'Asia/Phnom_Penh'));
        StoreSetting::current()->update(['accepting_orders' => false]);
        placeOrder()->assertStatus(422)->assertJsonPath('code', 'orders_paused');
    });

    it('takes a pickup time later today while the shop is open', function (string $time, ?string $code) {
        $response = placeOrder(['pickup_at' => Carbon::parse($time, 'Asia/Phnom_Penh')->toIso8601String()]);

        $code === null
            ? $response->assertCreated()->assertJsonPath('pickup_at', Carbon::parse($time, 'Asia/Phnom_Penh')->utc()->toIso8601String())
            : $response->assertStatus(422)->assertJsonPath('code', $code);
    })->with([
        'in an hour' => ['2026-12-02 10:00', null],
        'at closing time' => ['2026-12-02 18:00', null],
        'sooner than the prep time' => ['2026-12-02 09:03', 'pickup_outside_hours'],
        'after closing' => ['2026-12-02 18:30', 'pickup_outside_hours'],
        'tomorrow' => ['2026-12-03 10:00', 'pickup_outside_hours'],
        'in the past' => ['2026-12-02 08:00', 'pickup_outside_hours'],
    ]);

    it('allows an order before opening for a time after opening', function () {
        $this->travelTo(Carbon::parse('2026-12-02 06:30', 'Asia/Phnom_Penh'));

        placeOrder(['pickup_at' => '2026-12-02T07:30:00+07:00'])->assertCreated();
        placeOrder([], 'order-key-0002')->assertStatus(422)->assertJsonPath('code', 'store_closed');
    });

    it('checks the name and phone', function () {
        placeOrder(['customer_name' => '', 'customer_phone' => '12'])
            ->assertUnprocessable()->assertJsonValidationErrors(['customer_name', 'customer_phone']);
    });
});

describe('order history', function () {
    it('lists only my orders, newest first', function () {
        // Ids come from the responses: MySQL keeps counting across tests
        $first = placeOrder()->json('id');
        $second = placeOrder(key: 'order-key-0002')->json('id');
        $other = User::factory()->create();
        Sanctum::actingAs($other);
        $theirs = placeOrder(key: 'order-key-0003')->json('id');
        Sanctum::actingAs($this->customer);

        $response = $this->getJson('/api/v1/orders')->assertOk();

        expect(collect($response->json('data'))->pluck('id')->all())->toBe([$second, $first])
            ->and($response->json('next_page'))->toBeNull();
        $this->getJson("/api/v1/orders/{$theirs}")->assertForbidden();
        $this->postJson("/api/v1/orders/{$theirs}/cancel")->assertForbidden();
    });
});

describe('status and cancelling', function () {
    beforeEach(fn () => Event::fake([OrderStatusChanged::class]));

    it('lets the customer cancel until the barista starts, and gives points back', function () {
        setPoints($this->customer, 50);
        $id = placeOrder(['use_free_drink' => true])->json('id');

        $this->postJson("/api/v1/orders/{$id}/cancel")->assertOk()
            ->assertJson(['status' => 'cancelled', 'can_cancel' => false]);

        expect($this->customer->refresh()->points)->toBe(50)
            ->and($this->customer->pointEntries()->latest('id')->first()->reason)->toBe(PointReason::Refund);
        Event::assertDispatched(OrderStatusChanged::class, fn ($event) => $event->order->id === $id);
        $this->postJson("/api/v1/orders/{$id}/cancel")->assertStatus(422)->assertJsonPath('code', 'order_not_cancellable');
    });

    it('refuses to cancel once preparing', function () {
        $order = Order::find(placeOrder()->json('id'));
        app(SetOrderStatus::class)->handle($order, OrderStatus::Preparing);

        $this->postJson("/api/v1/orders/{$order->id}/cancel")->assertStatus(422)->assertJsonPath('code', 'order_not_cancellable');
        expect(app(CancelOrder::class)->handle($order, byCustomer: false, reason: 'Out of milk')->status)->toBe(OrderStatus::Cancelled);
    });

    it('moves forward one step at a time and awards points on collection', function () {
        $order = Order::find(placeOrder()->json('id'));
        $steps = app(SetOrderStatus::class);

        $steps->handle($order, OrderStatus::Preparing);
        $steps->handle($order, OrderStatus::Ready);
        expect(fn () => $steps->handle($order, OrderStatus::Preparing))->toThrow(DomainException::class);
        expect($this->customer->refresh()->points)->toBe(0);

        $steps->handle($order, OrderStatus::Collected);

        // $13.50 paid, so 13 points
        expect($this->customer->refresh()->points)->toBe(13)
            ->and($order->refresh()->collected_at)->not->toBeNull();
        Event::assertDispatchedTimes(OrderStatusChanged::class, 3);
        $this->getJson('/api/v1/me/points')->assertJson([
            'points' => 13,
            'data' => [['change' => 13, 'reason' => 'order', 'order_number' => $order->number()]],
        ]);
    });

    it('broadcasts on the private channel of that order only', function () {
        $order = Order::find(placeOrder()->json('id'));
        $event = new OrderStatusChanged($order);

        expect($event->broadcastOn()->name)->toBe("private-orders.{$order->id}")
            ->and($event->broadcastAs())->toBe('status')
            ->and($event->broadcastWith())->toMatchArray(['id' => $order->id, 'status' => 'received']);
    });
});

describe('live status channel', function () {
    beforeEach(function () {
        // Sign channel requests like Reverb would, with throwaway keys
        config([
            'broadcasting.connections.reverb.key' => 'test-key',
            'broadcasting.connections.reverb.secret' => 'test-secret',
            'broadcasting.connections.reverb.app_id' => 'test-app',
        ]);
        app(BroadcastManager::class)->setDefaultDriver('reverb');
        require base_path('routes/channels.php');
    });

    it('lets a customer join their own order channel and nobody else', function () {
        $id = placeOrder()->json('id');

        $this->postJson('/api/broadcasting/auth', ['socket_id' => '1234.5678', 'channel_name' => "private-orders.{$id}"])
            ->assertOk()->assertJsonStructure(['auth']);

        Sanctum::actingAs(User::factory()->create());
        $this->postJson('/api/broadcasting/auth', ['socket_id' => '1234.5678', 'channel_name' => "private-orders.{$id}"])
            ->assertForbidden();
    });
});
