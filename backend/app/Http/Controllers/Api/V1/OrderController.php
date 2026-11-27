<?php

namespace App\Http\Controllers\Api\V1;

use App\Actions\CancelOrder;
use App\Actions\PlaceOrder;
use App\Actions\QuoteOrder;
use App\Exceptions\ApiProblem;
use App\Http\Controllers\Controller;
use App\Http\Requests\CheckoutRequest;
use App\Http\Requests\PlaceOrderRequest;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class OrderController extends Controller
{
    /** POST /api/v1/checkout/quote: server totals for a cart, or a promo or stock problem. */
    public function quote(CheckoutRequest $request, QuoteOrder $quoteOrder): JsonResponse
    {
        return response()->json($quoteOrder->handle($request->user(), $request->validated())->toApiArray());
    }

    /**
     * POST /api/v1/orders with an Idempotency-Key header. Sending the same
     * key again returns the first order instead of making a second one.
     */
    public function store(PlaceOrderRequest $request, PlaceOrder $placeOrder): JsonResponse
    {
        $key = (string) $request->header('Idempotency-Key');
        if (! preg_match('/^[A-Za-z0-9_-]{8,64}$/', $key)) {
            throw new ApiProblem('idempotency_key_missing', 'Send an Idempotency-Key header of 8 to 64 letters, digits, - or _.', status: 400);
        }

        [$order, $created] = $placeOrder->handle($request->user(), $request->validated(), $key);

        return response()->json($order->toApiArray(), $created ? 201 : 200);
    }

    /** GET /api/v1/orders: own orders, newest first, 20 per page. */
    public function index(Request $request): JsonResponse
    {
        $orders = $request->user()->orders()->with('lines')->latest('id')->paginate(20);

        return response()->json([
            'data' => $orders->getCollection()->map->toApiArray(),
            'next_page' => $orders->hasMorePages() ? $orders->currentPage() + 1 : null,
        ]);
    }

    /** GET /api/v1/orders/{order} */
    public function show(Order $order): JsonResponse
    {
        Gate::authorize('view', $order);

        return response()->json($order->load('lines')->toApiArray());
    }

    /** POST /api/v1/orders/{order}/cancel: only while the order is still received. */
    public function cancel(Order $order, CancelOrder $cancelOrder): JsonResponse
    {
        Gate::authorize('cancel', $order);

        return response()->json($cancelOrder->handle($order, byCustomer: true)->load('lines')->toApiArray());
    }
}
