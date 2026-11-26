import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @turnOnNotifications.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get turnOnNotifications;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 4'**
  String stepOf(int step);

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to HomeCoffee'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Pick your language. You can change it any time in Account.'**
  String get welcomeBody;

  /// No description provided for @orderAheadTitle.
  ///
  /// In en, this message translates to:
  /// **'Order ahead, skip the line'**
  String get orderAheadTitle;

  /// No description provided for @orderAheadBody.
  ///
  /// In en, this message translates to:
  /// **'Choose your drink, pick a pickup time, and collect it at the counter when it’s ready.'**
  String get orderAheadBody;

  /// No description provided for @pointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Every dollar earns a point'**
  String get pointsTitle;

  /// No description provided for @pointsBody.
  ///
  /// In en, this message translates to:
  /// **'Collect 50 points and your next drink is on us.'**
  String get pointsBody;

  /// No description provided for @pointsSample.
  ///
  /// In en, this message translates to:
  /// **'+5 points'**
  String get pointsSample;

  /// No description provided for @notifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Know when it’s ready'**
  String get notifyTitle;

  /// No description provided for @notifyBody.
  ///
  /// In en, this message translates to:
  /// **'We send one notification when your order is ready to pick up, and nothing else.'**
  String get notifyBody;

  /// No description provided for @yourPoints.
  ///
  /// In en, this message translates to:
  /// **'Your points'**
  String get yourPoints;

  /// No description provided for @sampleNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Order #1042 is ready'**
  String get sampleNotificationTitle;

  /// No description provided for @sampleNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Come and pick it up at the counter.'**
  String get sampleNotificationBody;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @showWelcomeAgain.
  ///
  /// In en, this message translates to:
  /// **'Show welcome screens again'**
  String get showWelcomeAgain;

  /// No description provided for @tabMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get tabMenu;

  /// No description provided for @tabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get tabOrders;

  /// No description provided for @tabRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get tabRewards;

  /// No description provided for @tabAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabAccount;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @readyIn.
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup in about {minutes} min'**
  String readyIn(int minutes);

  /// No description provided for @closedNow.
  ///
  /// In en, this message translates to:
  /// **'We’re closed right now. You can still look around.'**
  String get closedNow;

  /// No description provided for @menuError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the menu. Check your connection and try again.'**
  String get menuError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search the menu'**
  String get search;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No items match “{query}”'**
  String noResults(String query);

  /// No description provided for @noResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try another word or category.'**
  String get noResultsHint;

  /// No description provided for @noFavourites.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get noFavourites;

  /// No description provided for @noFavouritesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any drink to save it here.'**
  String get noFavouritesHint;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String addItem(String name);

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @addFavourite.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get addFavourite;

  /// No description provided for @removeFavourite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get removeFavourite;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get soldOut;

  /// No description provided for @productMissing.
  ///
  /// In en, this message translates to:
  /// **'This item is no longer on the menu.'**
  String get productMissing;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note for the barista (optional)'**
  String get note;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. extra hot, no lid'**
  String get noteHint;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increase;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'{name} added to cart'**
  String added(String name);

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String removed(String name);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @yourCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart'**
  String get yourCart;

  /// No description provided for @each.
  ///
  /// In en, this message translates to:
  /// **'{price} each'**
  String each(String price);

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add more items'**
  String get addMore;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @toCheckout.
  ///
  /// In en, this message translates to:
  /// **'Go to checkout'**
  String get toCheckout;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @browseMenu.
  ///
  /// In en, this message translates to:
  /// **'Browse the menu'**
  String get browseMenu;

  /// No description provided for @noteLine.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String noteLine(String note);

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removeItem(String name);

  /// No description provided for @decreaseOf.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity of {name}'**
  String decreaseOf(String name);

  /// No description provided for @increaseOf.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity of {name}'**
  String increaseOf(String name);

  /// No description provided for @earnPoints.
  ///
  /// In en, this message translates to:
  /// **'You’ll earn {points} points with this order'**
  String earnPoints(int points);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming in a later version'**
  String get comingSoon;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No past orders yet'**
  String get noOrders;

  /// No description provided for @noOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'Orders you place will show here, so you can track them and order again.'**
  String get noOrdersHint;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @how1.
  ///
  /// In en, this message translates to:
  /// **'Earn 1 point for every \$1 you pay'**
  String get how1;

  /// No description provided for @how2.
  ///
  /// In en, this message translates to:
  /// **'50 points = 1 free drink'**
  String get how2;

  /// No description provided for @how3.
  ///
  /// In en, this message translates to:
  /// **'We take your most expensive drink off the bill'**
  String get how3;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @orderAlerts.
  ///
  /// In en, this message translates to:
  /// **'Order-ready alerts'**
  String get orderAlerts;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemCount(int count);
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'km':
      return L10nKm();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
