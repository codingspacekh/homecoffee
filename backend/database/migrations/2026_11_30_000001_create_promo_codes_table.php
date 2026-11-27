<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('promo_codes', function (Blueprint $table) {
            $table->id();
            $table->string('code', 20)->unique();
            // One of the two: a percentage, or an amount in cents
            $table->unsignedTinyInteger('percent')->nullable();
            $table->unsignedInteger('amount_cents')->nullable();
            $table->unsignedInteger('minimum_cents')->default(0);
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('ends_at')->nullable();
            // Across all customers; null means no limit
            $table->unsignedInteger('max_uses')->nullable();
            $table->boolean('once_per_customer')->default(false);
            $table->boolean('active')->default(true);
            $table->timestamps();
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->index('promo_code');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropIndex(['promo_code']);
        });
        Schema::dropIfExists('promo_codes');
    }
};
