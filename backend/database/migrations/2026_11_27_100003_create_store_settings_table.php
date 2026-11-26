<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // A single row with the shop's settings.
        Schema::create('store_settings', function (Blueprint $table) {
            $table->id();
            $table->string('timezone')->default('Asia/Phnom_Penh');
            // {"mon": {"open": "07:00", "close": "18:00"}, ..., "sun": null} where null is closed.
            $table->json('opening_hours');
            // Minutes from order to ready, for "as soon as possible".
            $table->unsignedSmallInteger('prep_minutes')->default(7);
            // The Pause orders switch for rush hour.
            $table->boolean('accepting_orders')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('store_settings');
    }
};
