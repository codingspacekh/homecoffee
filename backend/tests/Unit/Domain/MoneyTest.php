<?php

use App\Domain\Money;

it('turns menu.json dollars into cents without float drift', function () {
    expect(Money::fromDollars(3.75))->toBe(375)
        ->and(Money::fromDollars(0.6))->toBe(60)
        ->and(Money::fromDollars(10.05))->toBe(1005);
});

it('formats cents as dollars', function () {
    expect(Money::format(535))->toBe('$5.35')
        ->and(Money::format(7))->toBe('$0.07')
        ->and(Money::format(-200))->toBe('−$2.00');
});
