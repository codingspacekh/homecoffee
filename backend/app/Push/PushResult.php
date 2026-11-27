<?php

namespace App\Push;

enum PushResult
{
    case Sent;

    /** The app was removed or the token expired: forget this device. */
    case InvalidToken;

    /** Firebase is down or rate limiting: the job tries again. */
    case Failed;
}
