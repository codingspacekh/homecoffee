<?php

namespace App\Filament\Pages;

use App\Models\StoreSetting;
use App\Reports\SalesReport;
use BackedEnum;
use Carbon\CarbonImmutable;
use Filament\Actions\Action;
use Filament\Pages\Page;
use Filament\Support\Icons\Heroicon;
use Livewire\Attributes\Computed;
use Livewire\Attributes\Url;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Sales, best sellers and promo use for a run of days, and every order in
 * that run as a spreadsheet.
 */
class Reports extends Page
{
    public const RANGES = [
        'today' => 'Today',
        'yesterday' => 'Yesterday',
        'this_week' => 'This week',
        'last_week' => 'Last week',
        'this_month' => 'This month',
        'last_month' => 'Last month',
        'custom' => 'Choose days',
    ];

    protected string $view = 'filament.pages.reports';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedChartBar;

    protected static ?string $navigationLabel = 'Reports';

    protected static ?string $title = 'Reports';

    protected static ?string $slug = 'reports';

    protected static ?int $navigationSort = 40;

    #[Url]
    public string $range = 'this_week';

    /** Y-m-d, used when the range is custom. */
    #[Url]
    public string $from = '';

    #[Url]
    public string $to = '';

    public static function canAccess(): bool
    {
        return auth()->user()?->role->canManageShop() ?? false;
    }

    public function mount(): void
    {
        if (! array_key_exists($this->range, self::RANGES)) {
            $this->range = 'this_week';
        }
        if ($this->range !== 'custom') {
            $this->fillDays();
        }
    }

    public function updatedRange(): void
    {
        if ($this->range !== 'custom') {
            $this->fillDays();
        }
    }

    /** The first and last day of a preset, in the shop's time zone. Weeks start on Monday. */
    public static function daysFor(string $range, CarbonImmutable $today): array
    {
        return match ($range) {
            'today' => [$today, $today],
            'yesterday' => [$today->subDay(), $today->subDay()],
            'last_week' => [$today->subWeek()->startOfWeek(), $today->subWeek()->endOfWeek()],
            'this_month' => [$today->startOfMonth(), $today],
            'last_month' => [$today->subMonthNoOverflow()->startOfMonth(), $today->subMonthNoOverflow()->endOfMonth()],
            default => [$today->startOfWeek(), $today],
        };
    }

    private function fillDays(): void
    {
        $today = CarbonImmutable::now(StoreSetting::current()->timezone)->startOfDay();
        [$from, $to] = self::daysFor($this->range, $today);
        $this->from = $from->toDateString();
        $this->to = $to->toDateString();
    }

    #[Computed]
    public function report(): SalesReport
    {
        $valid = fn (string $day) => preg_match('/^\d{4}-\d{2}-\d{2}$/', $day) && strtotime($day) !== false;
        if (! $valid($this->from) || ! $valid($this->to)) {
            $this->range = 'this_week';
            $this->fillDays();
        }
        [$from, $to] = $this->from <= $this->to ? [$this->from, $this->to] : [$this->to, $this->from];

        return new SalesReport($from, $to);
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('export')
                ->label('Download orders (CSV)')
                ->icon(Heroicon::OutlinedArrowDownTray)
                ->color('gray')
                ->action(function (): StreamedResponse {
                    $report = $this->report;

                    return response()->streamDownload(
                        fn () => $report->writeCsv(fopen('php://output', 'w')),
                        $report->fileName(),
                        ['Content-Type' => 'text/csv; charset=UTF-8'],
                    );
                }),
        ];
    }
}
