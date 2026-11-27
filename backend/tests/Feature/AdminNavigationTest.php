<?php

use App\Enums\UserRole;
use App\Models\User;
use Filament\Facades\Filament;

beforeEach(fn () => Filament::setCurrentPanel('admin'));

it('shows each role only its pages', function (UserRole $role, array $see, array $dontSee) {
    $response = $this->actingAs(User::factory()->role($role)->create())->get('/admin');

    $response->assertOk();
    foreach ($see as $label) {
        $response->assertSeeText($label);
    }
    foreach ($dontSee as $label) {
        $response->assertDontSeeText($label);
    }
})->with([
    'barista' => [UserRole::Barista, ['Orders board', 'Counter points', 'Products'], ['Promo codes', 'Customers', 'Shop settings', 'Reports', 'Staff']],
    'manager' => [UserRole::Manager, ['Orders board', 'Counter points', 'Promo codes', 'Customers', 'Orders', 'Shop settings', 'Reports'], ['Staff']],
    'owner' => [UserRole::Owner, ['Shop settings', 'Reports', 'Staff'], []],
]);
