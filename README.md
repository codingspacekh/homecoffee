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

Everything is under `/api/v1` and speaks JSON. Signed-in requests send
`Authorization: Bearer <token>`. The app sends choices, never prices: the
server prices every cart from the products table.

| Method | Endpoint | What it does |
| --- | --- | --- |
| GET | `/menu` | Every category with its products, prices in cents, English and Khmer. Sends an ETag and answers `304` when the app already has the latest menu |
| GET | `/store` | Opening hours, prep time, `open_now` and `can_order_now` |
| POST | `/auth/code` | Emails a 6-digit sign-in code, valid 10 minutes. 5 a minute per email |
| POST | `/auth/verify` | Checks the code, creates the account the first time, returns a token |
| POST | `/auth/logout` | Signs out this phone |
| GET, PATCH, DELETE | `/me` | Profile and points; change name, phone, language; forget my data |
| GET | `/me/favourites` | Favourite product ids |
| PUT, DELETE | `/me/favourites/{product}` | Add or remove a favourite |
| GET | `/me/points` | Points history |
| POST, DELETE | `/me/devices` | Save or forget this phone's push token (`token`, `platform`: `android` or `ios`) |
| POST | `/checkout/quote` | Server totals for a cart, promo code and free drink |
| POST | `/orders` | Places an order. Needs an `Idempotency-Key` header, so a retry never makes two |
| GET | `/orders`, `/orders/{order}` | Own orders, newest first, with their lines |
| POST | `/orders/{order}/cancel` | Cancels while the order is still received |

A broken rule answers `422` with a code the app translates, for example
`{"code": "promo_minimum", "minimum_cents": 1000}`. The codes are
`item_unavailable`, `promo_invalid`, `promo_minimum`, `not_enough_points`,
`store_closed`, `orders_paused`, `pickup_outside_hours`, `order_not_cancellable`,
`code_invalid` and `code_expired`.

Each phone or user can make 120 requests a minute, and place 10 orders a minute.

### Sign-in emails and live status

With `MAIL_MAILER=log` (the default), sign-in codes go to
`storage/logs/laravel.log` instead of an inbox. Set a real mailer (Resend,
Postmark or Mailgun) before inviting anyone.

Order status changes reach the app through Reverb, on the private channel
`orders.{id}`. The app joins it at `POST /api/broadcasting/auth` with its token.
To try it locally, set the `REVERB_*` values and `BROADCAST_CONNECTION=reverb`
in `.env`, then run these next to `php artisan serve`:

```sh
php artisan reverb:start
php artisan queue:work
```

Points are spent on a free drink when the order is placed, given back if it is
cancelled, and earned when the order is collected.

Open http://localhost:8000/admin and sign in. Only baristas, managers and the
owner can open the admin panel; customers use the app.

### Orders board

The counter tablet opens http://localhost:8000/admin/board. Open orders sit in
three columns, New, Preparing and Ready for pickup, soonest due first. The
board checks for new orders every 5 seconds, and one tap moves an order to the
next step. If two tablets tap the same order, only the first tap counts. A
barista can cancel an open order with a reason, which the customer reads in
the app.

Tap **Turn on sound** once each morning: browsers only play sound and keep the
screen awake after a tap on the page. The tablet remembers the choice, and the
board chimes for each new order after that.

### "Your order is ready" pushes

When the barista taps Ready, a queued job sends a push to each phone of that
customer that turned on order alerts, in the customer's language. Until
Firebase is set up, the push is written to `storage/logs/laravel.log` instead.

To send real pushes:

1. Create a Firebase project and add the Android and iOS apps to it
   (package and bundle id `com.codingspacekh.homecoffee`). For iOS, upload an APNs key
   under Project settings > Cloud Messaging.
2. Under Project settings > Service accounts, generate a new private key.
   Keep the JSON file outside the repository, or in `backend/storage/` as
   `firebase.json` (ignored by git), and set its path as `FCM_CREDENTIALS`.
3. Keep `php artisan queue:work` running. A push that Firebase can't take is
   tried 3 times; a phone that no longer has the app is forgotten.

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
flutter run                                                      # iOS simulator, uses localhost
```

Start the backend first (`php artisan serve`). The app keeps the last menu it
downloaded and its photos on the phone, so after one successful start it opens
with no signal too.

For live order status, also run `php artisan reverb:start` and give the app
Reverb's address with your `REVERB_APP_KEY` from `backend/.env`:

```sh
flutter run --dart-define=REVERB_URL=ws://localhost:8080/app/<REVERB_APP_KEY>
```

Without `REVERB_URL` the order screen asks the server for news every 10
seconds instead. Sign-in codes go to `backend/storage/logs/laravel.log` while
`MAIL_MAILER=log`. The sign-in token is kept in the Keychain (iOS) or
Keystore-backed storage (Android), not in plain preferences.

### Order-ready pushes

The app saves the phone with the server (`POST /me/devices`) once the
customer is signed in with **Order-ready alerts** on, and removes it when they
turn alerts off or sign out. Tapping the notification opens that order. While
the app is open, the push shows as a bar at the bottom instead.

Pushes need Firebase. Without its settings the app builds and runs as usual,
just with no pushes (as on the web and in tests). To turn them on:

1. In the Firebase console, add an Android app (`com.codingspacekh.homecoffee`)
   and an iOS app (same bundle id) to the project from the backend steps.
2. Copy the values from Project settings > Your apps into
   `apps/mobile/firebase.json`. Git ignores this file.

   ```json
   {
     "FIREBASE_PROJECT_ID": "homecoffee-12345",
     "FIREBASE_SENDER_ID": "123456789012",
     "FIREBASE_ANDROID_APP_ID": "1:123456789012:android:abc123",
     "FIREBASE_ANDROID_API_KEY": "AIza...",
     "FIREBASE_IOS_APP_ID": "1:123456789012:ios:def456",
     "FIREBASE_IOS_API_KEY": "AIza..."
   }
   ```

   The sender id is the project number. Each app's API key is inside the
   file the console offers to download for it: `current_key` in
   google-services.json, `API_KEY` in GoogleService-Info.plist. Copy the key
   out; the files themselves aren't needed.
3. Pass the file to every run and build:

   ```sh
   flutter run --dart-define-from-file=firebase.json
   ```

   The Android build reads the same file, so Firebase starts with the app and
   can show a push while the app is closed.
4. For iOS, upload an APNs key in Firebase (Project settings > Cloud
   Messaging) and test on a real iPhone; the simulator gets no pushes.

App text lives in `apps/mobile/lib/l10n/app_en.arb` and `app_km.arb`. After
editing either, run `flutter gen-l10n` in `apps/mobile` (a build also does it).
Every key needs both languages.

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
cd packages/domain && dart run build_runner build
```

## Prices

Money is always whole cents: $3.75 is `375`. The rules live twice, in PHP
(`backend/app/Domain`, the real total) and in Dart (`packages/domain`, the cart
preview). Both test suites read `fixtures/pricing.json`. Add a case there
whenever a price rule changes, and CI fails if the two ever disagree.

## Fonts

Figtree and Noto Sans Khmer are bundled in `packages/ui/fonts` under the SIL
Open Font License (see the OFL files there).
