<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Support\MenuCache;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class MenuController extends Controller
{
    /**
     * GET /api/v1/menu: every category with its products, sold out ones
     * included. The app sends back the ETag it has, and gets an empty 304 when
     * nothing changed, so a cold start on a weak signal stays fast.
     */
    public function __invoke(Request $request): Response
    {
        ['json' => $json, 'etag' => $etag] = MenuCache::get();
        $headers = ['ETag' => $etag, 'Cache-Control' => 'no-cache'];

        if (in_array($etag, $request->getETags(), true)) {
            return response('', 304, $headers);
        }

        return response($json, 200, $headers + ['Content-Type' => 'application/json']);
    }
}
