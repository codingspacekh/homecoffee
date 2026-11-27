<?php

use App\Actions\SetOrderStatus;
use App\Enums\OrderStatus;
use App\Jobs\SendOrderReadyPush;
use App\Models\User;
use App\Push\FcmPushSender;
use App\Push\LogPushSender;
use App\Push\PushSender;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Queue;

/** A throwaway service account key, shaped like the one Firebase hands out. */
function fakeServiceAccount(): string
{
    $key = openssl_pkey_new(['private_key_bits' => 2048, 'private_key_type' => OPENSSL_KEYTYPE_RSA]);
    openssl_pkey_export($key, $pem);
    $path = tempnam(sys_get_temp_dir(), 'firebase').'.json';
    file_put_contents($path, json_encode([
        'type' => 'service_account',
        'project_id' => 'homecoffee-test',
        'client_email' => 'push@homecoffee-test.iam.gserviceaccount.com',
        'private_key' => $pem,
        'token_uri' => 'https://oauth2.googleapis.com/token',
    ]));

    return $path;
}

function useFirebase(): void
{
    config(['services.fcm.credentials' => fakeServiceAccount()]);
}

function fakeFirebase(array $sendResponses): void
{
    Http::fake([
        'oauth2.googleapis.com/token' => Http::response(['access_token' => 'google-token', 'expires_in' => 3600]),
        'fcm.googleapis.com/*' => Http::sequence($sendResponses),
    ]);
}

function unregistered(): array
{
    return ['error' => ['code' => 404, 'status' => 'NOT_FOUND', 'details' => [
        ['@type' => 'type.googleapis.com/google.firebase.fcm.v1.FcmError', 'errorCode' => 'UNREGISTERED'],
    ]]];
}

it('queues the push when the barista marks an order ready, and only then', function () {
    Queue::fake();
    $order = makeOrder();

    app(SetOrderStatus::class)->handle($order, OrderStatus::Preparing);
    Queue::assertNotPushed(SendOrderReadyPush::class);

    app(SetOrderStatus::class)->handle($order, OrderStatus::Ready);
    Queue::assertPushed(SendOrderReadyPush::class, fn ($job) => $job->orderId === $order->id);

    app(SetOrderStatus::class)->handle($order, OrderStatus::Collected);
    Queue::assertPushed(SendOrderReadyPush::class, 1);
});

it('sends "order ready" to every phone of the customer through Firebase', function () {
    useFirebase();
    fakeFirebase([Http::response(['name' => 'projects/homecoffee-test/messages/1']), Http::response(['name' => 'projects/homecoffee-test/messages/2'])]);
    $customer = User::factory()->create();
    $customer->devices()->create(['token' => 'phone-a', 'platform' => 'android']);
    $customer->devices()->create(['token' => 'phone-b', 'platform' => 'ios']);
    $order = makeOrder(['status' => OrderStatus::Ready], $customer);

    (new SendOrderReadyPush($order->id))->handle(app(PushSender::class));

    Http::assertSent(function (Request $request) {
        if (! str_contains($request->url(), 'oauth2')) {
            return false;
        }
        [, $claims] = explode('.', $request['assertion']);
        $claims = json_decode(base64_decode(strtr($claims, '-_', '+/')), true);

        return $request['grant_type'] === 'urn:ietf:params:oauth:grant-type:jwt-bearer'
            && $claims['iss'] === 'push@homecoffee-test.iam.gserviceaccount.com'
            && $claims['scope'] === 'https://www.googleapis.com/auth/firebase.messaging';
    });
    $sends = Http::recorded(fn (Request $request) => str_contains($request->url(), 'fcm.googleapis.com'));
    expect($sends)->toHaveCount(2);
    [$request] = $sends->first();
    expect($request->url())->toBe('https://fcm.googleapis.com/v1/projects/homecoffee-test/messages:send')
        ->and($request->header('Authorization'))->toBe(['Bearer google-token'])
        ->and($request['message']['token'])->toBe('phone-a')
        ->and($request['message']['notification'])->toBe(['title' => "Order #{$order->number()} is ready", 'body' => 'Come and pick it up at the counter.'])
        ->and((array) $request['message']['data'])->toBe(['type' => 'order_ready', 'order_id' => (string) $order->id])
        ->and($request['message']['android']['notification']['channel_id'])->toBe('order_ready');
});

it('writes the push in Khmer for a customer who reads Khmer', function () {
    useFirebase();
    fakeFirebase([Http::response(['name' => 'ok'])]);
    $customer = User::factory()->create(['language' => 'km']);
    $customer->devices()->create(['token' => 'phone-a', 'platform' => 'android']);
    $order = makeOrder(['status' => OrderStatus::Ready], $customer);

    (new SendOrderReadyPush($order->id))->handle(app(PushSender::class));

    Http::assertSent(fn (Request $request) => str_contains($request->url(), 'fcm')
        && $request['message']['notification']['title'] === "ការបញ្ជាទិញ #{$order->number()} រួចរាល់ហើយ");
});

it('forgets a phone that Firebase says no longer has the app', function () {
    useFirebase();
    fakeFirebase([Http::response(unregistered(), 404), Http::response(['name' => 'ok'])]);
    $customer = User::factory()->create();
    $customer->devices()->create(['token' => 'old-phone', 'platform' => 'android']);
    $customer->devices()->create(['token' => 'new-phone', 'platform' => 'android']);

    (new SendOrderReadyPush(makeOrder(['status' => OrderStatus::Ready], $customer)->id))->handle(app(PushSender::class));

    expect($customer->devices()->pluck('token')->all())->toBe(['new-phone']);
});

it('fails the job so the queue tries again when Firebase is down', function () {
    useFirebase();
    fakeFirebase([Http::response(['error' => ['status' => 'UNAVAILABLE']], 503)]);
    $customer = User::factory()->create();
    $customer->devices()->create(['token' => 'phone-a', 'platform' => 'android']);
    $order = makeOrder(['status' => OrderStatus::Ready], $customer);

    expect(fn () => (new SendOrderReadyPush($order->id))->handle(app(PushSender::class)))
        ->toThrow(RuntimeException::class);
    expect($customer->devices()->count())->toBe(1);
});

it('sends nothing for a customer without alerts turned on', function () {
    useFirebase();
    Http::fake();

    (new SendOrderReadyPush(makeOrder(['status' => OrderStatus::Ready])->id))->handle(app(PushSender::class));

    Http::assertNothingSent();
});

it('writes pushes to the log until the Firebase key is set', function () {
    config(['services.fcm.credentials' => null]);

    expect(app(PushSender::class))->toBeInstanceOf(LogPushSender::class);

    useFirebase();
    expect(app(PushSender::class))->toBeInstanceOf(FcmPushSender::class);
});
