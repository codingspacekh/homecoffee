<?php

namespace App\Actions;

use App\Enums\PointReason;
use App\Exceptions\ApiProblem;
use App\Models\PointEntry;
use App\Models\User;
use Illuminate\Support\Facades\DB;

/**
 * Points added or taken away by staff: a purchase at the counter, a free
 * drink given at the counter, or a manager's correction. The customer's row
 * is locked, so two tablets can't spend the same points twice.
 */
class ChangePoints
{
    /** @throws ApiProblem not_enough_points when the balance would go below zero */
    public function handle(User $customer, int $change, PointReason $reason, User $staff, ?string $note = null): PointEntry
    {
        return DB::transaction(function () use ($customer, $change, $reason, $staff, $note) {
            $locked = User::whereKey($customer->id)->lockForUpdate()->firstOrFail();
            if ($locked->points + $change < 0) {
                throw new ApiProblem('not_enough_points', ($locked->name ?: $locked->email)." has {$locked->points} points.", [
                    'points' => $locked->points,
                ]);
            }
            $locked->forceFill(['points' => $locked->points + $change])->save();
            $customer->setRawAttributes($locked->getAttributes(), true);

            return $locked->pointEntries()->create([
                'staff_id' => $staff->id,
                'change' => $change,
                'reason' => $reason,
                'note' => filled($note) ? trim($note) : null,
            ]);
        });
    }
}
