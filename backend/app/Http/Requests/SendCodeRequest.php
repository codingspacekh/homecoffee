<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SendCodeRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email:rfc', 'max:254'],
            'language' => ['sometimes', 'in:en,km'],
        ];
    }

    public function email(): string
    {
        return mb_strtolower(trim($this->string('email')));
    }
}
