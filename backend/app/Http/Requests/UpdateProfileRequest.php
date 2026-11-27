<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    /** Cambodian numbers, with or without +855, spaces allowed: 012 345 678. */
    public const PHONE_PATTERN = '/^(\+?855|0)[1-9][0-9 ]{6,10}$/';

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'nullable', 'string', 'max:60'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:20', 'regex:'.self::PHONE_PATTERN],
            'language' => ['sometimes', 'in:en,km'],
        ];
    }
}
