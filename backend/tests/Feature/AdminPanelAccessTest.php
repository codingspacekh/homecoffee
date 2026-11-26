<?php

use App\Enums\UserRole;
use App\Models\User;

it('sends guests to the admin sign-in page', function () {
    $this->get('/admin')->assertRedirect('/admin/login');
});

it('keeps customers out of the admin panel', function () {
    $this->actingAs(User::factory()->create())
        ->get('/admin')
        ->assertForbidden();
});

it('lets staff into the admin panel', function (UserRole $role) {
    $this->actingAs(User::factory()->role($role)->create())
        ->get('/admin')
        ->assertOk()
        ->assertSee('HomeCoffee');
})->with([UserRole::Barista, UserRole::Manager, UserRole::Owner]);

it('makes new accounts customers', function () {
    expect(User::factory()->create()->refresh()->role)->toBe(UserRole::Customer);
});

it('does not let a role be mass assigned', function () {
    $user = new User(['name' => 'A', 'email' => 'a@example.com', 'password' => 'secret-password', 'role' => 'owner']);

    expect($user->role)->toBe(UserRole::Customer);
});

it('creates the owner from the command line', function () {
    $this->artisan('homecoffee:owner', ['email' => 'owner@example.com'])
        ->expectsQuestion('Password (at least 12 characters)', 'a-long-password')
        ->assertSuccessful();

    expect(User::firstWhere('email', 'owner@example.com')->role)->toBe(UserRole::Owner);
});
