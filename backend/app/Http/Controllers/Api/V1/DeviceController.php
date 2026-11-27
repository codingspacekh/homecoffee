<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Device;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Push tokens for "Notify me when it's ready". */
class DeviceController extends Controller
{
    /**
     * POST /api/v1/me/devices: saves this phone's push token. A token moves
     * to the account that sends it, so a shared phone only notifies the
     * person signed in now.
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string', 'max:255'],
            'platform' => ['required', 'in:android,ios'],
        ]);

        $device = Device::query()->firstOrNew(['token' => $data['token']]);
        $device->user()->associate($request->user());
        $device->platform = $data['platform'];
        $device->updated_at = now();
        $device->save();

        return response()->json(['saved' => true], 201);
    }

    /**
     * DELETE /api/v1/me/devices: stops pushes to this phone, when the
     * customer turns alerts off or signs out.
     */
    public function destroy(Request $request): JsonResponse
    {
        $data = $request->validate(['token' => ['required', 'string', 'max:255']]);
        $request->user()->devices()->where('token', $data['token'])->delete();

        return response()->json(['deleted' => true]);
    }
}
