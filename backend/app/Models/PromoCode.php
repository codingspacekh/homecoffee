<?php

namespace App\Models;

use App\Domain\Promo;
use App\Enums\OrderStatus;
use Carbon\CarbonInterface;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

/** A code managers create in the admin panel, such as WELCOME10. */
#[Fillable(['code', 'percent', 'amount_cents', 'minimum_cents', 'starts_at', 'ends_at', 'max_uses', 'once_per_customer', 'active'])]
class PromoCode extends Model
{
    protected function casts(): array
    {
        return [
            'percent' => 'integer',
            'amount_cents' => 'integer',
            'minimum_cents' => 'integer',
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
            'max_uses' => 'integer',
            'once_per_customer' => 'boolean',
            'active' => 'boolean',
        ];
    }

    protected static function booted(): void
    {
        static::saving(fn (self $promo) => $promo->code = Promo::normalize($promo->code));
    }

    public static function findByCode(string $code): ?self
    {
        return static::where('code', Promo::normalize($code))->first();
    }

    public function toDomain(): Promo
    {
        return new Promo($this->code, $this->percent, $this->amount_cents, $this->minimum_cents);
    }

    /** Orders that used the code, leaving out cancelled ones. */
    public function orders(): Builder
    {
        return Order::where('promo_code', $this->code)->where('status', '!=', OrderStatus::Cancelled);
    }

    /**
     * Why the code can't be used right now, as the app's error code, or null.
     * promo_invalid: switched off, not started, ended or used up.
     * promo_used: this customer already used a once-per-customer code.
     */
    public function problemFor(User $customer, CarbonInterface $now): ?string
    {
        if (! $this->active
            || ($this->starts_at !== null && $now->lt($this->starts_at))
            || ($this->ends_at !== null && $now->gte($this->ends_at))
            || ($this->max_uses !== null && $this->orders()->count() >= $this->max_uses)) {
            return 'promo_invalid';
        }
        if ($this->once_per_customer && $this->orders()->where('user_id', $customer->id)->exists()) {
            return 'promo_used';
        }

        return null;
    }
}
