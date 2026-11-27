<?php

namespace App\Notifications;

use App\Enums\UserRole;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

/** The email a new barista or manager gets, with a link to choose a password. */
class StaffInvite extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public readonly string $url,
        public readonly UserRole $role,
        public readonly string $invitedBy,
    ) {}

    /** @return list<string> */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('You are invited to the HomeCoffee admin')
            ->greeting('Hello'.($notifiable->name ? " {$notifiable->name}" : '').',')
            ->line("{$this->invitedBy} added you to HomeCoffee as a {$this->role->label()}.")
            ->line('Choose a password to sign in to the orders board and the admin panel.')
            ->action('Choose a password', $this->url)
            ->line('The link works for 24 hours. If it has run out, ask for a new invite, or use "Forgot password" on the sign-in page.');
    }
}
