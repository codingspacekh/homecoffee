<?php

namespace App\Push;

interface PushSender
{
    public function send(PushMessage $message): PushResult;
}
