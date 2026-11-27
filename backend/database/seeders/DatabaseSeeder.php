<?php

namespace Database\Seeders;

use App\Models\StoreSetting;
use App\Support\MenuCache;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * php artisan db:seed fills a new database with the website's menu, its
     * two promo codes and the default shop settings. Create your admin
     * account with php artisan homecoffee:owner.
     */
    public function run(): void
    {
        $this->call([MenuSeeder::class, PromoCodeSeeder::class]);
        StoreSetting::current();
        MenuCache::forget();
    }
}
