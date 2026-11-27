# Putting the app in testers' hands

This guide gets HomeCoffee onto testers' phones through **TestFlight** (iPhone)
and **Google Play internal testing** (Android). Neither needs a public store
listing or a full store review. Do the server guide
(`backend/deploy/README.md`) first, because the app needs a live server.

## What you need first

| What | Cost | Notes |
| --- | --- | --- |
| [Apple Developer Program](https://developer.apple.com/programs/) | $99 a year | For TestFlight. Approval can take a day or two. |
| [Google Play Console](https://play.google.com/console/signup) | $25 once | Google checks your identity first, which can take a few days. |
| A Mac with Xcode | | Only for the signed iPhone build. Android builds run on GitHub. |

The app is already set up for both stores:

- App name **HomeCoffee**, ID `com.codingspacekh.homecoffee` on both.
- Version `1.0.0` in `pubspec.yaml`. The build number after the `+` must go up
  for every upload.
- The icon (cup and roof on espresso brown) is made from the pictures in
  `assets/icon`. To change it, edit those pictures and follow the steps in
  `flutter_launcher_icons.yaml`.
- iOS says the app uses only standard HTTPS, so App Store Connect asks no
  export questions, and lists English and Khmer.
- The Account tab links to the privacy policy on the server.

## 1. Point the app at your server

Store builds read the server address from `config/production.json`, which is
not in git. Make it from the example:

```sh
cd apps/mobile
cp config/production.example.json config/production.json
```

Put in your domain, and the `REVERB_APP_KEY` from the server's `.env`:

```json
{
  "API_URL": "https://YOUR.DOMAIN/api/v1",
  "REVERB_URL": "wss://YOUR.DOMAIN/app/YOUR_REVERB_APP_KEY"
}
```

For builds on GitHub, add the same two values in GitHub under **Settings >
Secrets and variables > Actions > Variables** as `API_URL` and `REVERB_URL`.
They aren't secret: anyone with the app can see them.

## 2. Android: Google Play internal testing

### Make the upload key (once)

Google Play only accepts builds signed with your upload key:

```sh
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

Keep `upload-keystore.jks` and its password in your password manager, never in
git. If you lose it, Google can reset it, but that takes a support request and
a few days.

### Build on GitHub (recommended)

1. In GitHub, under **Settings > Secrets and variables > Actions > Secrets**, add:
   - `ANDROID_KEYSTORE_BASE64`: the key file as text. On a Mac:
     `base64 -i upload-keystore.jks | pbcopy`, then paste.
   - `ANDROID_KEYSTORE_PASSWORD` and `ANDROID_KEY_PASSWORD`: the password you chose.
   - `ANDROID_KEY_ALIAS`: `upload`
2. Under **Actions > App builds**, press **Run workflow**. Pushing a tag such as
   `app-v1.0.0` runs it too.
3. When it finishes, download **homecoffee-android-N** from the run's page. It
   has `app-release.aab` for Google Play and `app-release.apk` you can install
   on a phone directly. Each run has a higher build number, so you never need
   to change it by hand.

### Or build on your computer

With the Android SDK installed, put `key.properties` next to the key in
`apps/mobile/android/` (git ignores both):

```properties
storeFile=upload-keystore.jks
storePassword=your password
keyAlias=upload
keyPassword=your password
```

```sh
flutter build appbundle --release --dart-define-from-file=config/production.json --build-number=2
```

Without `key.properties`, release builds are signed with a debug key. They
install fine but Google Play refuses them.

### Upload it

1. In Play Console, **Create app**: name HomeCoffee, App, Free.
2. Play Console lists what it needs under **Dashboard > Set up your app**. For
   internal testing, fill in:
   - **Privacy policy**: `https://YOUR.DOMAIN/privacy`
   - **App access**: sign-in is by an email code, so say testers use their own
     email address.
   - **Ads**: no ads.
   - **Content rating**: answer the questionnaire (no violence, no gambling,
     users don't talk to each other).
   - **Target audience**: 13 and over.
   - **Data safety**: see the answers below.
3. **Testing > Internal testing > Testers**: make an email list of up to 100
   testers.
4. **Testing > Internal testing > Create new release**: upload the `.aab`,
   then **Review release > Start rollout**. Google keeps the signing key for
   installs (Play App Signing), which is the default.
5. Send testers the **Copy link** address from the Testers tab. They open it on
   their phone, accept, and install HomeCoffee from Google Play.

Internal testing has no review, so a release usually reaches testers within an
hour.

**Data safety answers**, matching the privacy page:

| Question | Answer |
| --- | --- |
| Collects or shares data? | Collects. Shares nothing. |
| Encrypted in transit? | Yes |
| Users can ask for deletion? | Yes. Deletion page: `https://YOUR.DOMAIN/delete-account` |
| Personal info | Email address (required, account management), name and phone number (optional, app functionality) |
| Financial info | Purchase history (app functionality) |
| App activity | Other user-generated content: order notes (app functionality) |

## 3. iPhone: TestFlight

### Register the app (once)

1. In [App Store Connect](https://appstoreconnect.apple.com), **Apps > + >
   New App**: iOS, name HomeCoffee (if the name is taken, try "HomeCoffee
   Phnom Penh"), English, bundle ID `com.codingspacekh.homecoffee`, SKU
   `homecoffee`. If the bundle ID isn't in the list, register it first under
   Certificates, Identifiers & Profiles > Identifiers.
2. On your Mac, clone the repository, make `config/production.json` as in
   step 1, then open `apps/mobile/ios/Runner.xcworkspace` in Xcode. Under
   **Runner > Signing & Capabilities**, tick **Automatically manage signing**
   and pick your team.

### Build and upload

```sh
cd apps/mobile
flutter build ipa --release --dart-define-from-file=config/production.json --build-number=2
```

Then upload the `.ipa` file in `build/ios/ipa/` with Apple's
[Transporter](https://apps.apple.com/app/transporter/id1450874784) app, or open
`build/ios/archive/Runner.xcarchive` and use **Distribute App > App Store
Connect** in Xcode.

Raise `--build-number` for every upload. The **App builds** workflow on GitHub
also builds the iPhone app on every change to the iOS setup, without signing,
so you know it compiles before you sit down at the Mac.

### Invite testers

After about 15 minutes the build appears under **TestFlight**. Add **internal
testers** (people in your App Store Connect team, up to 100): they get an
email, install the TestFlight app, and install HomeCoffee from there. Internal
testing has no review.

External testers (anyone with a link) need Apple's beta review, which needs a
way for the reviewer to sign in. Sign-in is by email code, so that would need a
review account first.

## Releasing a new version

1. Merge the changes to `main`. The server updates by itself.
2. For a bigger change, raise the version in `pubspec.yaml` (for example
   `1.1.0+1`).
3. Android: run **App builds** and upload the new `.aab` to internal testing.
4. iPhone: on the Mac, pull `main`, build with a higher `--build-number`, and
   upload.

Old app versions keep working while the API stays at `/api/v1`.
