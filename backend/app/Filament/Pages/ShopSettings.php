<?php

namespace App\Filament\Pages;

use App\Models\StoreSetting;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\TimePicker;
use Filament\Forms\Components\Toggle;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Schemas\Components\Actions;
use Filament\Schemas\Components\EmbeddedSchema;
use Filament\Schemas\Components\Form;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;

/**
 * Opening hours, how long a drink takes, and the switch that stops new app
 * orders. The app reads all of it from GET /api/v1/store, so a change shows
 * up the next time a customer opens the menu or checks out.
 */
class ShopSettings extends Page
{
    public const DAY_NAMES = [
        'mon' => 'Monday', 'tue' => 'Tuesday', 'wed' => 'Wednesday', 'thu' => 'Thursday',
        'fri' => 'Friday', 'sat' => 'Saturday', 'sun' => 'Sunday',
    ];

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCog6Tooth;

    protected static ?string $navigationLabel = 'Shop settings';

    protected static ?string $title = 'Shop settings';

    protected static ?string $slug = 'shop-settings';

    protected static ?int $navigationSort = 50;

    /** @var array<string, mixed> */
    public ?array $data = [];

    public static function canAccess(): bool
    {
        return auth()->user()?->role->canManageShop() ?? false;
    }

    public function mount(): void
    {
        $store = StoreSetting::current();
        $days = [];
        foreach (StoreSetting::DAYS as $day) {
            $hours = $store->opening_hours[$day] ?? null;
            $days[$day] = [
                'open_day' => $hours !== null,
                'open' => $hours['open'] ?? StoreSetting::DEFAULT_HOURS['open'],
                'close' => $hours['close'] ?? StoreSetting::DEFAULT_HOURS['close'],
            ];
        }

        $this->form->fill([
            'accepting_orders' => $store->accepting_orders,
            'prep_minutes' => $store->prep_minutes,
            'days' => $days,
        ]);
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->statePath('data')
            ->components([
                Section::make('App orders')
                    ->columns(2)
                    ->schema([
                        Toggle::make('accepting_orders')
                            ->label('Take new orders in the app')
                            ->helperText('Turn this off in a rush. Customers see that the shop has paused orders, and orders already placed stay on the board.')
                            ->columnSpanFull(),
                        TextInput::make('prep_minutes')
                            ->label('Time to make an order')
                            ->helperText('An "as soon as possible" order is due this many minutes after it is placed.')
                            ->integer()
                            ->minValue(1)
                            ->maxValue(60)
                            ->suffix('minutes')
                            ->required(),
                    ]),
                Section::make('Opening hours')
                    ->description('Customers can order from opening time, and the last pickup is at closing time.')
                    ->schema(collect(self::DAY_NAMES)->map(fn (string $name, string $day) => Grid::make(3)
                        ->schema([
                            Toggle::make("days.{$day}.open_day")
                                ->label($name)
                                ->onIcon(Heroicon::Check)
                                ->live()
                                ->inline(false),
                            TimePicker::make("days.{$day}.open")
                                ->label('Opens')
                                ->seconds(false)
                                ->format('H:i')
                                ->required(fn (Get $get) => $get("days.{$day}.open_day"))
                                ->visible(fn (Get $get) => $get("days.{$day}.open_day")),
                            TimePicker::make("days.{$day}.close")
                                ->label('Closes')
                                ->seconds(false)
                                ->format('H:i')
                                ->after("days.{$day}.open")
                                ->validationMessages(['after' => 'Closing time must be after opening time.'])
                                ->required(fn (Get $get) => $get("days.{$day}.open_day"))
                                ->visible(fn (Get $get) => $get("days.{$day}.open_day")),
                        ]))->values()->all()),
            ]);
    }

    public function content(Schema $schema): Schema
    {
        return $schema->components([
            Form::make([EmbeddedSchema::make('form')])
                ->id('form')
                ->livewireSubmitHandler('save')
                ->footer([
                    Actions::make([
                        Action::make('save')->label('Save settings')->submit('save')->keyBindings(['mod+s']),
                    ]),
                ]),
        ]);
    }

    public function save(): void
    {
        $data = $this->form->getState();

        $hours = [];
        foreach (StoreSetting::DAYS as $day) {
            $row = $data['days'][$day] ?? [];
            $hours[$day] = ($row['open_day'] ?? false)
                ? ['open' => substr($row['open'], 0, 5), 'close' => substr($row['close'], 0, 5)]
                : null;
        }

        StoreSetting::current()->update([
            'accepting_orders' => $data['accepting_orders'],
            'prep_minutes' => $data['prep_minutes'],
            'opening_hours' => $hours,
        ]);

        Notification::make()->title('Settings saved')->success()->send();
    }
}
