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
| GET, PATCH, DELETE | `/me` | Profile, points and the 8-digit `member_code`; change name, phone, language; forget my data |
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
`item_unavailable`, `promo_invalid`, `promo_used`, `promo_minimum`, `not_enough_points`,
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

### Running the shop

Everything else happens in the admin panel, and what each person sees depends
on their role.

| Role | Can use |
| --- | --- |
| Barista | Orders board, Counter points, and marking products sold out |
| Manager | Also the menu, Promo codes, Orders, Customers, Shop settings and Reports |
| Owner | Everything, including Staff |

- **Counter points** (`/admin/counter-points`): for customers who pay at the
  counter without ordering in the app. Scan the QR on the Rewards tab of their
  app with the tablet camera, or type their member code, phone or email. Enter
  what they paid and they get a point per whole dollar. **Give free drink**
  takes 50 points. The tablet needs the camera allowed for the site, and the
  admin panel on HTTPS (or localhost).
- **Promo codes**: a percent or an amount off, with a minimum order, start and
  end dates, a total number of uses and once per customer. `WELCOME10` and
  `SAVE2`, the website's codes, are seeded. A code that was used can be turned
  off but not deleted.
- **Orders**: every order, searchable by number, name or phone, filtered by
  status and day. A manager can cancel an open order with a reason.
- **Customers**: each customer's orders and points history. **Adjust points**
  adds or takes away points with a note, for example after a mistake.
- **Shop settings**: opening hours for each day (or closed), how long an order
  takes to make, and **Take new orders in the app**. Baristas can also pause
  and resume app orders from the top of the orders board in a rush.
- **Reports**: sales, orders, average order, best sellers and promo code use
  for today, this week, last month or any days, and **Download orders (CSV)**
  for a spreadsheet. Only orders that were picked up count as sales. Managers
  see today and this week on the dashboard too.
- **Staff**: the owner invites people by email and picks their role. They get
  a link to choose a password, which works for 24 hours (**Send invite again**
  makes a new one). Someone who already uses the app keeps their points.
  **Remove** signs them out and makes them a customer again. Nobody can change
  their own role, so the shop always has an owner.

Invites and "Forgot password" are emails, so set a real mailer first.

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

Not switched on yet. The app has the pieces: once a push service is added
(Firebase Cloud Messaging, see the backend section), it saves the phone with
the server (`POST /me/devices`) while the customer is signed in with
**Order-ready alerts** on, removes it when they turn alerts off or sign out,
and opens the order when its notification is tapped. Until then the order
screen still updates live while the app is open.

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
