<?php

use App\Enums\OrderStatus;
use App\Enums\PointReason;
use App\Filament\Resources\Customers\Pages\ListCustomers;
use App\Filament\Resources\Customers\Pages\ViewCustomer;
use App\Filament\Resources\Customers\RelationManagers\OrdersRelationManager;
use App\Filament\Resources\Customers\RelationManagers\PointEntriesRelationManager;
use App\Filament\Resources\Orders\Pages\ListOrders;
use App\Filament\Resources\Orders\Pages\ViewOrder;
use App\Models\User;
use Filament\Actions\Testing\TestAction;
use Filament\Facades\Filament;
use Illuminate\Support\Carbon;

use function Pest\Livewire\livewire;

beforeEach(function () {
    Filament::setCurrentPanel('admin');
    $this->travelTo(Carbon::parse('2026-12-02 09:00', 'Asia/Phnom_Penh'));
    $this->manager = User::factory()->manager()->create(['name' => 'Mony']);
    $this->actingAs($this->manager);
});

describe('orders', function () {
    it('lists every order, newest first, and finds one by number, name or phone', function () {
        $dara = makeOrder(['customer_name' => 'Dara', 'customer_phone' => '012 111 222']);
        $sokha = makeOrder(['customer_name' => 'Sokha', 'customer_phone' => '097 333 444', 'status' => OrderStatus::Collected]);

        livewire(ListOrders::class)
            ->assertCanSeeTableRecords([$sokha, $dara], inOrder: true)
            ->searchTable("#{$dara->number()}")->assertCanSeeTableRecords([$dara])->assertCanNotSeeTableRecords([$sokha])
            ->searchTable('Sokha')->assertCanSeeTableRecords([$sokha])->assertCanNotSeeTableRecords([$dara])
            ->searchTable('333')->assertCanSeeTableRecords([$sokha]);
    });

    it('filters by status and by day in the shop\'s time zone', function () {
        $today = makeOrder();
        $cancelled = makeOrder(['status' => OrderStatus::Cancelled]);
        $this->travelTo(Carbon::parse('2026-12-01 23:30', 'Asia/Phnom_Penh'));
        $yesterday = makeOrder();
        $this->travelBack();

        livewire(ListOrders::class)
            ->filterTable('status', ['cancelled'])->assertCanSeeTableRecords([$cancelled])->assertCanNotSeeTableRecords([$today, $yesterday])
            ->resetTableFilters()
            ->filterTable('day', ['day' => '2026-12-01'])->assertCanSeeTableRecords([$yesterday])->assertCanNotSeeTableRecords([$today, $cancelled]);
    });

    it('shows the lines and cancels an open order with a reason', function () {
        $order = makeOrder(['status' => OrderStatus::Preparing]);

        livewire(ViewOrder::class, ['record' => $order->id])
            ->assertSeeText('1 × Cappuccino')
            ->assertSeeText('Note: extra hot')
            ->callAction('cancel', ['reason' => 'Machine broke'])
            ->assertNotified("Order #{$order->number()} cancelled");

        expect($order->refresh())->status->toBe(OrderStatus::Cancelled)->cancel_reason->toBe('Machine broke');
    });

    it('offers cancel only on open orders', function () {
        $done = makeOrder(['status' => OrderStatus::Collected]);

        livewire(ListOrders::class)->assertActionHidden(TestAction::make('cancel')->table($done));
    });
});

describe('customers', function () {
    it('lists customers, not staff, and finds one by phone or member code', function () {
        $dara = User::factory()->create(['name' => 'Dara', 'phone' => '012 111 222']);
        $sokha = User::factory()->create(['name' => 'Sokha']);
        $barista = User::factory()->barista()->create();

        livewire(ListCustomers::class)
            ->assertCanSeeTableRecords([$dara, $sokha])
            ->assertCanNotSeeTableRecords([$barista, $this->manager])
            ->searchTable('111')->assertCanSeeTableRecords([$dara])->assertCanNotSeeTableRecords([$sokha])
            ->searchTable($sokha->member_code)->assertCanSeeTableRecords([$sokha]);
    });

    it('shows a customer\'s points history and orders', function () {
        $dara = User::factory()->create(['name' => 'Dara']);
        $order = makeOrder([], $dara);
        $dara->pointEntries()->create(['order_id' => $order->id, 'change' => 5, 'reason' => PointReason::Order]);

        livewire(PointEntriesRelationManager::class, ['ownerRecord' => $dara, 'pageClass' => ViewCustomer::class])
            ->assertSeeText('App order')->assertSeeText('+5')->assertSeeText("Order #{$order->number()}");
        livewire(OrdersRelationManager::class, ['ownerRecord' => $dara, 'pageClass' => ViewCustomer::class])
            ->assertCanSeeTableRecords([$order]);
    });

    it('adjusts points with a note, and never below zero', function () {
        $dara = User::factory()->create(['name' => 'Dara']);
        $dara->forceFill(['points' => 8])->save();

        livewire(ViewCustomer::class, ['record' => $dara->id])
            ->callAction('adjustPoints', ['change' => 12, 'note' => 'Missed on order #1042'])
            ->assertNotified('Dara now has 20 points');

        livewire(ViewCustomer::class, ['record' => $dara->id])
            ->callAction('adjustPoints', ['change' => -25, 'note' => 'Oops'])
            ->assertNotified('Dara has only 20 points');

        $entry = $dara->pointEntries()->sole();
        expect($dara->refresh()->points)->toBe(20)
            ->and($entry)->reason->toBe(PointReason::Adjustment)->note->toBe('Missed on order #1042')->staff_id->toBe($this->manager->id);
    });

    it('does not show the note to the customer', function () {
        $dara = User::factory()->create();
        $dara->pointEntries()->create(['change' => 3, 'reason' => PointReason::Adjustment, 'note' => 'Internal', 'staff_id' => $this->manager->id]);

        $this->actingAs($dara, 'sanctum')->getJson('/api/v1/me/points')
            ->assertOk()
            ->assertJsonPath('data.0.reason', 'adjustment')
            ->assertJsonMissingPath('data.0.note');
    });
});

it('keeps baristas out of orders and customers', function (string $url) {
    $this->actingAs(User::factory()->barista()->create())->get($url)->assertForbidden();
})->with(['/admin/orders', '/admin/customers']);
