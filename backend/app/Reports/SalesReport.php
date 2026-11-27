<?php

namespace App\Reports;

use App\Enums\OrderStatus;
use App\Models\Order;
use App\Models\OrderLine;
use App\Models\StoreSetting;
use Carbon\CarbonImmutable;
use Carbon\CarbonPeriod;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Collection;

/**
 * Sales for a run of days in the shop's time zone, by the day the order was
 * placed. Customers pay at the counter, so only orders picked up count as
 * sales. Cancelled orders are counted on their own.
 */
final class SalesReport
{
    public readonly CarbonImmutable $from;

    public readonly CarbonImmutable $to;

    public readonly string $timezone;

    /** @param  string  $from  first day, Y-m-d, in the shop's time zone; $to is the last day */
    public function __construct(string $from, string $to)
    {
        $this->timezone = StoreSetting::current()->timezone;
        $this->from = CarbonImmutable::parse($from, $this->timezone)->startOfDay();
        $this->to = CarbonImmutable::parse($to, $this->timezone)->endOfDay();
    }

    /** @return Builder<Order> every order placed in the range, whatever happened to it */
    public function orders(): Builder
    {
        return Order::query()->whereBetween('created_at', [$this->from->utc(), $this->to->utc()]);
    }

    /** @return Builder<Order> */
    public function sales(): Builder
    {
        return $this->orders()->where('status', OrderStatus::Collected);
    }

    /**
     * @return array{sales_cents: int, orders: int, average_cents: int, open: int, cancelled: int,
     *     free_drinks: int, reward_cents: int, promo_cents: int, points_earned: int}
     */
    public function summary(): array
    {
        $sales = $this->sales()->toBase()->selectRaw(
            'COUNT(*) AS orders, COALESCE(SUM(total_cents), 0) AS total, COALESCE(SUM(discount_cents), 0) AS reward,
             COALESCE(SUM(promo_cents), 0) AS promo, COALESCE(SUM(points_earned), 0) AS earned,
             COALESCE(SUM(CASE WHEN points_spent > 0 THEN 1 ELSE 0 END), 0) AS free_drinks'
        )->first();
        $orders = (int) $sales->orders;

        return [
            'sales_cents' => (int) $sales->total,
            'orders' => $orders,
            'average_cents' => $orders > 0 ? intdiv((int) $sales->total + intdiv($orders, 2), $orders) : 0,
            'open' => $this->orders()->whereIn('status', [OrderStatus::Received, OrderStatus::Preparing, OrderStatus::Ready])->count(),
            'cancelled' => $this->orders()->where('status', OrderStatus::Cancelled)->count(),
            'free_drinks' => (int) $sales->free_drinks,
            'reward_cents' => (int) $sales->reward,
            'promo_cents' => (int) $sales->promo,
            'points_earned' => (int) $sales->earned,
        ];
    }

    /** @return list<array{day: CarbonImmutable, orders: int, sales_cents: int}> every day in the range, empty days too */
    public function byDay(): array
    {
        $totals = [];
        foreach ($this->sales()->toBase()->select(['created_at', 'total_cents'])->cursor() as $order) {
            $day = CarbonImmutable::parse($order->created_at, 'UTC')->setTimezone($this->timezone)->toDateString();
            $totals[$day]['orders'] = ($totals[$day]['orders'] ?? 0) + 1;
            $totals[$day]['sales_cents'] = ($totals[$day]['sales_cents'] ?? 0) + (int) $order->total_cents;
        }

        $days = [];
        foreach (CarbonPeriod::create($this->from->toDateString(), $this->to->toDateString()) as $date) {
            $key = $date->toDateString();
            $days[] = [
                'day' => CarbonImmutable::parse($key, $this->timezone),
                'orders' => $totals[$key]['orders'] ?? 0,
                'sales_cents' => $totals[$key]['sales_cents'] ?? 0,
            ];
        }

        return $days;
    }

    /**
     * What sold most, by cups. A product renamed in the range shows its
     * latest name.
     *
     * @return Collection<int, array{name: string, quantity: int, sales_cents: int}>
     */
    public function bestSellers(int $limit = 10): Collection
    {
        $lines = OrderLine::query()->whereIn('order_id', $this->sales()->select('id'));
        $rows = (clone $lines)->toBase()
            ->whereNotNull('product_id')
            ->groupBy('product_id')
            ->selectRaw('SUM(quantity) AS quantity, SUM(line_cents) AS sales, MAX(id) AS last_line')
            ->get();
        $names = OrderLine::whereIn('id', $rows->pluck('last_line'))->get()->keyBy('id');
        $items = $rows->map(fn ($row) => [
            'name' => $names[$row->last_line]->translated('name') ?? 'Unknown',
            'quantity' => (int) $row->quantity,
            'sales_cents' => (int) $row->sales,
        ]);

        // Lines of a product deleted since, kept apart by name
        $gone = (clone $lines)->whereNull('product_id')->get()
            ->groupBy(fn (OrderLine $line) => $line->translated('name') ?? 'Unknown')
            ->map(fn (Collection $group, string $name) => [
                'name' => $name,
                'quantity' => (int) $group->sum('quantity'),
                'sales_cents' => (int) $group->sum('line_cents'),
            ]);

        return $items->concat($gone->values())
            ->sortBy([['quantity', 'desc'], ['sales_cents', 'desc'], ['name', 'asc']])
            ->take($limit)
            ->values();
    }

    /** @return Collection<int, array{code: string, uses: int, discount_cents: int, sales_cents: int}> */
    public function promoUse(): Collection
    {
        return $this->sales()->toBase()
            ->whereNotNull('promo_code')
            ->groupBy('promo_code')
            ->selectRaw('promo_code, COUNT(*) AS uses, SUM(promo_cents) AS discount, SUM(total_cents) AS sales')
            ->orderByDesc('uses')
            ->orderBy('promo_code')
            ->get()
            ->map(fn ($row) => [
                'code' => $row->promo_code,
                'uses' => (int) $row->uses,
                'discount_cents' => (int) $row->discount,
                'sales_cents' => (int) $row->sales,
            ]);
    }

    public const CSV_HEADINGS = [
        'Order', 'Placed', 'Status', 'Customer', 'Phone', 'Email', 'Items', 'Subtotal',
        'Free drink', 'Promo code', 'Promo discount', 'Total', 'Points earned', 'Points spent', 'Cancel reason',
    ];

    /**
     * One row per order, for a spreadsheet. Money is in dollars with two
     * decimals so the columns add up.
     *
     * @return \Generator<int, list<string|int>>
     */
    public function csvRows(): \Generator
    {
        $dollars = fn (int $cents) => number_format($cents / 100, 2, '.', '');

        foreach ($this->orders()->with(['lines', 'user'])->orderBy('id')->lazy(200) as $order) {
            yield [
                $order->number(),
                $order->created_at->setTimezone($this->timezone)->format('Y-m-d H:i'),
                ucfirst($order->status->value),
                $order->customer_name,
                (string) $order->customer_phone,
                (string) $order->user?->email,
                $order->lines->map(fn (OrderLine $line) => $line->quantity.' x '.$line->translated('name')
                    .(filled($line->translated('choices')) ? ' ('.$line->translated('choices').')' : ''))->implode('; '),
                $dollars($order->subtotal_cents),
                $dollars($order->discount_cents),
                (string) $order->promo_code,
                $dollars($order->promo_cents),
                $dollars($order->total_cents),
                $order->points_earned,
                $order->points_spent,
                (string) $order->cancel_reason,
            ];
        }
    }

    /** Opens fine in Excel and Google Sheets, Khmer included. */
    public function writeCsv($handle): void
    {
        fwrite($handle, "\xEF\xBB\xBF");
        fputcsv($handle, self::CSV_HEADINGS, escape: '');
        foreach ($this->csvRows() as $row) {
            // A name starting with = or + is text, not a formula
            fputcsv($handle, array_map(fn ($cell) => is_string($cell) && preg_match('/^[=+\-@\t\r]/', $cell) ? "'".$cell : $cell, $row), escape: '');
        }
    }

    public function fileName(): string
    {
        return 'homecoffee-orders-'.$this->from->toDateString().'-to-'.$this->to->toDateString().'.csv';
    }
}
