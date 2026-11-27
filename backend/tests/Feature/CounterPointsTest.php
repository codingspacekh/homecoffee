<?php

use App\Enums\PointReason;
use App\Filament\Pages\CounterPoints;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Support\Carbon;

use function Pest\Livewire\livewire;

beforeEach(function () {
    Filament::setCurrentPanel('admin');
    $this->travelTo(Carbon::parse('2026-12-02 09:00', 'Asia/Phnom_Penh'));
    $this->barista = User::factory()->barista()->create(['name' => 'Vanna']);
    $this->actingAs($this->barista);
    $this->dara = User::factory()->create(['name' => 'Dara', 'phone' => '012 345 678', 'points' => 12]);
});

it('opens for baristas but not for customers', function () {
    $this->get(CounterPoints::getUrl())->assertOk()->assertSee('Counter points');

    $this->actingAs($this->dara)->get(CounterPoints::getUrl())->assertForbidden();
});

it('finds a member by the QR text, the typed code with a space, the phone or the email', function (string $lookup) {
    $lookup = str_replace('{code}', $this->dara->member_code, $lookup);
    $lookup = str_replace('{label}', $this->dara->memberCodeLabel(), $lookup);

    livewire(CounterPoints::class)
        ->set('lookup', $lookup)->call('find')
        ->assertHasNoErrors()
        ->assertSet('customerId', $this->dara->id)
        ->assertSee('Dara');
})->with([
    'QR text' => 'homecoffee:member:{code}',
    'typed code' => '{label}',
    'phone without spaces' => '012345678',
    'phone with dashes' => '012-345-678',
]);

it('finds a member by email, ignoring case', function () {
    livewire(CounterPoints::class)
        ->set('lookup', strtoupper($this->dara->email))->call('find')
        ->assertSet('customerId', $this->dara->id);
});

it('says so when nobody matches, and never finds staff', function () {
    livewire(CounterPoints::class)
        ->set('lookup', '099 999 999')->call('find')
        ->assertHasErrors('lookup')
        ->assertSet('customerId', null)
        ->set('lookup', $this->barista->member_code)->call('find')
        ->assertHasErrors('lookup');
});

it('lets the barista choose when two accounts share a phone', function () {
    $sister = User::factory()->create(['name' => 'Dara\'s sister', 'phone' => '012345678']);

    livewire(CounterPoints::class)
        ->set('lookup', '012 345 678')->call('find')
        ->assertSet('customerId', null)
        ->assertSet('matches', [$this->dara->id, $sister->id])
        ->call('pick', $sister->id)
        ->assertSet('customerId', $sister->id)
        ->assertSet('matches', []);
});

it('adds a point per whole dollar paid and records who did it', function () {
    livewire(CounterPoints::class)
        ->call('scanned', $this->dara->member_code)
        ->set('amount', '12.50')
        ->call('addPoints')
        ->assertHasNoErrors()
        ->assertNotified('+12 points for Dara')
        ->assertSet('customerId', null)
        ->assertDontSee('Amount paid')
        ->assertSee('Paid $12.50');

    expect($this->dara->fresh()->points)->toBe(24)
        ->and($this->dara->pointEntries()->sole())
        ->change->toBe(12)
        ->reason->toBe(PointReason::Counter)
        ->staff_id->toBe($this->barista->id)
        ->note->toBe('Paid $12.50');
});

it('refuses amounts under a dollar or over $500', function (string $amount) {
    livewire(CounterPoints::class)
        ->call('pick', $this->dara->id)
        ->set('amount', $amount)
        ->call('addPoints')
        ->assertHasErrors('amount')
        ->assertSet('customerId', $this->dara->id);

    expect($this->dara->fresh()->points)->toBe(12)
        ->and($this->dara->pointEntries()->count())->toBe(0);
})->with(['0.80', '0', '-5', '500.01', 'abc', '']);

it('gives a free drink for 50 points', function () {
    $this->dara->forceFill(['points' => 57])->save();

    livewire(CounterPoints::class)
        ->call('pick', $this->dara->id)
        ->call('giveFreeDrink')
        ->assertNotified('Free drink for Dara')
        ->assertDontSee('Amount paid');

    expect($this->dara->fresh()->points)->toBe(7)
        ->and($this->dara->pointEntries()->sole())
        ->change->toBe(-50)
        ->reason->toBe(PointReason::Reward);
});

it('won\'t give a free drink without 50 points', function () {
    livewire(CounterPoints::class)
        ->call('pick', $this->dara->id)
        ->call('giveFreeDrink')
        ->assertNotified('Dara needs 50 points for a free drink');

    expect($this->dara->fresh()->points)->toBe(12)
        ->and($this->dara->pointEntries()->count())->toBe(0);
});

it('lists today\'s counter points, not yesterday\'s or the app\'s', function () {
    $this->travelTo(Carbon::parse('2026-12-01 23:50', 'Asia/Phnom_Penh'));
    livewire(CounterPoints::class)->call('pick', $this->dara->id)->set('amount', '7')->call('addPoints');
    $this->travelTo(Carbon::parse('2026-12-02 08:10', 'Asia/Phnom_Penh'));
    livewire(CounterPoints::class)->call('pick', $this->dara->id)->set('amount', '3.25')->call('addPoints');
    $this->dara->pointEntries()->create(['change' => 9, 'reason' => PointReason::Order]);

    livewire(CounterPoints::class)
        ->assertSee('Paid $3.25')
        ->assertDontSee('Paid $7.00');
});
