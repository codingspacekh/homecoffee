<?php

namespace App\Console\Commands;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Console\Attributes\Description;
use Illuminate\Console\Attributes\Signature;
use Illuminate\Console\Command;
use Illuminate\Support\Str;

use function Laravel\Prompts\password;
use function Laravel\Prompts\text;

#[Signature('homecoffee:owner {email?} {--name=}')]
#[Description('Create the owner account for the admin panel, or make an existing user the owner')]
class MakeOwner extends Command
{
    public function handle(): int
    {
        $email = $this->argument('email') ?? text('Email', required: true);
        $user = User::firstWhere('email', $email);

        if ($user === null) {
            $user = new User([
                'name' => $this->option('name') ?? Str::before($email, '@'),
                'email' => $email,
                'password' => password('Password (at least 12 characters)', required: true, validate: fn (string $value) => strlen($value) < 12 ? 'Use at least 12 characters.' : null),
            ]);
        }

        $user->role = UserRole::Owner;
        $user->save();

        $this->info("{$email} is the owner. Sign in at ".url('/admin'));

        return self::SUCCESS;
    }
}
