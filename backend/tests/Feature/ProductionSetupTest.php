<?php

use App\Models\LoginCode;
use App\Providers\AppServiceProvider;
use Illuminate\Console\Scheduling\Schedule;

describe('public pages', function () {
    it('serves the home page, privacy policy and delete-account page', function (string $path, string $text) {
        config(['homecoffee.contact_email' => 'privacy@homecoffee.test']);

        $this->get($path)
            ->assertOk()
            ->assertSee($text)
            ->assertSee('privacy@homecoffee.test')
            ->assertSee(route('privacy'))
            ->assertSee(route('delete-account'));
    })->with([
        'home' => ['/', 'Order ahead and skip the line.'],
        'privacy' => ['/privacy', 'No ads, no tracking'],
        'delete account' => ['/delete-account', 'Forget my data'],
    ]);

    it('tells people deleting by email what is kept', function () {
        $this->get('/delete-account')->assertSee('Removed')->assertSee('within 30 days')->assertSee('4 months');
    });
});

it('runs backups and cleanup every night in the shop\'s time zone', function () {
    $events = collect(app(Schedule::class)->events())
        ->mapWithKeys(fn ($event) => [trim(preg_replace('/^.*artisan.? /', '', $event->command), "'") => $event]);

    expect($events->keys()->all())->toContain('backup:run', 'backup:clean', 'backup:monitor', 'model:prune', 'auth:clear-resets', 'queue:prune-failed --hours=168')
        ->and($events['backup:run']->expression)->toBe('0 2 * * *')
        ->and($events['backup:run']->timezone)->toBe('Asia/Phnom_Penh');
});

it('prunes sign-in codes a day after they expire', function () {
    $old = LoginCode::create(['email' => 'a@example.com', 'code_hash' => 'x', 'expires_at' => now()->subDays(2)]);
    $recent = LoginCode::create(['email' => 'b@example.com', 'code_hash' => 'x', 'expires_at' => now()->subHour()]);

    $this->artisan('model:prune', ['--model' => [LoginCode::class]])->assertSuccessful();

    expect(LoginCode::find($old->id))->toBeNull()->and(LoginCode::find($recent->id))->not->toBeNull();
});

it('makes https links on the server, so emailed links are safe', function () {
    expect(route('privacy'))->toStartWith('http://');

    app()->detectEnvironment(fn () => 'production');
    (new AppServiceProvider(app()))->boot();

    expect(route('privacy'))->toStartWith('https://');
});
