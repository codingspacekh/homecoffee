<?php

namespace App\Push;

use Illuminate\Support\Facades\Log;

/**
 * Used until the Firebase key is set (FCM_CREDENTIALS in .env): writes the
 * notification to the log instead, so everything else can be tried locally.
 */
class LogPushSender implements PushSender
{
    public function send(PushMessage $message): PushResult
    {
        Log::info('Push (Firebase not set up)', [
            'token' => substr($message->token, 0, 12).'…',
            'title' => $message->title,
            'body' => $message->body,
            'data' => $message->data,
        ]);

        return PushResult::Sent;
    }
}
