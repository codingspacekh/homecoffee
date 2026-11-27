<?php

namespace App\Push;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use RuntimeException;

/**
 * Sends through Firebase Cloud Messaging (HTTP v1). Signs in with the
 * project's service account key: a JSON file from Firebase console >
 * Project settings > Service accounts, whose path is FCM_CREDENTIALS.
 */
class FcmPushSender implements PushSender
{
    private const SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';

    /** @param  array{project_id: string, client_email: string, private_key: string, token_uri?: string}  $account */
    public function __construct(private readonly array $account) {}

    public static function fromFile(string $path): self
    {
        $account = json_decode((string) file_get_contents($path), true);
        if (! is_array($account) || ! isset($account['project_id'], $account['client_email'], $account['private_key'])) {
            throw new RuntimeException("{$path} is not a Firebase service account key.");
        }

        return new self($account);
    }

    public function send(PushMessage $message): PushResult
    {
        $response = Http::withToken($this->accessToken())
            ->acceptJson()
            ->timeout(10)
            ->post("https://fcm.googleapis.com/v1/projects/{$this->account['project_id']}/messages:send", [
                'message' => [
                    'token' => $message->token,
                    'notification' => ['title' => $message->title, 'body' => $message->body],
                    'data' => (object) $message->data,
                    'android' => [
                        'priority' => 'high',
                        'notification' => ['channel_id' => 'order_ready', 'sound' => 'default'],
                    ],
                    'apns' => ['payload' => ['aps' => ['sound' => 'default']]],
                ],
            ]);

        if ($response->successful()) {
            return PushResult::Sent;
        }

        $error = collect($response->json('error.details', []))->pluck('errorCode')->filter()->first()
            ?? $response->json('error.status');
        if ($response->status() === 404 || in_array($error, ['UNREGISTERED', 'INVALID_ARGUMENT'], true)) {
            return PushResult::InvalidToken;
        }

        return PushResult::Failed;
    }

    /** A Google OAuth token for the service account, kept for 50 minutes. */
    private function accessToken(): string
    {
        return Cache::remember('fcm.access_token.'.md5($this->account['client_email']), now()->addMinutes(50), function () {
            $tokenUri = $this->account['token_uri'] ?? 'https://oauth2.googleapis.com/token';
            $response = Http::asForm()->timeout(10)->post($tokenUri, [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $this->signedJwt($tokenUri),
            ])->throw();

            return $response->json('access_token');
        });
    }

    private function signedJwt(string $audience): string
    {
        $now = time();
        $encode = fn (array $part) => rtrim(strtr(base64_encode(json_encode($part)), '+/', '-_'), '=');
        $unsigned = $encode(['alg' => 'RS256', 'typ' => 'JWT']).'.'.$encode([
            'iss' => $this->account['client_email'],
            'scope' => self::SCOPE,
            'aud' => $audience,
            'iat' => $now,
            'exp' => $now + 3600,
        ]);
        if (! openssl_sign($unsigned, $signature, $this->account['private_key'], OPENSSL_ALGO_SHA256)) {
            throw new RuntimeException('Could not sign the Firebase token request.');
        }

        return $unsigned.'.'.rtrim(strtr(base64_encode($signature), '+/', '-_'), '=');
    }
}
