<?php

use App\Enums\UserRole;
use App\Filament\Resources\Staff\Pages\ManageStaff;
use App\Models\User;
use App\Notifications\StaffInvite;
use Filament\Actions\Testing\TestAction;
use Filament\Auth\Pages\PasswordReset\ResetPassword;
use Filament\Facades\Filament;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Notification;

use function Pest\Livewire\livewire;

beforeEach(function () {
    Filament::setCurrentPanel('admin');
    Notification::fake();
    $this->owner = User::factory()->owner()->create(['name' => 'Piseth']);
    $this->actingAs($this->owner);
});

it('is for the owner only', function (UserRole $role) {
    $this->get(ManageStaff::getUrl())->assertOk()->assertSee('Invite staff');

    $this->actingAs(User::factory()->role($role)->create())->get(ManageStaff::getUrl())->assertForbidden();
})->with([UserRole::Manager, UserRole::Barista]);

it('lists staff, not customers', function () {
    $barista = User::factory()->barista()->create();
    $customer = User::factory()->create();

    livewire(ManageStaff::class)
        ->assertCanSeeTableRecords([$this->owner, $barista])
        ->assertCanNotSeeTableRecords([$customer]);
});

it('invites a barista by email with a link to choose a password', function () {
    livewire(ManageStaff::class)
        ->callAction('invite', ['name' => 'Vanna', 'email' => 'Vanna@Example.com', 'role' => 'barista'])
        ->assertHasNoFormErrors()
        ->assertNotified('Invite sent to vanna@example.com');

    $vanna = User::firstWhere('email', 'vanna@example.com');
    expect($vanna->role)->toBe(UserRole::Barista)->and($vanna->password)->toBeNull();

    $url = null;
    Notification::assertSentTo($vanna, StaffInvite::class, function (StaffInvite $invite) use (&$url, $vanna) {
        $url = $invite->url;
        $mail = $invite->toMail($vanna);

        return $invite->invitedBy === 'Piseth' && str_contains($mail->introLines[0], 'as a Barista');
    });

    // The link opens the panel's own "choose a password" page
    auth()->logout();
    $this->get($url)->assertOk();
    parse_str(parse_url($url, PHP_URL_QUERY), $query);
    livewire(ResetPassword::class, ['token' => $query['token'] ?? basename(parse_url($url, PHP_URL_PATH)), 'email' => 'vanna@example.com'])
        ->fillForm(['password' => 'a-long-new-password', 'passwordConfirmation' => 'a-long-new-password'])
        ->call('resetPassword')
        ->assertHasNoFormErrors();

    expect(Hash::check('a-long-new-password', $vanna->fresh()->password))->toBeTrue();
});

it('makes an app customer staff, keeping their points', function () {
    $dara = User::factory()->create(['email' => 'dara@example.com', 'points' => 40, 'password' => null]);

    livewire(ManageStaff::class)
        ->callAction('invite', ['name' => 'Dara', 'email' => 'dara@example.com', 'role' => 'manager']);

    expect($dara->fresh())->role->toBe(UserRole::Manager)->points->toBe(40)
        ->and(User::where('email', 'dara@example.com')->count())->toBe(1);
    Notification::assertSentTo($dara, StaffInvite::class);
});

it('says so when the person is already staff', function () {
    User::factory()->manager()->create(['email' => 'mony@example.com']);

    livewire(ManageStaff::class)
        ->callAction('invite', ['name' => 'Mony', 'email' => 'MONY@example.com', 'role' => 'barista'])
        ->assertHasFormErrors(['email']);
    Notification::assertNothingSent();
});

it('changes a role, but never the owner\'s own', function () {
    $barista = User::factory()->barista()->create();

    livewire(ManageStaff::class)
        ->callAction(TestAction::make('role')->table($barista), ['role' => 'manager'])
        ->assertActionHidden(TestAction::make('role')->table($this->owner))
        ->assertActionHidden(TestAction::make('remove')->table($this->owner));

    expect($barista->fresh()->role)->toBe(UserRole::Manager);
});

it('removes someone from staff and signs them out, keeping their app account', function () {
    $barista = User::factory()->barista()->create(['points' => 7]);
    DB::table('sessions')->insert(['id' => 'tablet', 'user_id' => $barista->id, 'payload' => '', 'last_activity' => time()]);

    livewire(ManageStaff::class)->callAction(TestAction::make('remove')->table($barista));

    expect($barista->fresh())->role->toBe(UserRole::Customer)->points->toBe(7)
        ->and(DB::table('sessions')->where('user_id', $barista->id)->exists())->toBeFalse();
    $this->actingAs($barista->fresh())->get('/admin/board')->assertForbidden();
});

it('sends the invite again to someone who has not chosen a password', function () {
    $waiting = User::factory()->barista()->create(['password' => null]);
    $done = User::factory()->barista()->create();

    livewire(ManageStaff::class)
        ->assertActionHidden(TestAction::make('resend')->table($done))
        ->callAction(TestAction::make('resend')->table($waiting))
        ->assertNotified("Invite sent to {$waiting->email}");
    Notification::assertSentTo($waiting, StaffInvite::class);
});
