<?php

use Illuminate\Support\Facades\Schedule;

/*
 * Run by the server's cron every minute: `php artisan schedule:run`.
 * Times are in the shop's time zone, at night when nobody orders.
 */

// Database and product photos to the backup bucket, then old backups removed
Schedule::command('backup:clean')->dailyAt('01:30')->timezone('Asia/Phnom_Penh')->onOneServer();
Schedule::command('backup:run')->dailyAt('02:00')->timezone('Asia/Phnom_Penh')->onOneServer();
// Emails the owner if last night's backup is missing or too big
Schedule::command('backup:monitor')->dailyAt('08:00')->timezone('Asia/Phnom_Penh');

// Housekeeping: expired sign-in codes, password links and failed jobs
Schedule::command('model:prune')->dailyAt('03:00')->timezone('Asia/Phnom_Penh');
Schedule::command('auth:clear-resets')->dailyAt('03:10')->timezone('Asia/Phnom_Penh');
Schedule::command('queue:prune-failed --hours=168')->dailyAt('03:20')->timezone('Asia/Phnom_Penh');
