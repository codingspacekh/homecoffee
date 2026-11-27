<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * What the customer chose. The app never sends prices: the server works
 * them out from the products table.
 */
class CheckoutRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'lines' => ['required', 'array', 'min:1', 'max:30'],
            'lines.*.product_id' => ['required', 'integer'],
            'lines.*.options' => ['sometimes', 'array'],
            'lines.*.options.*' => ['string', 'max:60'],
            'lines.*.quantity' => ['sometimes', 'integer', 'min:1', 'max:20'],
            'lines.*.note' => ['sometimes', 'nullable', 'string', 'max:200'],
            'promo_code' => ['sometimes', 'nullable', 'string', 'max:20'],
            'use_free_drink' => ['sometimes', 'boolean'],
        ];
    }
}
