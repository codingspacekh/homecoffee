<?php

use App\Filament\Pages\ShopSettings;
use App\Models\StoreSetting;
use App\Models\User;
use Filament\Facades\Filament;

use function Pest\Livewire\livewire;

beforeEach(function () {
    Filament::setCurrentPanel('admin');
    $this->actingAs(User::factory()->manager()->create());
});

it('is for managers and the owner, not baristas', function () {
    $this->get(ShopSettings::getUrl())->assertOk()->assertSee('Opening hours');

    $this->actingAs(User::factory()->barista()->create())->get(ShopSettings::getUrl())->assertForbidden();
});

it('shows the current settings', function () {
    $store = StoreSetting::current();
    $store->update(['prep_minutes' => 9, 'opening_hours' => [...$store->opening_hours, 'sun' => null]]);

    livewire(ShopSettings::class)->assertSchemaStateSet([
        'prep_minutes' => 9,
        'accepting_orders' => true,
        'days.mon.open_day' => true,
        'days.mon.open' => '07:00',
        'days.sun.open_day' => false,
    ]);
});

it('saves hours, closed days, prep time and the pause switch', function () {
    livewire(ShopSettings::class)
        ->fillForm([
            'accepting_orders' => false,
            'prep_minutes' => 12,
            'days.mon.open' => '06:30',
            'days.mon.close' => '17:00',
            'days.sun.open_day' => false,
        ])
        ->call('save')
        ->assertHasNoFormErrors()
        ->assertNotified('Settings saved');

    $store = StoreSetting::current();
    expect($store->accepting_orders)->toBeFalse()
        ->and($store->prep_minutes)->toBe(12)
        ->and($store->opening_hours['mon'])->toBe(['open' => '06:30', 'close' => '17:00'])
        ->and($store->opening_hours['tue'])->toBe(['open' => '07:00', 'close' => '18:00'])
        ->and($store->opening_hours['sun'])->toBeNull();

    $this->getJson('/api/v1/store')->assertJsonPath('accepting_orders', false)->assertJsonPath('opening_hours.sun', null);
});

it('refuses a closing time before the opening time, and silly prep times', function () {
    livewire(ShopSettings::class)
        ->fillForm(['days.wed.open' => '15:00', 'days.wed.close' => '09:00', 'prep_minutes' => 0])
        ->call('save')
        ->assertHasFormErrors(['days.wed.close' => 'after', 'prep_minutes' => 'min']);

    expect(StoreSetting::current()->opening_hours['wed'])->toBe(['open' => '07:00', 'close' => '18:00']);
});
