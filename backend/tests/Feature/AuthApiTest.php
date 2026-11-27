<?php

use App\Enums\UserRole;
use App\Mail\LoginCodeMail;
use App\Models\LoginCode;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;

beforeEach(function () {
    Mail::fake();
});

/** Asks for a code and returns the one that was emailed. */
function requestCode(string $email = 'dara@example.com'): string
{
    test()->postJson('/api/v1/auth/code', ['email' => $email, 'language' => 'km'])->assertStatus(202);
    $code = null;
    Mail::assertSent(LoginCodeMail::class, function (LoginCodeMail $mail) use (&$code) {
        $code = $mail->code;

        return true;
    });

    return $code;
}

it('emails a 6-digit code and keeps only its hash', function () {
    $code = requestCode('  Dara@Example.com ');

    expect($code)->toMatch('/^\d{6}$/');
    $saved = LoginCode::sole();
    expect($saved->email)->toBe('dara@example.com')
        ->and($saved->code_hash)->not->toContain($code);
    Mail::assertSent(LoginCodeMail::class, fn ($mail) => $mail->hasTo('dara@example.com') && $mail->language === 'km');
});

it('creates the account on the first right code and returns a token', function () {
    $code = requestCode();

    $response = $this->postJson('/api/v1/auth/verify', [
        'email' => 'dara@example.com', 'code' => $code, 'device_name' => 'Pixel 9', 'language' => 'km',
    ])->assertOk();

    expect($response->json('new_account'))->toBeTrue()
        ->and($response->json('user'))->toMatchArray(['email' => 'dara@example.com', 'language' => 'km', 'points' => 0])
        ->and(LoginCode::count())->toBe(0);
    $user = User::sole();
    expect($user->role)->toBe(UserRole::Customer)->and($user->email_verified_at)->not->toBeNull();

    $this->withToken($response->json('token'))->getJson('/api/v1/me')
        ->assertOk()->assertJsonPath('email', 'dara@example.com');
});

it('signs an existing customer back in without a second account', function () {
    $user = User::factory()->create(['email' => 'dara@example.com']);

    $response = $this->postJson('/api/v1/auth/verify', ['email' => 'dara@example.com', 'code' => requestCode()])->assertOk();

    expect($response->json('new_account'))->toBeFalse()
        ->and($response->json('user.id'))->toBe($user->id)
        ->and(User::count())->toBe(1);
});

it('refuses a wrong code, counts tries, and locks after five', function () {
    $code = requestCode();
    $wrong = $code === '000000' ? '111111' : '000000';

    $this->postJson('/api/v1/auth/verify', ['email' => 'dara@example.com', 'code' => $wrong])
        ->assertStatus(422)->assertJson(['code' => 'code_invalid', 'attempts_left' => 4]);
    LoginCode::query()->update(['attempts' => 5]);

    $this->postJson('/api/v1/auth/verify', ['email' => 'dara@example.com', 'code' => $code])
        ->assertStatus(422)->assertJsonPath('code', 'code_expired');
});

it('refuses a code after 10 minutes', function () {
    $code = requestCode();
    $this->travel(11)->minutes();

    $this->postJson('/api/v1/auth/verify', ['email' => 'dara@example.com', 'code' => $code])
        ->assertStatus(422)->assertJsonPath('code', 'code_expired');
});

it('only the newest code works', function () {
    $first = requestCode();
    Mail::fake();
    $second = requestCode();

    if ($first !== $second) {
        $this->postJson('/api/v1/auth/verify', ['email' => 'dara@example.com', 'code' => $first])->assertStatus(422);
    }
    $this->postJson('/api/v1/auth/verify', ['email' => 'dara@example.com', 'code' => $second])->assertOk();
});

it('limits codes to 5 a minute per email', function () {
    foreach (range(1, 5) as $i) {
        $this->postJson('/api/v1/auth/code', ['email' => 'dara@example.com'])->assertStatus(202);
    }
    $this->postJson('/api/v1/auth/code', ['email' => 'dara@example.com'])->assertStatus(429);
    $this->postJson('/api/v1/auth/code', ['email' => 'sokha@example.com'])->assertStatus(202);
});

it('signs out only this phone', function () {
    $user = User::factory()->create();
    $phone = $user->createToken('phone')->plainTextToken;
    $tablet = $user->createToken('tablet')->plainTextToken;

    $this->withToken($phone)->postJson('/api/v1/auth/logout')->assertOk();

    expect($user->tokens()->pluck('name')->all())->toBe(['tablet']);
    $this->app['auth']->forgetGuards();
    $this->withToken($tablet)->getJson('/api/v1/me')->assertOk();
});

it('keeps profile and order routes for signed-in customers', function (string $method, string $uri) {
    $this->json($method, $uri)->assertUnauthorized();
})->with([
    ['GET', '/api/v1/me'],
    ['PATCH', '/api/v1/me'],
    ['GET', '/api/v1/me/favourites'],
    ['POST', '/api/v1/checkout/quote'],
    ['POST', '/api/v1/orders'],
    ['GET', '/api/v1/orders'],
]);

describe('profile', function () {
    beforeEach(function () {
        Storage::fake('public');
        $this->seed(DatabaseSeeder::class);
        $this->user = User::factory()->create(['phone' => null]);
        Sanctum::actingAs($this->user);
    });

    it('changes name, phone and language but never role or points', function () {
        $this->patchJson('/api/v1/me', [
            'name' => 'Dara', 'phone' => '012 345 678', 'language' => 'km', 'role' => 'owner', 'points' => 999,
        ])->assertOk()->assertJson(['name' => 'Dara', 'phone' => '012 345 678', 'language' => 'km', 'points' => 0]);

        expect($this->user->refresh()->role)->toBe(UserRole::Customer);
        $this->patchJson('/api/v1/me', ['phone' => '12'])->assertUnprocessable()->assertJsonValidationErrors('phone');
    });

    it('adds and removes favourites', function () {
        $this->putJson('/api/v1/me/favourites/12')->assertOk()->assertJson(['product_ids' => [12]]);
        $this->putJson('/api/v1/me/favourites/12')->assertOk()->assertJson(['product_ids' => [12]]);
        $this->putJson('/api/v1/me/favourites/41')->assertOk();
        $this->deleteJson('/api/v1/me/favourites/12')->assertOk()->assertJson(['product_ids' => [41]]);
        $this->putJson('/api/v1/me/favourites/999')->assertNotFound();
    });

    it('forgets the customer but keeps their past orders without name or phone', function () {
        $this->user->favourites()->attach(12);
        $order = Order::create([
            'user_id' => $this->user->id, 'customer_name' => 'Dara', 'customer_phone' => '012345678',
            'estimated_ready_at' => now(), 'subtotal_cents' => 375, 'total_cents' => 375,
        ]);

        $this->deleteJson('/api/v1/me')->assertOk();

        expect(User::find($this->user->id))->toBeNull()
            ->and($order->refresh())->toMatchArray(['user_id' => null, 'customer_name' => 'Removed', 'customer_phone' => null])
            ->and(Product::find(12))->not->toBeNull();
    });

    it('does not let staff delete themselves from the app', function () {
        $barista = User::factory()->create();
        $barista->forceFill(['role' => UserRole::Barista])->save();
        Sanctum::actingAs($barista);

        $this->deleteJson('/api/v1/me')->assertForbidden()->assertJsonPath('code', 'staff_account');
    });
});
