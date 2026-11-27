<?php

use App\Enums\OrderStatus;
use App\Enums\UserRole;
use App\Filament\Pages\OrdersBoard;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Support\Carbon;

use function Pest\Livewire\livewire;

beforeEach(function () {
    Filament::setCurrentPanel('admin');
    $this->travelTo(Carbon::parse('2026-12-02 09:00', 'Asia/Phnom_Penh'));
    $this->actingAs(User::factory()->barista()->create());
});

it('opens for every staff role and not for customers', function (UserRole $role, int $status) {
    $this->actingAs(User::factory()->role($role)->create())
        ->get('/admin/board')
        ->assertStatus($status);
})->with([
    'barista' => [UserRole::Barista, 200],
    'manager' => [UserRole::Manager, 200],
    'owner' => [UserRole::Owner, 200],
    'customer' => [UserRole::Customer, 403],
]);

it('puts open orders in three columns, the soonest due first', function () {
    $later = makeOrder(['estimated_ready_at' => now()->addMinutes(40), 'customer_name' => 'Later']);
    $soon = makeOrder(['estimated_ready_at' => now()->addMinutes(5), 'customer_name' => 'Soon']);
    $making = makeOrder(['status' => OrderStatus::Preparing, 'preparing_at' => now()]);
    $ready = makeOrder(['status' => OrderStatus::Ready, 'ready_at' => now()]);
    makeOrder(['status' => OrderStatus::Collected]);
    makeOrder(['status' => OrderStatus::Cancelled]);

    $columns = livewire(OrdersBoard::class)->instance()->columns();

    expect($columns['received']->pluck('id')->all())->toBe([$soon->id, $later->id])
        ->and($columns['preparing']->pluck('id')->all())->toBe([$making->id])
        ->and($columns['ready']->pluck('id')->all())->toBe([$ready->id]);
});

it('shows what to make on each card', function () {
    $order = makeOrder(['customer_name' => 'Sokha', 'points_spent' => 50]);

    livewire(OrdersBoard::class)
        ->assertSeeText($order->number())
        ->assertSeeText('Sokha')
        ->assertSeeTextInOrder(['1 ×', 'Cappuccino'])
        ->assertSeeText('Large, Oat milk')
        ->assertSeeText('Note: extra hot')
        ->assertSeeText('Free drink')
        ->assertSeeText('Due 9:10 AM');
});

it('marks a card late once it is past due', function () {
    makeOrder(['estimated_ready_at' => now()->subMinutes(3)]);

    livewire(OrdersBoard::class)->assertSeeHtml('hc-card-warning hc-late')->assertSeeText('Late, was due 8:57 AM');
});

it('moves an order one step with each tap', function () {
    $order = makeOrder(['points_earned' => 5]);
    $board = livewire(OrdersBoard::class);

    $board->call('advance', $order->id, 'received');
    expect($order->refresh()->status)->toBe(OrderStatus::Preparing);

    $board->call('advance', $order->id, 'preparing');
    expect($order->refresh()->status)->toBe(OrderStatus::Ready);

    $board->call('advance', $order->id, 'ready');
    expect($order->refresh()->status)->toBe(OrderStatus::Collected)
        ->and($order->user->refresh()->points)->toBe(5);
});

it('does not skip a step when two tablets tap the same order', function () {
    $order = makeOrder();
    $first = livewire(OrdersBoard::class);
    $second = livewire(OrdersBoard::class);

    $first->call('advance', $order->id, 'received');
    $second->call('advance', $order->id, 'received')->assertNotified("Order #{$order->number()} was already moved");

    expect($order->refresh()->status)->toBe(OrderStatus::Preparing);
});

it('says so when the customer cancelled before the tap', function () {
    $order = makeOrder(['status' => OrderStatus::Cancelled]);

    livewire(OrdersBoard::class)
        ->call('advance', $order->id, 'received')
        ->assertNotified("Order #{$order->number()} was cancelled");
});

it('cancels an order with a reason the customer can read', function () {
    $order = makeOrder(['status' => OrderStatus::Preparing]);

    livewire(OrdersBoard::class)
        ->callAction('cancel', ['reason' => 'Out of oat milk'], ['order' => $order->id])
        ->assertHasNoFormErrors()
        ->assertNotified("Order #{$order->number()} cancelled");

    expect($order->refresh())
        ->status->toBe(OrderStatus::Cancelled)
        ->cancel_reason->toBe('Out of oat milk');
});

it('needs a reason to cancel', function () {
    $order = makeOrder();

    livewire(OrdersBoard::class)
        ->callAction('cancel', ['reason' => ''], ['order' => $order->id])
        ->assertHasFormErrors(['reason' => 'required']);

    expect($order->refresh()->status)->toBe(OrderStatus::Received);
});

it('chimes once when a new order comes in', function () {
    makeOrder();
    $board = livewire(OrdersBoard::class);

    $board->call('refreshBoard')->assertNotDispatched('new-order');

    makeOrder();
    $board->call('refreshBoard')->assertDispatched('new-order');
    $board->call('refreshBoard')->assertNotDispatched('new-order');
});

it('counts new orders on the menu badge', function () {
    makeOrder();
    makeOrder();
    makeOrder(['status' => OrderStatus::Preparing]);

    expect(OrdersBoard::getNavigationBadge())->toBe('2');
});
