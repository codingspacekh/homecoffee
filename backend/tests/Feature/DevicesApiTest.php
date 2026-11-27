<?php

use App\Models\Device;
use App\Models\User;
use Laravel\Sanctum\Sanctum;

beforeEach(function () {
    $this->customer = User::factory()->create();
    Sanctum::actingAs($this->customer);
});

it('saves the phone that turned on order alerts', function () {
    $this->postJson('/api/v1/me/devices', ['token' => 'fcm-token-a', 'platform' => 'android'])
        ->assertCreated()
        ->assertJson(['saved' => true]);

    expect($this->customer->devices()->pluck('token')->all())->toBe(['fcm-token-a']);
});

it('keeps one row per phone when the app saves it again', function () {
    $this->postJson('/api/v1/me/devices', ['token' => 'fcm-token-a', 'platform' => 'android']);
    $this->postJson('/api/v1/me/devices', ['token' => 'fcm-token-a', 'platform' => 'android']);

    expect(Device::count())->toBe(1);
});

it('moves a phone to whoever signed in on it last', function () {
    $this->postJson('/api/v1/me/devices', ['token' => 'shared-phone', 'platform' => 'ios']);

    $next = User::factory()->create();
    Sanctum::actingAs($next);
    $this->postJson('/api/v1/me/devices', ['token' => 'shared-phone', 'platform' => 'ios'])->assertCreated();

    expect(Device::sole()->user_id)->toBe($next->id)
        ->and($this->customer->devices()->count())->toBe(0);
});

it('checks the token and platform', function () {
    $this->postJson('/api/v1/me/devices', ['token' => '', 'platform' => 'windows'])
        ->assertUnprocessable()
        ->assertJsonValidationErrors(['token', 'platform']);
});

it('forgets a phone when alerts are turned off or the customer signs out', function () {
    $this->customer->devices()->create(['token' => 'fcm-token-a', 'platform' => 'android']);
    $this->customer->devices()->create(['token' => 'fcm-token-b', 'platform' => 'ios']);

    $this->deleteJson('/api/v1/me/devices', ['token' => 'fcm-token-a'])
        ->assertOk()
        ->assertJson(['deleted' => true]);

    expect($this->customer->devices()->pluck('token')->all())->toBe(['fcm-token-b']);
});

it('does not let one customer remove another customer\'s phone', function () {
    $other = User::factory()->create();
    $other->devices()->create(['token' => 'not-mine', 'platform' => 'android']);

    $this->deleteJson('/api/v1/me/devices', ['token' => 'not-mine'])->assertOk();

    expect($other->devices()->count())->toBe(1);
});

it('removes the phones with the account', function () {
    $this->customer->devices()->create(['token' => 'fcm-token-a', 'platform' => 'android']);

    $this->deleteJson('/api/v1/me')->assertSuccessful();

    expect(Device::count())->toBe(0);
});

it('needs a signed in customer', function () {
    app('auth')->forgetGuards();

    $this->postJson('/api/v1/me/devices', ['token' => 'x', 'platform' => 'ios'])->assertUnauthorized();
});
