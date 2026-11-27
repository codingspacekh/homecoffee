<?php

use App\Enums\OrderStatus;
use App\Filament\Resources\PromoCodes\Pages\ManagePromoCodes;
use App\Models\PromoCode;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\Testing\TestAction;
use Filament\Facades\Filament;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;

use function Pest\Livewire\livewire;

beforeEach(function () {
    Storage::fake('public');
    $this->seed(DatabaseSeeder::class);
    $this->travelTo(Carbon::parse('2026-12-02 09:00', 'Asia/Phnom_Penh'));
    $this->customer = User::factory()->create();
});

/** Quote a $10.70 cart (2 cappuccinos) with a code, as the app does at checkout. */
function quoteWith(string $code)
{
    Sanctum::actingAs(test()->customer);

    return test()->postJson('/api/v1/checkout/quote', [
        'lines' => [['product_id' => 12, 'options' => ['Size' => 'Large', 'Milk' => 'Oat'], 'quantity' => 2]],
        'promo_code' => $code,
    ]);
}

describe('at checkout', function () {
    it('takes a code made in the admin panel', function () {
        PromoCode::create(['code' => 'rainy', 'amount_cents' => 150]);

        quoteWith(' Rainy ')->assertOk()->assertJson(['promo_code' => 'RAINY', 'promo_cents' => 150, 'total_cents' => 920]);
    });

    it('refuses a code that is off, not started, ended or used up', function (array $attributes) {
        PromoCode::create(['code' => 'LATE', 'percent' => 20, ...$attributes]);
        makeOrder(['promo_code' => 'LATE']);

        quoteWith('LATE')->assertStatus(422)->assertJsonPath('code', 'promo_invalid');
    })->with([
        'switched off' => [['active' => false]],
        'not started' => [['starts_at' => '2026-12-02 03:00:00']], // 10 AM in Phnom Penh
        'ended' => [['ends_at' => '2026-12-02 01:00:00']], // 8 AM in Phnom Penh
        'used up' => [['max_uses' => 1]],
    ]);

    it('lets a customer use a once-per-customer code once', function () {
        PromoCode::create(['code' => 'FIRST', 'percent' => 20, 'once_per_customer' => true]);
        quoteWith('FIRST')->assertOk();

        makeOrder(['promo_code' => 'FIRST'], $this->customer);

        quoteWith('FIRST')->assertStatus(422)->assertJsonPath('code', 'promo_used');
    });

    it('does not count cancelled orders as uses', function () {
        PromoCode::create(['code' => 'ONE', 'percent' => 20, 'max_uses' => 1, 'once_per_customer' => true]);
        makeOrder(['promo_code' => 'ONE', 'status' => OrderStatus::Cancelled], $this->customer);

        quoteWith('ONE')->assertOk();
    });

    it('still checks the smallest order', function () {
        PromoCode::create(['code' => 'BIG', 'amount_cents' => 300, 'minimum_cents' => 2000]);

        quoteWith('BIG')->assertStatus(422)->assertJson(['code' => 'promo_minimum', 'minimum_cents' => 2000]);
    });

    it('keeps the website codes', function () {
        expect(PromoCode::pluck('code')->sort()->values()->all())->toBe(['SAVE2', 'WELCOME10']);
    });
});

describe('in the admin panel', function () {
    beforeEach(fn () => Filament::setCurrentPanel('admin'));

    it('lets a manager create a percent or amount code', function () {
        $this->actingAs(User::factory()->manager()->create());

        livewire(ManagePromoCodes::class)
            ->callAction(CreateAction::class, ['code' => 'coffee5', 'kind' => 'amount', 'amount_cents' => '5.00', 'minimum_cents' => '15', 'max_uses' => 100, 'active' => true])
            ->assertHasNoFormErrors();

        expect(PromoCode::firstWhere('code', 'COFFEE5'))
            ->percent->toBeNull()
            ->amount_cents->toBe(500)
            ->minimum_cents->toBe(1500)
            ->max_uses->toBe(100);
    });

    it('switches a code from amount to percent', function () {
        $this->actingAs(User::factory()->owner()->create());
        $promo = PromoCode::firstWhere('code', 'SAVE2');

        livewire(ManagePromoCodes::class)
            ->callAction(TestAction::make(EditAction::class)->table($promo), ['kind' => 'percent', 'percent' => 15])
            ->assertHasNoFormErrors();

        expect($promo->refresh())->percent->toBe(15)->amount_cents->toBeNull();
    });

    it('checks the code and the dates', function () {
        $this->actingAs(User::factory()->manager()->create());

        livewire(ManagePromoCodes::class)
            ->callAction(CreateAction::class, [
                'code' => 'save2',
                'kind' => 'percent',
                'percent' => 150,
                'starts_at' => '2026-12-10 09:00',
                'ends_at' => '2026-12-01 09:00',
            ])
            ->assertHasFormErrors(['code', 'percent' => 'max', 'ends_at' => 'after']);
    });

    it('shows how often each code was used', function () {
        $this->actingAs(User::factory()->manager()->create());
        makeOrder(['promo_code' => 'WELCOME10']);
        makeOrder(['promo_code' => 'WELCOME10']);
        makeOrder(['promo_code' => 'WELCOME10', 'status' => OrderStatus::Cancelled]);

        livewire(ManagePromoCodes::class)->assertSeeText('10% off')->assertSeeText('2');
        expect(PromoCode::firstWhere('code', 'WELCOME10')->orders()->count())->toBe(2);
    });

    it('only deletes a code no order used', function () {
        $this->actingAs(User::factory()->manager()->create());
        makeOrder(['promo_code' => 'WELCOME10']);

        livewire(ManagePromoCodes::class)
            ->assertActionHidden(TestAction::make(DeleteAction::class)->table(PromoCode::firstWhere('code', 'WELCOME10')))
            ->assertActionVisible(TestAction::make(DeleteAction::class)->table(PromoCode::firstWhere('code', 'SAVE2')));
    });

    it('is for managers and the owner only', function () {
        $this->actingAs(User::factory()->barista()->create())
            ->get('/admin/promo-codes')
            ->assertForbidden();
    });
});
