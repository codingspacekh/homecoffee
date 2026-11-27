<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class VerifyCodeRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email:rfc', 'max:254'],
            'code' => ['required', 'string', 'regex:/^\d{6}$/'],
            'device_name' => ['sometimes', 'string', 'max:60'],
            'language' => ['sometimes', 'in:en,km'],
        ];
    }

    public function email(): string
    {
        return mb_strtolower(trim($this->string('email')));
    }
}
