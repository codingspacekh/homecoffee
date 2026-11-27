<?php

return [
    // Shown on the privacy policy and delete-account pages, which the app
    // stores ask for. Questions and deletion requests go to this address.
    'contact_email' => env('CONTACT_EMAIL') ?: env('MAIL_FROM_ADDRESS', 'hello@example.com'),

    // Who runs the app, as it should read on those pages
    'operator' => env('APP_OPERATOR') ?: 'HomeCoffee',
];
