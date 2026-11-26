<?php

namespace App\Filament\Resources\Products\Schemas;

use App\Filament\Support\Fields;
use App\Models\Category;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Repeater\TableColumn;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ProductForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema->components([
            Section::make('Product')
                ->columnSpanFull()
                ->schema([
                    Fields::translated('name', 'Name'),
                    Fields::translated('description', 'Description', long: true, required: false),
                    Grid::make(['default' => 1, 'md' => 3])->schema([
                        Select::make('category_id')
                            ->label('Category')
                            ->options(fn () => Category::query()->orderBy('sort')->get()->mapWithKeys(fn (Category $c) => [$c->id => $c->translated('name')]))
                            ->required(),
                        Fields::price('price_cents')->helperText('The price of the smallest size, before options.'),
                        Toggle::make('drink')
                            ->label('This is a drink')
                            ->helperText('Only drinks can be the free reward drink.')
                            ->inline(false),
                    ]),
                    Grid::make(['default' => 1, 'md' => 2])->schema([
                        FileUpload::make('image_path')
                            ->label('Photo')
                            ->image()
                            ->disk('public')
                            ->directory('products')
                            ->visibility('public')
                            ->imageEditor()
                            ->imageAspectRatio('1:1')
                            ->maxSize(2048)
                            ->helperText('Square, at least 600 by 600 pixels. Up to 2 MB.'),
                        Toggle::make('available')
                            ->label('Available')
                            ->helperText('Turn off when it is sold out. It stays on the menu, greyed out.')
                            ->default(true)
                            ->inline(false),
                    ]),
                ]),
            Section::make('Options')
                ->description('For example Size or Milk. The first choice in each group is the default, so give it the base price ($0.00 extra).')
                ->columnSpanFull()
                ->schema([
                    Repeater::make('options')
                        ->hiddenLabel()
                        ->addActionLabel('Add an option group')
                        ->reorderable()
                        ->collapsible()
                        ->itemLabel(fn (array $state): ?string => $state['name']['en'] ?? null)
                        ->default([])
                        ->schema([
                            Fields::translated('name', 'Group name', hint: false),
                            Repeater::make('choices')
                                ->addActionLabel('Add a choice')
                                ->reorderable()
                                ->minItems(1)
                                ->required()
                                ->table([
                                    TableColumn::make('Choice in English')->markAsRequired(),
                                    TableColumn::make('Choice in Khmer'),
                                    TableColumn::make('Extra cost')->markAsRequired()->width('9rem'),
                                ])
                                ->schema([
                                    TextInput::make('label.en')->required()->maxLength(40),
                                    TextInput::make('label.km')->maxLength(40),
                                    Fields::price('price_cents', 'Extra cost'),
                                ]),
                        ]),
                ]),
        ]);
    }
}
