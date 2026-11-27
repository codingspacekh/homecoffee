<?php

namespace App\Exceptions;

use Illuminate\Http\JsonResponse;
use RuntimeException;

/**
 * A rule the request broke, answered as HTTP 422 with a code the app
 * translates, for example {"code": "promo_minimum", "message": "..."}.
 * The message is English, for logs and for people reading the API.
 */
class ApiProblem extends RuntimeException
{
    /** @param  array<string, mixed>  $details */
    public function __construct(
        public readonly string $problem,
        string $message,
        public readonly array $details = [],
        public readonly int $status = 422,
    ) {
        parent::__construct($message);
    }

    public function render(): JsonResponse
    {
        return response()->json(
            ['code' => $this->problem, 'message' => $this->getMessage(), ...$this->details],
            $this->status,
        );
    }
}
