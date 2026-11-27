<?php

namespace App\Filament\Pages;

use App\Actions\CancelOrder;
use App\Actions\SetOrderStatus;
use App\Enums\OrderStatus;
use App\Exceptions\ApiProblem;
use App\Models\Order;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Forms\Components\Textarea;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Support\Icons\Heroicon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Livewire\Attributes\Computed;

/**
 * The counter tablet: open orders in three columns, received, preparing
 * and ready. It checks for new orders every 5 seconds and chimes when one
 * arrives. One tap moves an order to the next step.
 */
class OrdersBoard extends Page
{
    protected string $view = 'filament.pages.orders-board';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedQueueList;

    protected static ?string $navigationLabel = 'Orders board';

    protected static ?string $title = 'Orders board';

    protected static ?string $slug = 'board';

    protected static ?int $navigationSort = -10;

    /** The newest order the tablet has seen, so it only chimes for new ones. */
    public int $lastSeenId = 0;

    public function mount(): void
    {
        $this->lastSeenId = (int) Order::max('id');
    }

    public static function getNavigationBadge(): ?string
    {
        $waiting = Order::where('status', OrderStatus::Received)->count();

        return $waiting > 0 ? (string) $waiting : null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }

    /**
     * Open orders by column. Received and preparing go by when they must be
     * ready, so a pickup set for later waits its turn; ready goes by when it
     * was ready, oldest first.
     *
     * @return array<string, Collection<int, Order>>
     */
    #[Computed]
    public function columns(): array
    {
        $open = Order::with('lines')
            ->whereIn('status', [OrderStatus::Received, OrderStatus::Preparing, OrderStatus::Ready])
            ->orderBy('estimated_ready_at')
            ->orderBy('id')
            ->get();

        return [
            'received' => $open->where('status', OrderStatus::Received)->values(),
            'preparing' => $open->where('status', OrderStatus::Preparing)->values(),
            'ready' => $open->where('status', OrderStatus::Ready)->sortBy('ready_at')->values(),
        ];
    }

    /** Runs on every 5 second refresh: chime once for each batch of new orders. */
    public function refreshBoard(): void
    {
        $newest = (int) Order::max('id');
        if ($newest > $this->lastSeenId) {
            $this->lastSeenId = $newest;
            $this->dispatch('new-order');
        }
    }

    /**
     * Moves an order one step on from the status the tablet showed. If the
     * order is no longer in that status (another tablet got there first, or
     * the customer cancelled), nothing moves, so a double tap can't skip a
     * step.
     */
    public function advance(int $orderId, string $from): void
    {
        $moved = DB::transaction(function () use ($orderId, $from) {
            $order = Order::whereKey($orderId)->lockForUpdate()->first();
            $next = $order?->status->next();
            if ($order === null || $order->status->value !== $from || $next === null) {
                return $order;
            }
            app(SetOrderStatus::class)->handle($order, $next);

            return null;
        });

        if ($moved !== null) {
            Notification::make()
                ->title($moved->status === OrderStatus::Cancelled
                    ? "Order #{$moved->number()} was cancelled"
                    : "Order #{$moved->number()} was already moved")
                ->warning()
                ->send();
        }
        unset($this->columns);
    }

    public function cancelAction(): Action
    {
        return Action::make('cancel')
            ->label('Cancel')
            ->color('danger')
            ->link()
            ->size('sm')
            ->modalHeading(fn (array $arguments) => 'Cancel order #'.(Order::find($arguments['order'] ?? 0)?->number() ?? ''))
            ->modalDescription('The customer sees the reason in the app. A free drink they used goes back to their points.')
            ->modalSubmitActionLabel('Cancel order')
            ->modalCancelActionLabel('Keep order')
            ->schema([
                Textarea::make('reason')
                    ->label('Reason')
                    ->placeholder('Out of oat milk')
                    ->required()
                    ->maxLength(200),
            ])
            ->action(function (array $data, array $arguments) {
                $order = Order::findOrFail($arguments['order']);
                try {
                    app(CancelOrder::class)->handle($order, byCustomer: false, reason: $data['reason']);
                    Notification::make()->title("Order #{$order->number()} cancelled")->success()->send();
                } catch (ApiProblem) {
                    Notification::make()->title("Order #{$order->number()} is already finished")->warning()->send();
                }
                unset($this->columns);
            });
    }
}
