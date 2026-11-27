<?php

namespace App\View\Components;

use Illuminate\View\Component;
use Illuminate\View\View;

/** The public pages: home, privacy policy and delete account. */
class SiteLayout extends Component
{
    public function __construct(public string $title, public ?string $description = null) {}

    public function render(): View
    {
        return view('site.layout');
    }
}
