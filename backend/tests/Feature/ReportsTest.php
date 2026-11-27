<?php

use App\Domain\Money;
use App\Enums\OrderStatus;
use App\Filament\Pages\Reports;
use App\Filament\Widgets\TodayStats;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use App\Reports\SalesReport;
use Database\Seeders\MenuSeeder;
use Filament\Facades\Filament;
use Illuminate\Support\Carbon;

use function Pest\Livewire\livewire;

beforeEach(function () {
    Filament::setCurrentPanel('admin');
    $this->seed(MenuSeeder::class);
    // Wednesday
    $this->travelTo(Carbon::parse('2026-12-02 15:00', 'Asia/Phnom_Penh'));
    $this->actingAs(User::factory()->manager()->create());
    [$this->latte, $this->croissant] = Product::orderBy('id')->take(2)->get()->all();
});

/** A picked-up order of one product, placed at a local time. */
function sold(Product $product, int $quantity, string $at, array $attributes = []): Order
{
    $unit = $product->price_cents;
    $order = Order::forceCreate([
        'user_id' => User::factory()->create()->id,
        'status' => OrderStatus::Collected,
        'customer_name' => 'Dara',
        'estimated_ready_at' => now(),
        'subtotal_cents' => $unit * $quantity,
        'total_cents' => $unit * $quantity - ($attributes['promo_cents'] ?? 0),
        'created_at' => Carbon::parse($at, 'Asia/Phnom_Penh')->utc(),
        ...$attributes,
    ]);
    $order->lines()->forceCreate([
        'product_id' => $product->id,
        'name' => $product->name,
        'options' => [],
        'choices' => ['en' => ''],
        'unit_cents' => $unit,
        'quantity' => $quantity,
        'line_cents' => $unit * $quantity,
    ]);

    return $order;
}

it('is for managers and the owner, not baristas', function () {
    $this->get(Reports::getUrl())->assertOk()->assertSee('Best sellers');

    $this->actingAs(User::factory()->barista()->create())->get(Reports::getUrl())->assertForbidden();
});

it('works out presets in the shop\'s time zone, weeks from Monday', function () {
    $today = Carbon::parse('2026-12-02', 'Asia/Phnom_Penh')->toImmutable();
    $days = fn (string $range) => array_map(fn ($day) => $day->toDateString(), Reports::daysFor($range, $today));

    expect($days('today'))->toBe(['2026-12-02', '2026-12-02'])
        ->and($days('yesterday'))->toBe(['2026-12-01', '2026-12-01'])
        ->and($days('this_week'))->toBe(['2026-11-30', '2026-12-02'])
        ->and($days('last_week'))->toBe(['2026-11-23', '2026-11-29'])
        ->and($days('this_month'))->toBe(['2026-12-01', '2026-12-02'])
        ->and($days('last_month'))->toBe(['2026-11-01', '2026-11-30']);
});

it('counts picked-up orders as sales, by the local day they were placed', function () {
    sold($this->latte, 2, '2026-11-30 07:10');
    sold($this->latte, 1, '2026-12-02 00:20'); // after midnight in Phnom Penh, still Dec 1 in UTC
    sold($this->croissant, 4, '2026-12-02 09:00', ['promo_code' => 'WELCOME10', 'promo_cents' => 100]);
    sold($this->latte, 1, '2026-11-29 23:50'); // last week
    sold($this->latte, 5, '2026-12-01 10:00', ['status' => OrderStatus::Cancelled]);
    sold($this->latte, 1, '2026-12-02 14:55', ['status' => OrderStatus::Preparing]);

    $report = new SalesReport('2026-11-30', '2026-12-02');
    $latte = $this->latte->price_cents;
    $croissant = $this->croissant->price_cents;

    expect($report->summary())->toMatchArray([
        'orders' => 3,
        'sales_cents' => $latte * 3 + $croissant * 4 - 100,
        'open' => 1,
        'cancelled' => 1,
        'promo_cents' => 100,
    ])
        ->and(array_map(fn ($day) => [$day['day']->toDateString(), $day['orders']], $report->byDay()))
        ->toBe([['2026-11-30', 1], ['2026-12-01', 0], ['2026-12-02', 2]])
        ->and($report->bestSellers()->all())->toBe([
            ['name' => $this->croissant->translated('name'), 'quantity' => 4, 'sales_cents' => $croissant * 4],
            ['name' => $this->latte->translated('name'), 'quantity' => 3, 'sales_cents' => $latte * 3],
        ])
        ->and($report->promoUse()->all())->toBe([
            ['code' => 'WELCOME10', 'uses' => 1, 'discount_cents' => 100, 'sales_cents' => $croissant * 4 - 100],
        ]);
});

it('keeps a deleted product in best sellers under its name', function () {
    sold($this->latte, 4, '2026-12-02 08:00');
    $name = $this->latte->translated('name');
    $this->latte->delete();
    sold($this->croissant, 1, '2026-12-02 08:30');

    expect((new SalesReport('2026-12-02', '2026-12-02'))->bestSellers()->pluck('quantity', 'name')->all())
        ->toBe([$name => 4, $this->croissant->translated('name') => 1]);
});

it('shows the week by default and switches range', function () {
    sold($this->latte, 2, '2026-12-02 08:00', ['promo_code' => 'SAVE2', 'promo_cents' => 200]);
    sold($this->croissant, 1, '2026-11-25 08:00');

    livewire(Reports::class)
        ->assertSet('from', '2026-11-30')
        ->assertSee('SAVE2')
        ->assertSee($this->latte->translated('name'))
        ->assertDontSee($this->croissant->translated('name'))
        ->set('range', 'last_week')
        ->assertSet('from', '2026-11-23')
        ->assertSet('to', '2026-11-29')
        ->assertSee($this->croissant->translated('name'))
        ->assertSee('No promo codes used')
        ->set('range', 'custom')
        ->set('from', '2026-11-25')
        ->set('to', '2026-12-02')
        ->assertSee('SAVE2')
        ->assertSee($this->croissant->translated('name'));
});

it('downloads every order in the range as a spreadsheet', function () {
    $order = sold($this->latte, 2, '2026-12-01 08:05', ['customer_name' => '=HYPERLINK("x")', 'customer_phone' => '012 345 678']);
    $cancelled = sold($this->croissant, 1, '2026-12-02 09:00', ['status' => OrderStatus::Cancelled, 'cancel_reason' => 'Out of butter']);
    sold($this->latte, 1, '2026-11-20 08:00');

    $handle = fopen('php://memory', 'w+');
    (new SalesReport('2026-11-30', '2026-12-02'))->writeCsv($handle);
    rewind($handle);
    $csv = stream_get_contents($handle);
    $rows = array_map(str_getcsv(...), explode("\n", trim(substr($csv, 3))));

    expect(substr($csv, 0, 3))->toBe("\xEF\xBB\xBF")
        ->and($rows)->toHaveCount(3)
        ->and($rows[0])->toBe(SalesReport::CSV_HEADINGS)
        ->and($rows[1][0])->toBe((string) $order->number())
        ->and($rows[1][1])->toBe('2026-12-01 08:05')
        ->and($rows[1][3])->toBe("'=HYPERLINK(\"x\")")
        ->and($rows[1][6])->toBe('2 x '.$this->latte->translated('name'))
        ->and($rows[1][11])->toBe(number_format($this->latte->price_cents * 2 / 100, 2))
        ->and($rows[2][2])->toBe('Cancelled')
        ->and($rows[2][14])->toBe('Out of butter');

    livewire(Reports::class)
        ->callAction('export')
        ->assertFileDownloaded('homecoffee-orders-2026-11-30-to-2026-12-02.csv');
});

it('shows today and this week on the dashboard for managers only', function () {
    sold($this->latte, 2, '2026-12-02 08:00');
    sold($this->latte, 1, '2026-11-30 08:00');

    livewire(TodayStats::class)
        ->assertSee('Sales today')
        ->assertSee(Money::format($this->latte->price_cents * 2))
        ->assertSee(Money::format($this->latte->price_cents * 3));

    $this->actingAs(User::factory()->barista()->create());
    expect(TodayStats::canView())->toBeFalse();
});
