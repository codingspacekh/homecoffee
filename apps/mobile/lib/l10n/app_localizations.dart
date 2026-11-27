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

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

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

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @pickupTime.
  ///
  /// In en, this message translates to:
  /// **'Pickup time'**
  String get pickupTime;

  /// No description provided for @asap.
  ///
  /// In en, this message translates to:
  /// **'As soon as possible'**
  String get asap;

  /// No description provided for @readyInAbout.
  ///
  /// In en, this message translates to:
  /// **'Ready in about {minutes} min'**
  String readyInAbout(int minutes);

  /// No description provided for @scheduleLater.
  ///
  /// In en, this message translates to:
  /// **'Schedule for later'**
  String get scheduleLater;

  /// No description provided for @chooseTimeBelow.
  ///
  /// In en, this message translates to:
  /// **'Choose a time below'**
  String get chooseTimeBelow;

  /// No description provided for @noSlotsToday.
  ///
  /// In en, this message translates to:
  /// **'No more pickup times today'**
  String get noSlotsToday;

  /// No description provided for @yourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get yourDetails;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @phoneHelp.
  ///
  /// In en, this message translates to:
  /// **'We only call if there’s a problem with your order.'**
  String get phoneHelp;

  /// No description provided for @errName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get errName;

  /// No description provided for @errPhoneMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get errPhoneMissing;

  /// No description provided for @errPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get errPhone;

  /// No description provided for @rewardsPromo.
  ///
  /// In en, this message translates to:
  /// **'Rewards and promo code'**
  String get rewardsPromo;

  /// No description provided for @useReward.
  ///
  /// In en, this message translates to:
  /// **'Use my free drink (−{amount})'**
  String useReward(String amount);

  /// No description provided for @freeDrink.
  ///
  /// In en, this message translates to:
  /// **'Free drink'**
  String get freeDrink;

  /// No description provided for @promo.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get promo;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @promoApplied.
  ///
  /// In en, this message translates to:
  /// **'{code} applied'**
  String promoApplied(String code);

  /// No description provided for @promoLine.
  ///
  /// In en, this message translates to:
  /// **'Promo {code}'**
  String promoLine(String code);

  /// No description provided for @removePromo.
  ///
  /// In en, this message translates to:
  /// **'Remove promo code {code}'**
  String removePromo(String code);

  /// No description provided for @errPromoEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a promo code'**
  String get errPromoEmpty;

  /// No description provided for @errPromoUnknown.
  ///
  /// In en, this message translates to:
  /// **'That code isn’t valid'**
  String get errPromoUnknown;

  /// No description provided for @errPromoUsed.
  ///
  /// In en, this message translates to:
  /// **'You’ve already used this code'**
  String get errPromoUsed;

  /// No description provided for @errPromoMin.
  ///
  /// In en, this message translates to:
  /// **'{code} needs an order of {minimum} or more'**
  String errPromoMin(String code, String minimum);

  /// No description provided for @remainingPoints.
  ///
  /// In en, this message translates to:
  /// **'{count} more points for a free drink'**
  String remainingPoints(int count);

  /// No description provided for @haveReward.
  ///
  /// In en, this message translates to:
  /// **'You have a free drink! Turn it on at checkout.'**
  String get haveReward;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @payCounter.
  ///
  /// In en, this message translates to:
  /// **'Pay at the counter'**
  String get payCounter;

  /// No description provided for @payKhqr.
  ///
  /// In en, this message translates to:
  /// **'Pay with KHQR'**
  String get payKhqr;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get soon;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get summary;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @checkFields.
  ///
  /// In en, this message translates to:
  /// **'Please check the highlighted fields'**
  String get checkFields;

  /// No description provided for @statusTitle.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get statusTitle;

  /// No description provided for @showNumber.
  ///
  /// In en, this message translates to:
  /// **'Show this number at the counter'**
  String get showNumber;

  /// No description provided for @statusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get statusReceived;

  /// No description provided for @statusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusCollected.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get statusCollected;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @receivedText.
  ///
  /// In en, this message translates to:
  /// **'We’ve got your order. Ready around {time}.'**
  String receivedText(String time);

  /// No description provided for @preparingText.
  ///
  /// In en, this message translates to:
  /// **'We’re making your order. Ready around {time}.'**
  String preparingText(String time);

  /// No description provided for @readyText.
  ///
  /// In en, this message translates to:
  /// **'Your order is ready to pick up!'**
  String get readyText;

  /// No description provided for @collectedText.
  ///
  /// In en, this message translates to:
  /// **'Picked up. Enjoy!'**
  String get collectedText;

  /// No description provided for @cancelledText.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled.'**
  String get cancelledText;

  /// No description provided for @pickupAsap.
  ///
  /// In en, this message translates to:
  /// **'Pickup as soon as possible'**
  String get pickupAsap;

  /// No description provided for @pickupAt.
  ///
  /// In en, this message translates to:
  /// **'Pickup at {time}'**
  String pickupAt(String time);

  /// No description provided for @notifyMe.
  ///
  /// In en, this message translates to:
  /// **'Notify me when it’s ready'**
  String get notifyMe;

  /// No description provided for @earnedTitle.
  ///
  /// In en, this message translates to:
  /// **'+{points} points'**
  String earnedTitle(int points);

  /// No description provided for @earnedBody.
  ///
  /// In en, this message translates to:
  /// **'You now have {balance} points.'**
  String earnedBody(int balance);

  /// No description provided for @rewardReady.
  ///
  /// In en, this message translates to:
  /// **'You’ve earned a free drink! Use it on your next order.'**
  String get rewardReady;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to menu'**
  String get backToMenu;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order?'**
  String get cancelOrderTitle;

  /// No description provided for @cancelOrderBody.
  ///
  /// In en, this message translates to:
  /// **'The barista hasn’t started it yet. A free drink you used goes back to your points.'**
  String get cancelOrderBody;

  /// No description provided for @keepOrder.
  ///
  /// In en, this message translates to:
  /// **'Keep order'**
  String get keepOrder;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @orderMissing.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load this order.'**
  String get orderMissing;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @pastOrders.
  ///
  /// In en, this message translates to:
  /// **'Past orders'**
  String get pastOrders;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @reorderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reorder order #{number}'**
  String reorderLabel(int number);

  /// No description provided for @reordered.
  ///
  /// In en, this message translates to:
  /// **'Order #{number} added to cart'**
  String reordered(int number);

  /// No description provided for @reorderMissing.
  ///
  /// In en, this message translates to:
  /// **'Those items aren’t on the menu now'**
  String get reorderMissing;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get loadMore;

  /// No description provided for @pointsOutOf.
  ///
  /// In en, this message translates to:
  /// **'/ {total} points'**
  String pointsOutOf(int total);

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsLabel;

  /// No description provided for @pointsHistory.
  ///
  /// In en, this message translates to:
  /// **'Points history'**
  String get pointsHistory;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderNumber(int number);

  /// No description provided for @rewardUsed.
  ///
  /// In en, this message translates to:
  /// **'Free drink used'**
  String get rewardUsed;

  /// No description provided for @rewardRefunded.
  ///
  /// In en, this message translates to:
  /// **'Free drink given back'**
  String get rewardRefunded;

  /// No description provided for @pointsAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Changed by the shop'**
  String get pointsAdjusted;

  /// No description provided for @pointsAtCounter.
  ///
  /// In en, this message translates to:
  /// **'Paid at the counter'**
  String get pointsAtCounter;

  /// No description provided for @memberCard.
  ///
  /// In en, this message translates to:
  /// **'Member card'**
  String get memberCard;

  /// No description provided for @memberCardHint.
  ///
  /// In en, this message translates to:
  /// **'Paying at the counter? Show this code and the barista adds your points.'**
  String get memberCardHint;

  /// No description provided for @memberCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Member code'**
  String get memberCodeLabel;

  /// No description provided for @noPointsYet.
  ///
  /// In en, this message translates to:
  /// **'No points yet. Your first order starts it.'**
  String get noPointsYet;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @forgetRow.
  ///
  /// In en, this message translates to:
  /// **'Forget my data'**
  String get forgetRow;

  /// No description provided for @forgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Forget your data?'**
  String get forgetTitle;

  /// No description provided for @forgetBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes your account, points and favourites. Past orders stay in the shop’s records without your name or phone.'**
  String get forgetBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @forget.
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get forget;

  /// No description provided for @forgotten.
  ///
  /// In en, this message translates to:
  /// **'Your data was removed'**
  String get forgotten;

  /// No description provided for @addName.
  ///
  /// In en, this message translates to:
  /// **'Add your name'**
  String get addName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to order'**
  String get signInTitle;

  /// No description provided for @signInBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we’ll send you a 6-digit code. No password needed.'**
  String get signInBody;

  /// No description provided for @signInHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep your points and see your orders on any phone.'**
  String get signInHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @errEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get errEmail;

  /// No description provided for @codeTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get codeTitle;

  /// No description provided for @codeBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}. It works for 10 minutes.'**
  String codeBody(String email);

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @errCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6 digits from the email'**
  String get errCode;

  /// No description provided for @errCodeWrong.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{That code isn’t right. Send a new code.} =1{That code isn’t right. 1 try left.} other{That code isn’t right. {count} tries left.}}'**
  String errCodeWrong(int count);

  /// No description provided for @errCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Send a new one.'**
  String get errCodeExpired;

  /// No description provided for @sendNewCode.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get sendNewCode;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a new code'**
  String get codeSent;

  /// No description provided for @otherEmail.
  ///
  /// In en, this message translates to:
  /// **'Use another email'**
  String get otherEmail;

  /// No description provided for @errOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get errOffline;

  /// No description provided for @errTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Please wait a minute.'**
  String get errTooMany;

  /// No description provided for @errServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errServer;

  /// No description provided for @errSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get errSignedOut;

  /// No description provided for @errItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{name} is sold out now. Remove it to continue.'**
  String errItemUnavailable(String name);

  /// No description provided for @errNoPoints.
  ///
  /// In en, this message translates to:
  /// **'You don’t have enough points for a free drink.'**
  String get errNoPoints;

  /// No description provided for @errStoreClosed.
  ///
  /// In en, this message translates to:
  /// **'The shop is closed right now. Choose a pickup time later today.'**
  String get errStoreClosed;

  /// No description provided for @errOrdersPaused.
  ///
  /// In en, this message translates to:
  /// **'The shop isn’t taking app orders right now. Please try again soon.'**
  String get errOrdersPaused;

  /// No description provided for @errPickupTime.
  ///
  /// In en, this message translates to:
  /// **'Please choose a later pickup time while the shop is open.'**
  String get errPickupTime;

  /// No description provided for @errNotCancellable.
  ///
  /// In en, this message translates to:
  /// **'The barista has started this order, so it can’t be cancelled now.'**
  String get errNotCancellable;

  /// Snack bar when the customer turns on order alerts but said no to notifications on the system prompt
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for HomeCoffee. Turn them on in your phone’s settings.'**
  String get alertsBlocked;

  /// Snack bar button that opens the order whose ready notification arrived while the app was open
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewOrder;
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
