<?php

use App\Models\User;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Member codes for the QR on the Rewards tab, which the counter scans, and
 * who changed points by hand and why.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('member_code', 8)->nullable()->unique()->after('points');
        });
        DB::table('users')->whereNull('member_code')->orderBy('id')->pluck('id')
            ->each(fn (int $id) => DB::table('users')->where('id', $id)->update(['member_code' => User::newMemberCode()]));

        Schema::table('point_entries', function (Blueprint $table) {
            $table->foreignId('staff_id')->nullable()->after('order_id')->constrained('users')->nullOnDelete();
            $table->string('note', 200)->nullable()->after('reason');
        });
    }

    public function down(): void
    {
        Schema::table('point_entries', function (Blueprint $table) {
            $table->dropConstrainedForeignId('staff_id');
            $table->dropColumn('note');
        });
        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique(['member_code']);
            $table->dropColumn('member_code');
        });
    }
};
