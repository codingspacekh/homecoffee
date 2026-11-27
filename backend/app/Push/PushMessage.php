<?php

namespace App\Push;

/** One notification for one phone. */
final readonly class PushMessage
{
    /** @param  array<string, string>  $data  read by the app when the notification is tapped */
    public function __construct(
        public string $token,
        public string $title,
        public string $body,
        public array $data = [],
    ) {}
}
