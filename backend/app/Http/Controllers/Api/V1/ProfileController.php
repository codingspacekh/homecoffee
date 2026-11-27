<?php

namespace App\Http\Controllers\Api\V1;

use App\Exceptions\ApiProblem;
use App\Http\Controllers\Controller;
use App\Http\Requests\UpdateProfileRequest;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** The signed-in customer's own profile, favourites and points. */
class ProfileController extends Controller
{
    /** GET /api/v1/me */
    public function show(Request $request): JsonResponse
    {
        return response()->json($request->user()->toApiArray());
    }

    /** PATCH /api/v1/me */
    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();
        $user->update($request->validated());

        return response()->json($user->toApiArray());
    }

    /**
     * DELETE /api/v1/me: Forget my data. Removes the account, favourites,
     * points history and sign-ins, and clears the name and phone on past
     * orders, which stay for the shop's sales records.
     */
    public function destroy(Request $request): JsonResponse
    {
        $user = $request->user();
        if ($user->role->isStaff()) {
            throw new ApiProblem('staff_account', 'Staff accounts are removed by the owner in the admin panel.', status: 403);
        }

        DB::transaction(function () use ($user) {
            $user->orders()->update(['customer_name' => 'Removed', 'customer_phone' => null]);
            $user->tokens()->delete();
            $user->delete();
        });

        return response()->json(['deleted' => true]);
    }

    /** GET /api/v1/me/favourites: product ids, newest first. */
    public function favourites(Request $request): JsonResponse
    {
        return response()->json([
            'product_ids' => $request->user()->favourites()->orderByPivot('created_at', 'desc')->pluck('products.id'),
        ]);
    }

    /** PUT /api/v1/me/favourites/{product} */
    public function addFavourite(Request $request, Product $product): JsonResponse
    {
        $request->user()->favourites()->syncWithoutDetaching([$product->id]);

        return $this->favourites($request);
    }

    /** DELETE /api/v1/me/favourites/{product} */
    public function removeFavourite(Request $request, Product $product): JsonResponse
    {
        $request->user()->favourites()->detach($product->id);

        return $this->favourites($request);
    }

    /** GET /api/v1/me/points: the points history for the Rewards tab. */
    public function points(Request $request): JsonResponse
    {
        $user = $request->user();
        $entries = $user->pointEntries()->with('order')->latest('id')->paginate(20);

        return response()->json([
            'points' => $user->points,
            'data' => $entries->getCollection()->map->toApiArray(),
            'next_page' => $entries->hasMorePages() ? $entries->currentPage() + 1 : null,
        ]);
    }
}
