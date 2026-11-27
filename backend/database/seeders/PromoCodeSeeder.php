<?php

namespace Database\Seeders;

use App\Domain\Promo;
use App\Models\PromoCode;
use Illuminate\Database\Seeder;

/** The website's two codes, WELCOME10 and SAVE2. Safe to run again. */
class PromoCodeSeeder extends Seeder
{
    public function run(): void
    {
        foreach (Promo::WEBSITE as $code => $rule) {
            PromoCode::firstOrCreate(['code' => $code], [
                'percent' => $rule['percent'] ?? null,
                'amount_cents' => $rule['amount'] ?? null,
                'minimum_cents' => $rule['minimum'] ?? 0,
            ]);
        }
    }
}
