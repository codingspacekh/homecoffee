# HomeCoffee

Order ahead and skip the line. HomeCoffee is a Flutter app for customers, a
Laravel API, and a Filament admin panel for the shop.

| Folder | What it is |
| --- | --- |
| `backend/` | Laravel API (`/api/v1`) and the Filament admin panel (`/admin`), MySQL |
| `apps/mobile/` | Flutter customer app for iOS and Android |
| `packages/domain/` | Dart menu models and the price, promo and points rules |
| `packages/data/` | Dart API client and repositories |
| `packages/ui/` | Dart theme: colours, Figtree and Noto Sans Khmer, type scale |
| `fixtures/pricing.json` | Price cases that both the PHP and the Dart tests must pass |

## Backend

Needs PHP 8.3+, Composer and MySQL 8.

```sh
cd backend
composer install
cp .env.example .env          # then set DB_DATABASE, DB_USERNAME, DB_PASSWORD
php artisan key:generate
php artisan migrate --seed      # tables, plus the website's menu and photos
php artisan storage:link        # serves product photos from storage/app/public
php artisan homecoffee:owner you@example.com   # your admin panel account
php artisan serve
```

The seeder imports `backend/database/seeders/menu/menu.json`, a copy of the
website's menu, and is safe to run again.

### API

| Method | Endpoint | What it returns |
| --- | --- | --- |
| GET | `/api/v1/menu` | Every category with its products, prices in cents, English and Khmer. Sends an ETag and answers `304` when the app already has the latest menu |
| GET | `/api/v1/store` | Opening hours, prep time, `open_now` and `can_order_now` |

Each phone or user can make 120 requests a minute.

Open http://localhost:8000/admin and sign in. Only baristas, managers and the
owner can open the admin panel; customers use the app.

Tests and code style:

```sh
vendor/bin/pest
vendor/bin/pint
```

Tests use an in-memory SQLite database locally. CI runs them on MySQL.

## Flutter

Needs Flutter 3.50. The Dart packages form one workspace, so a single
`flutter pub get` at the root sets up everything.

```sh
flutter pub get
cd apps/mobile
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api/v1   # Android emulator
```

Tests:

```sh
flutter analyze
(cd packages/domain && dart test)
(cd packages/data && dart test)
(cd packages/ui && flutter test)
(cd apps/mobile && flutter test)
```

After changing a model in `packages/domain`, regenerate its code:

```sh
cd packages/domain && dart run build_runner build --delete-conflicting-outputs
```

## Prices

Money is always whole cents: $3.75 is `375`. The rules live twice, in PHP
(`backend/app/Domain`, the real total) and in Dart (`packages/domain`, the cart
preview). Both test suites read `fixtures/pricing.json`. Add a case there
whenever a price rule changes, and CI fails if the two ever disagree.

## Fonts

Figtree and Noto Sans Khmer are bundled in `packages/ui/fonts` under the SIL
Open Font License (see the OFL files there).
