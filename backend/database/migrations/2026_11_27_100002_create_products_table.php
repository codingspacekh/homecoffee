<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('category_id')->constrained()->restrictOnDelete();
            // {"en": "...", "km": "..."}. Khmer may be missing; the app falls back to English.
            $table->json('name');
            $table->json('description')->nullable();
            // Whole cents: $3.75 is 375.
            $table->unsignedInteger('price_cents');
            // Only drinks can be the free reward drink.
            $table->boolean('drink')->default(false);
            $table->string('image_path')->nullable();
            // Option groups, the first choice in each is the default. See Product::$options.
            $table->json('options')->nullable();
            // Off = sold out. The product stays on the menu, greyed out.
            $table->boolean('available')->default(true);
            $table->unsignedSmallInteger('sort')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
