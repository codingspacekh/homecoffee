<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\StoreSetting;
use Illuminate\Http\JsonResponse;

class StoreController extends Controller
{
    /** GET /api/v1/store: opening hours, prep time and whether orders are open. */
    public function __invoke(): JsonResponse
    {
        return response()->json(StoreSetting::current()->toApiArray(now()));
    }
}
