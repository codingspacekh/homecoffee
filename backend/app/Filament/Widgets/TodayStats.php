<?php

namespace App\Filament\Widgets;

use App\Domain\Money;
use App\Filament\Pages\Reports;
use App\Models\StoreSetting;
use App\Reports\SalesReport;
use Carbon\CarbonImmutable;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

/** The first thing a manager sees: today so far, and the week. */
class TodayStats extends StatsOverviewWidget
{
    protected static ?int $sort = -1;

    protected ?string $pollingInterval = '60s';

    public static function canView(): bool
    {
        return auth()->user()?->role->canManageShop() ?? false;
    }

    protected function getStats(): array
    {
        $today = CarbonImmutable::now(StoreSetting::current()->timezone)->toDateString();
        [$weekStart] = Reports::daysFor('this_week', CarbonImmutable::parse($today));
        $day = (new SalesReport($today, $today))->summary();
        $week = (new SalesReport($weekStart->toDateString(), $today))->summary();

        return [
            Stat::make('Sales today', Money::format($day['sales_cents']))
                ->description("{$day['orders']} picked up, {$day['open']} still open")
                ->url(Reports::getUrl(['range' => 'today'])),
            Stat::make('This week', Money::format($week['sales_cents']))
                ->description("{$week['orders']} orders since Monday")
                ->url(Reports::getUrl()),
            Stat::make('Free drinks this week', (string) $week['free_drinks'])
                ->description(Money::format($week['promo_cents']).' off with promo codes'),
        ];
    }
}
