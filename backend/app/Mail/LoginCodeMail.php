<?php

namespace App\Mail;

use App\Models\LoginCode;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;

class LoginCodeMail extends Mailable
{
    use Queueable;

    public function __construct(public readonly string $code, public readonly string $language = 'en') {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: $this->language === 'km'
                ? "{$this->code} គឺជាលេខកូដចូល HomeCoffee របស់អ្នក"
                : "{$this->code} is your HomeCoffee sign-in code",
        );
    }

    public function content(): Content
    {
        return new Content(
            markdown: 'mail.login-code',
            with: ['minutes' => LoginCode::VALID_MINUTES],
        );
    }
}
