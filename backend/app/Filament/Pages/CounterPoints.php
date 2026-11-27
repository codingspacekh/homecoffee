<?php

namespace App\Filament\Pages;

use App\Actions\ChangePoints;
use App\Domain\Loyalty;
use App\Domain\Money;
use App\Enums\PointReason;
use App\Enums\UserRole;
use App\Exceptions\ApiProblem;
use App\Models\PointEntry;
use App\Models\StoreSetting;
use App\Models\User;
use BackedEnum;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Support\Icons\Heroicon;
use Illuminate\Support\Collection;
use Livewire\Attributes\Computed;

/**
 * Points for purchases at the counter. The barista scans the member QR on
 * the customer's Rewards tab (or types the code or phone), enters what they
 * paid, and the points land on the account. A free drink can be given here
 * too.
 */
class CounterPoints extends Page
{
    protected string $view = 'filament.pages.counter-points';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedQrCode;

    protected static ?string $navigationLabel = 'Counter points';

    protected static ?string $title = 'Counter points';

    protected static ?string $slug = 'counter-points';

    protected static ?int $navigationSort = -9;

    /** Member code, phone or email, typed or read from the QR. */
    public string $lookup = '';

    public ?int $customerId = null;

    /** @var list<int> when a phone matches more than one account */
    public array $matches = [];

    /** Dollars paid at the counter, as typed. */
    public string $amount = '';

    #[Computed]
    public function customer(): ?User
    {
        return $this->customerId ? User::where('role', UserRole::Customer)->find($this->customerId) : null;
    }

    /** @return Collection<int, User> */
    #[Computed]
    public function choices(): Collection
    {
        return User::whereIn('id', $this->matches)->orderBy('id')->get();
    }

    /** What this tablet's counter did today, newest first, to catch a mistake. */
    #[Computed]
    public function today(): Collection
    {
        $timezone = StoreSetting::current()->timezone;

        return PointEntry::with(['user', 'staff'])
            ->whereIn('reason', [PointReason::Counter, PointReason::Reward])
            ->whereNotNull('staff_id')
            ->where('created_at', '>=', now($timezone)->startOfDay()->utc())
            ->latest('id')
            ->limit(10)
            ->get();
    }

    public function find(): void
    {
        $this->resetErrorBag();
        $this->matches = [];
        $this->customerId = null;
        $text = trim($this->lookup);
        if ($text === '') {
            return;
        }

        $customers = User::where('role', UserRole::Customer)->orderBy('id');
        $digits = preg_replace('/\D/', '', $text);
        if (preg_match('/(?<!\d)(\d{8})(?!\d)/', str_replace(' ', '', $text), $code) && $found = (clone $customers)->where('member_code', $code[1])->first()) {
            $this->pick($found->id);

            return;
        }
        $found = str_contains($text, '@')
            ? (clone $customers)->where('email', strtolower($text))->get()
            : (strlen($digits) >= 6
                ? (clone $customers)->whereRaw("REPLACE(REPLACE(phone, ' ', ''), '-', '') = ?", [$digits])->get()
                : collect());

        match ($found->count()) {
            0 => $this->addError('lookup', 'No member with that code, phone or email. They can find their code on the Rewards tab in the app.'),
            1 => $this->pick($found->first()->id),
            default => $this->matches = $found->pluck('id')->all(),
        };
    }

    /** Called by the camera when it reads a QR code. */
    public function scanned(string $text): void
    {
        $this->lookup = $text;
        $this->find();
    }

    public function pick(int $id): void
    {
        $this->customerId = $id;
        $this->matches = [];
        $this->amount = '';
        unset($this->customer);
    }

    public function clear(): void
    {
        $this->reset(['lookup', 'customerId', 'matches', 'amount']);
        $this->resetErrorBag();
        unset($this->customer, $this->choices);
    }

    public function addPoints(): void
    {
        $customer = $this->customer;
        if ($customer === null) {
            return;
        }
        $this->validate(['amount' => ['required', 'numeric', 'min:0.01', 'max:500']], [
            'amount.max' => 'That is more than $500. Check the amount.',
        ], ['amount' => 'amount paid']);

        $cents = Money::fromDollars((float) $this->amount);
        $points = Loyalty::pointsFor($cents);
        if ($points === 0) {
            $this->addError('amount', 'Points start at $1.00 (one point per whole dollar).');

            return;
        }

        app(ChangePoints::class)->handle($customer, $points, PointReason::Counter, auth()->user(), 'Paid '.Money::format($cents));
        Notification::make()
            ->title("+{$points} points for {$this->displayName($customer)}")
            ->body("They have {$customer->points} points now.")
            ->success()
            ->send();
        $this->clear();
        unset($this->today);
    }

    public function giveFreeDrink(): void
    {
        $customer = $this->customer;
        if ($customer === null) {
            return;
        }
        try {
            app(ChangePoints::class)->handle($customer, -Loyalty::REWARD_POINTS, PointReason::Reward, auth()->user(), 'Free drink at the counter');
        } catch (ApiProblem) {
            Notification::make()->title("{$this->displayName($customer)} needs ".Loyalty::REWARD_POINTS.' points for a free drink')->danger()->send();

            return;
        }
        Notification::make()
            ->title("Free drink for {$this->displayName($customer)}")
            ->body("{$customer->points} points left.")
            ->success()
            ->send();
        $this->clear();
        unset($this->today);
    }

    public function displayName(User $customer): string
    {
        return $customer->name ?: $customer->email;
    }

    /** Points a typed amount would earn, shown under the field as the barista types. */
    public function previewPoints(): ?int
    {
        return is_numeric($this->amount) && (float) $this->amount > 0 && (float) $this->amount <= 500
            ? Loyalty::pointsFor(Money::fromDollars((float) $this->amount))
            : null;
    }
}
