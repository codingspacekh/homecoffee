<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Customers sign in with an email code, so they have no password and may not
 * have told us their name yet.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('name')->nullable()->change();
            $table->string('password')->nullable()->change();
            $table->string('phone', 20)->nullable()->after('email');
            $table->string('language', 2)->default('en')->after('phone');
            $table->unsignedInteger('points')->default(0)->after('language');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['phone', 'language', 'points']);
        });
    }
};
