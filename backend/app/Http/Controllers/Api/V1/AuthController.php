<?php

namespace App\Http\Controllers\Api\V1;

use App\Exceptions\ApiProblem;
use App\Http\Controllers\Controller;
use App\Http\Requests\SendCodeRequest;
use App\Http\Requests\VerifyCodeRequest;
use App\Mail\LoginCodeMail;
use App\Models\LoginCode;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

/**
 * Customers sign in with a 6-digit code sent to their email. There are no
 * passwords: the first verified code creates the account.
 */
class AuthController extends Controller
{
    /** POST /api/v1/auth/code */
    public function sendCode(SendCodeRequest $request): JsonResponse
    {
        $email = $request->email();
        $code = str_pad((string) random_int(0, 999_999), 6, '0', STR_PAD_LEFT);

        DB::transaction(function () use ($email, $code) {
            // Only the newest code works
            LoginCode::where('email', $email)->delete();
            LoginCode::create([
                'email' => $email,
                'code_hash' => Hash::make($code),
                'expires_at' => now()->addMinutes(LoginCode::VALID_MINUTES),
            ]);
        });

        $language = User::where('email', $email)->value('language') ?? $request->input('language', 'en');
        Mail::to($email)->send(new LoginCodeMail($code, $language));

        // The same answer whether or not the account exists
        return response()->json(['sent' => true, 'expires_in_minutes' => LoginCode::VALID_MINUTES], 202);
    }

    /** POST /api/v1/auth/verify */
    public function verify(VerifyCodeRequest $request): JsonResponse
    {
        $email = $request->email();
        $login = LoginCode::where('email', $email)->latest('id')->first();

        if ($login === null || $login->expires_at->isPast()) {
            throw new ApiProblem('code_expired', 'This code has expired. Ask for a new one.');
        }
        if ($login->attempts >= LoginCode::MAX_ATTEMPTS) {
            throw new ApiProblem('code_expired', 'Too many wrong tries. Ask for a new code.');
        }
        if (! Hash::check($request->string('code'), $login->code_hash)) {
            $login->increment('attempts');
            throw new ApiProblem('code_invalid', 'That code is not right.', [
                'attempts_left' => max(0, LoginCode::MAX_ATTEMPTS - $login->attempts),
            ]);
        }

        $login->delete();
        $user = User::firstOrCreate(['email' => $email], ['language' => $request->input('language', 'en')]);
        $newAccount = $user->wasRecentlyCreated;
        if ($user->email_verified_at === null) {
            $user->forceFill(['email_verified_at' => now()])->save();
        }
        $token = $user->createToken($request->input('device_name', 'phone'))->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user->refresh()->toApiArray(),
            'new_account' => $newAccount,
        ]);
    }

    /** POST /api/v1/auth/logout: signs out this phone only. */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['signed_out' => true]);
    }
}
