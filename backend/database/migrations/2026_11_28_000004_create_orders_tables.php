<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Orders keep a copy of every name and price at the moment of ordering, so
 * later menu changes never rewrite an old receipt.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            // Null once the customer asks us to forget their data
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('status', 20)->default('received')->index();
            $table->string('customer_name', 60);
            $table->string('customer_phone', 20)->nullable();
            $table->string('payment_method', 20)->default('counter');
            // Null means as soon as possible
            $table->timestamp('pickup_at')->nullable();
            $table->timestamp('estimated_ready_at');
            $table->unsignedInteger('subtotal_cents');
            $table->unsignedInteger('discount_cents')->default(0);
            $table->string('promo_code', 20)->nullable();
            $table->unsignedInteger('promo_cents')->default(0);
            $table->unsignedInteger('total_cents');
            $table->unsignedInteger('points_spent')->default(0);
            $table->unsignedInteger('points_earned')->default(0);
            $table->string('idempotency_key', 64)->nullable();
            $table->string('cancel_reason')->nullable();
            $table->timestamp('preparing_at')->nullable();
            $table->timestamp('ready_at')->nullable();
            $table->timestamp('collected_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->timestamps();

            // A retried request with the same key finds the first order
            $table->unique(['user_id', 'idempotency_key']);
        });

        Schema::create('order_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->nullable()->constrained()->nullOnDelete();
            $table->json('name');
            // {"Size": "Large", "Milk": "Oat"}, every group filled in
            $table->json('options');
            // The non-default choices as text, in English and Khmer
            $table->json('choices');
            $table->string('note', 60)->default('');
            $table->unsignedInteger('unit_cents');
            $table->unsignedSmallInteger('quantity');
            $table->unsignedInteger('line_cents');
        });

        Schema::create('point_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('order_id')->nullable()->constrained()->nullOnDelete();
            // Positive when earned or refunded, negative when spent
            $table->integer('change');
            $table->string('reason', 20);
            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('point_entries');
        Schema::dropIfExists('order_lines');
        Schema::dropIfExists('orders');
    }
};
