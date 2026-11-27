<?php

namespace App\Providers;

use App\Push\FcmPushSender;
use App\Push\LogPushSender;
use App\Push\PushSender;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Firebase once its key is set, the log until then
        $this->app->bind(PushSender::class, function () {
            $credentials = config('services.fcm.credentials');

            return filled($credentials) ? FcmPushSender::fromFile($credentials) : new LogPushSender;
        });
    }

    public function boot(): void
    {
        // Plenty for the app, too few for anyone hammering the API.
        RateLimiter::for('api', fn (Request $request) => Limit::perMinute(120)->by($request->user()?->id ?: $request->ip()));

        // Sign-in emails: 5 a minute for one address, 20 a minute from one network.
        RateLimiter::for('login-code', fn (Request $request) => [
            Limit::perMinute(5)->by('email:'.mb_strtolower(trim((string) $request->input('email')))),
            Limit::perMinute(20)->by('ip:'.$request->ip()),
        ]);

        // Guessing a code: 10 tries a minute from one network, on top of 5 per code.
        RateLimiter::for('login-verify', fn (Request $request) => Limit::perMinute(10)->by($request->ip()));

        // Placing orders: nobody needs more than 10 a minute.
        RateLimiter::for('orders', fn (Request $request) => Limit::perMinute(10)->by($request->user()?->id ?: $request->ip()));
    }
}
