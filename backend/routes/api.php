<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\DeviceController;
use App\Http\Controllers\Api\V1\MenuController;
use App\Http\Controllers\Api\V1\OrderController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\StoreController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->middleware('throttle:api')->group(function () {
    Route::get('menu', MenuController::class)->name('api.menu');
    Route::get('store', StoreController::class)->name('api.store');

    Route::post('auth/code', [AuthController::class, 'sendCode'])->middleware('throttle:login-code');
    Route::post('auth/verify', [AuthController::class, 'verify'])->middleware('throttle:login-verify');

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);

        Route::get('me', [ProfileController::class, 'show']);
        Route::patch('me', [ProfileController::class, 'update']);
        Route::delete('me', [ProfileController::class, 'destroy']);
        Route::get('me/favourites', [ProfileController::class, 'favourites']);
        Route::put('me/favourites/{product}', [ProfileController::class, 'addFavourite']);
        Route::delete('me/favourites/{product}', [ProfileController::class, 'removeFavourite']);
        Route::get('me/points', [ProfileController::class, 'points']);
        Route::post('me/devices', [DeviceController::class, 'store']);
        Route::delete('me/devices', [DeviceController::class, 'destroy']);

        Route::post('checkout/quote', [OrderController::class, 'quote']);
        Route::post('orders', [OrderController::class, 'store'])->middleware('throttle:orders');
        Route::get('orders', [OrderController::class, 'index']);
        Route::get('orders/{order}', [OrderController::class, 'show']);
        Route::post('orders/{order}/cancel', [OrderController::class, 'cancel']);
    });
});
