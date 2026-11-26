# HomeCoffee backend

Laravel API and Filament admin panel. Setup, tests and the rest of the project
are described in the [main README](../README.md).

| Path | What it holds |
| --- | --- |
| `app/Domain/` | Price, promo and points rules, the same as `packages/domain` in Dart |
| `app/Enums/UserRole.php` | customer, barista, manager, owner |
| `app/Providers/Filament/AdminPanelProvider.php` | The admin panel at `/admin` |
| `tests/Unit/Domain/` | Rule tests, including the shared cases in `fixtures/pricing.json` |
| `tests/Feature/` | HTTP and admin access tests |
