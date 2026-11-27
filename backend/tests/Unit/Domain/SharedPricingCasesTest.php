<?php

use App\Domain\Money;
use App\Domain\Options;
use App\Domain\OrderTotals;
use App\Domain\Product;
use App\Domain\Promo;
use App\Domain\PromoProblem;

/*
 * The same cases run in Dart (packages/domain/test). If the server and the app
 * ever disagree about a price, one of the two suites fails.
 */
function pricingFixtures(): array
{
    return json_decode(file_get_contents(dirname(__DIR__, 4).'/fixtures/pricing.json'), true, flags: JSON_THROW_ON_ERROR);
}

function fixtureProduct(int $id): Product
{
    foreach (pricingFixtures()['products'] as $product) {
        if ($product['id'] === $id) {
            return Product::fromArray($product);
        }
    }
    throw new RuntimeException("No product {$id} in fixtures/pricing.json");
}

function fixtureLine(array $line)
{
    return Options::line(
        fixtureProduct($line['product_id']),
        $line['options'] ?? [],
        $line['quantity'] ?? 1,
        $line['note'] ?? '',
    );
}

dataset('line cases', fn () => collect(pricingFixtures()['line_cases'])->mapWithKeys(fn ($c) => [$c['name'] => [$c]])->all());
dataset('promo cases', fn () => collect(pricingFixtures()['promo_cases'])->mapWithKeys(fn ($c) => ["{$c['code']} on {$c['amount']}" => [$c]])->all());
dataset('order cases', fn () => collect(pricingFixtures()['order_cases'])->mapWithKeys(fn ($c) => [$c['name'] => [$c]])->all());

it('prices a cart line', function (array $case) {
    $line = fixtureLine($case['line']);

    expect($line->options)->toBe($case['expected']['options'])
        ->and($line->unitCents)->toBe($case['expected']['unit_cents'])
        ->and($line->key)->toBe($case['expected']['key'])
        ->and(Money::format($line->unitCents))->toBe($case['expected']['formatted']);
})->with('line cases');

it('checks a promo code', function (array $case) {
    $promo = Promo::website($case['code']);

    expect(($promo?->problem($case['amount']) ?? PromoProblem::Unknown)->value)->toBe($case['problem'])
        ->and($promo?->discount($case['amount']) ?? 0)->toBe($case['discount']);
})->with('promo cases');

it('adds up an order', function (array $case) {
    $cart = array_map(fixtureLine(...), $case['lines']);
    $totals = OrderTotals::for($cart, $case['points'], $case['use_reward'], Promo::website($case['promo_code']));

    expect([
        'subtotal' => $totals->subtotal,
        'discount' => $totals->discount,
        'promo_amount' => $totals->promoAmount,
        'total' => $totals->total,
        'points_earned' => $totals->pointsEarned(),
    ])->toBe($case['expected']);
})->with('order cases');
