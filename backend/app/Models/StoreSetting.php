<?php

namespace App\Models;

use Carbon\CarbonInterface;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['timezone', 'opening_hours', 'prep_minutes', 'accepting_orders'])]
class StoreSetting extends Model
{
    public const DAYS = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    /** Every day 7 AM to 6 PM until the owner sets real hours in the admin panel. */
    public const DEFAULT_HOURS = ['open' => '07:00', 'close' => '18:00'];

    protected function casts(): array
    {
        return [
            'opening_hours' => 'array',
            'prep_minutes' => 'integer',
            'accepting_orders' => 'boolean',
        ];
    }

    /** The shop's single settings row, created with defaults the first time. */
    public static function current(): self
    {
        return static::query()->firstOrCreate([], [
            'timezone' => 'Asia/Phnom_Penh',
            'opening_hours' => array_fill_keys(self::DAYS, self::DEFAULT_HOURS),
            'prep_minutes' => 7,
            'accepting_orders' => true,
        ]);
    }

    /** @return array{open: string, close: string}|null */
    public function hoursOn(CarbonInterface $moment): ?array
    {
        $day = strtolower($moment->copy()->setTimezone($this->timezone)->format('D'));

        return $this->opening_hours[$day] ?? null;
    }

    public function isOpenAt(CarbonInterface $moment): bool
    {
        $hours = $this->hoursOn($moment);
        if ($hours === null) {
            return false;
        }
        $local = $moment->copy()->setTimezone($this->timezone)->format('H:i');

        return $local >= $hours['open'] && $local < $hours['close'];
    }

    /** The shop as the app reads it from GET /api/v1/store. */
    public function toApiArray(CarbonInterface $now): array
    {
        return [
            'timezone' => $this->timezone,
            'opening_hours' => $this->opening_hours,
            'prep_minutes' => $this->prep_minutes,
            'accepting_orders' => $this->accepting_orders,
            'open_now' => $this->isOpenAt($now),
            'can_order_now' => $this->accepting_orders && $this->isOpenAt($now),
        ];
    }
}
