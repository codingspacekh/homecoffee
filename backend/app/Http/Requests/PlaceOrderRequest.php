<?php

namespace App\Http\Requests;

/** The checkout choices plus the pickup time and the name for the counter. */
class PlaceOrderRequest extends CheckoutRequest
{
    public function rules(): array
    {
        return [
            ...parent::rules(),
            'pickup_at' => ['required', 'string', function (string $attribute, mixed $value, \Closure $fail) {
                if ($value !== 'asap' && strtotime((string) $value) === false) {
                    $fail('Pickup time must be "asap" or a date and time.');
                }
            }],
            'customer_name' => ['required', 'string', 'max:60'],
            'customer_phone' => ['sometimes', 'nullable', 'string', 'max:20', 'regex:'.UpdateProfileRequest::PHONE_PATTERN],
        ];
    }
}
