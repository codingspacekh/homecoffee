@php
    use App\Domain\Money;
    use App\Filament\Pages\Reports;

    $report = $this->report;
    $summary = $report->summary();
    $days = $report->byDay();
    $best = $report->bestSellers();
    $promos = $report->promoUse();
    $peak = max(1, ...array_column($days, 'sales_cents'));
    $sameDay = $report->from->isSameDay($report->to);
    $label = $sameDay
        ? $report->from->format('l j F Y')
        : $report->from->format('j M').' to '.$report->to->format('j M Y');
@endphp

<x-filament-panels::page>
    <style>
        .hc-filters { display: flex; flex-wrap: wrap; align-items: end; gap: .75rem 1rem; }
        .hc-field { display: flex; flex-direction: column; gap: .25rem; font-size: .875rem; font-weight: 600; color: var(--gray-700); }
        .dark .hc-field { color: var(--gray-200); }
        .hc-field select, .hc-field input { min-width: 10rem; padding: .5rem .75rem; border-radius: .5rem; border: 1px solid var(--gray-300); background: white; color: var(--gray-950); font-weight: 400; font-size: 1rem; }
        .dark .hc-field select, .dark .hc-field input { background: var(--gray-900); border-color: var(--gray-700); color: white; color-scheme: dark; }
        .hc-range { font-size: 1rem; color: var(--gray-700); }
        .dark .hc-range { color: var(--gray-300); }
        .hc-stats { display: grid; gap: 1rem; grid-template-columns: repeat(4, minmax(0, 1fr)); }
        @media (max-width: 900px) { .hc-stats { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
        .hc-stat, .hc-panel { border-radius: .875rem; padding: 1rem 1.125rem; background: white; border: 1px solid var(--gray-200); }
        .dark .hc-stat, .dark .hc-panel { background: var(--gray-900); border-color: var(--gray-700); }
        .hc-stat-label { font-size: .875rem; font-weight: 600; color: var(--gray-600); }
        .dark .hc-stat-label { color: var(--gray-300); }
        .hc-stat-value { margin-top: .25rem; font-size: 1.75rem; font-weight: 800; color: var(--gray-950); font-variant-numeric: tabular-nums; }
        .dark .hc-stat-value { color: white; }
        .hc-stat-note { margin-top: .125rem; font-size: .875rem; color: var(--gray-600); }
        .dark .hc-stat-note { color: var(--gray-400); }
        .hc-panels { display: grid; gap: 1rem; grid-template-columns: repeat(2, minmax(0, 1fr)); align-items: start; }
        @media (max-width: 900px) { .hc-panels { grid-template-columns: minmax(0, 1fr); } }
        .hc-panel h2 { margin-bottom: .75rem; font-size: 1.0625rem; font-weight: 700; color: var(--gray-950); }
        .dark .hc-panel h2 { color: white; }
        .hc-table { width: 100%; border-collapse: collapse; font-size: .9375rem; font-variant-numeric: tabular-nums; }
        .hc-table th { padding: .375rem .5rem; text-align: left; font-size: .8125rem; font-weight: 600; color: var(--gray-600); border-bottom: 1px solid var(--gray-200); }
        .hc-table td { padding: .5rem; border-bottom: 1px solid var(--gray-100); color: var(--gray-900); vertical-align: middle; }
        .dark .hc-table th { color: var(--gray-400); border-color: var(--gray-700); }
        .dark .hc-table td { color: var(--gray-100); border-color: var(--gray-800); }
        .hc-table .hc-num { text-align: right; white-space: nowrap; }
        .hc-table tr:last-child td { border-bottom: 0; }
        .hc-bar { height: .625rem; border-radius: 999px; background: var(--primary-500); min-width: 2px; }
        .hc-bar-cell { width: 40%; }
        .hc-empty { padding: 1.5rem .5rem; text-align: center; color: var(--gray-600); }
        .dark .hc-empty { color: var(--gray-400); }
        .hc-rank { width: 1.5rem; color: var(--gray-500); }
    </style>

    <div class="hc-filters">
        <label class="hc-field">
            Show
            <select wire:model.live="range">
                @foreach (Reports::RANGES as $value => $name)
                    <option value="{{ $value }}">{{ $name }}</option>
                @endforeach
            </select>
        </label>
        @if ($range === 'custom')
            <label class="hc-field">From <input type="date" wire:model.live="from"></label>
            <label class="hc-field">To <input type="date" wire:model.live="to"></label>
        @endif
        <p class="hc-range">{{ $label }}. Only orders that were picked up count as sales.</p>
    </div>

    <div class="hc-stats">
        <div class="hc-stat">
            <div class="hc-stat-label">Sales</div>
            <div class="hc-stat-value">{{ Money::format($summary['sales_cents']) }}</div>
            <div class="hc-stat-note">Paid at the counter</div>
        </div>
        <div class="hc-stat">
            <div class="hc-stat-label">Orders picked up</div>
            <div class="hc-stat-value">{{ number_format($summary['orders']) }}</div>
            <div class="hc-stat-note">
                {{ $summary['open'] }} still open, {{ $summary['cancelled'] }} cancelled
            </div>
        </div>
        <div class="hc-stat">
            <div class="hc-stat-label">Average order</div>
            <div class="hc-stat-value">{{ Money::format($summary['average_cents']) }}</div>
            <div class="hc-stat-note">{{ number_format($summary['points_earned']) }} points earned</div>
        </div>
        <div class="hc-stat">
            <div class="hc-stat-label">Given away</div>
            <div class="hc-stat-value">{{ Money::format($summary['reward_cents'] + $summary['promo_cents']) }}</div>
            <div class="hc-stat-note">
                {{ $summary['free_drinks'] }} free {{ Str::plural('drink', $summary['free_drinks']) }}, {{ Money::format($summary['promo_cents']) }} in promo codes
            </div>
        </div>
    </div>

    <div class="hc-panels">
        @unless ($sameDay)
            <section class="hc-panel">
                <h2>Sales by day</h2>
                <table class="hc-table">
                    <thead><tr><th>Day</th><th class="hc-num">Orders</th><th class="hc-num">Sales</th><th aria-label="Chart"></th></tr></thead>
                    <tbody>
                        @foreach ($days as $day)
                            <tr>
                                <td>{{ $day['day']->format('D j M') }}</td>
                                <td class="hc-num">{{ $day['orders'] }}</td>
                                <td class="hc-num">{{ Money::format($day['sales_cents']) }}</td>
                                <td class="hc-bar-cell">
                                    @if ($day['sales_cents'] > 0)
                                        <div class="hc-bar" style="width: {{ round($day['sales_cents'] / $peak * 100, 1) }}%"></div>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </section>
        @endunless

        <section class="hc-panel">
            <h2>Best sellers</h2>
            @if ($best->isEmpty())
                <p class="hc-empty">Nothing sold on these days yet.</p>
            @else
                <table class="hc-table">
                    <thead><tr><th class="hc-rank">#</th><th>Item</th><th class="hc-num">Sold</th><th class="hc-num">Sales</th></tr></thead>
                    <tbody>
                        @foreach ($best as $i => $item)
                            <tr>
                                <td class="hc-rank">{{ $i + 1 }}</td>
                                <td>{{ $item['name'] }}</td>
                                <td class="hc-num">{{ $item['quantity'] }}</td>
                                <td class="hc-num">{{ Money::format($item['sales_cents']) }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @endif
        </section>

        <section class="hc-panel">
            <h2>Promo codes</h2>
            @if ($promos->isEmpty())
                <p class="hc-empty">No promo codes used on these days.</p>
            @else
                <table class="hc-table">
                    <thead><tr><th>Code</th><th class="hc-num">Used</th><th class="hc-num">Discount</th><th class="hc-num">Sales</th></tr></thead>
                    <tbody>
                        @foreach ($promos as $promo)
                            <tr>
                                <td><strong>{{ $promo['code'] }}</strong></td>
                                <td class="hc-num">{{ $promo['uses'] }}</td>
                                <td class="hc-num">{{ Money::format($promo['discount_cents']) }}</td>
                                <td class="hc-num">{{ Money::format($promo['sales_cents']) }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @endif
        </section>
    </div>
</x-filament-panels::page>
