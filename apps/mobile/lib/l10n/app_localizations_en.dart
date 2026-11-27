// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get skip => 'Skip';

  @override
  String get continueLabel => 'Continue';

  @override
  String get turnOnNotifications => 'Turn on notifications';

  @override
  String get notNow => 'Not now';

  @override
  String stepOf(int step) {
    return 'Step $step of 4';
  }

  @override
  String get welcomeTitle => 'Welcome to HomeCoffee';

  @override
  String get welcomeBody =>
      'Pick your language. You can change it any time in Account.';

  @override
  String get orderAheadTitle => 'Order ahead, skip the line';

  @override
  String get orderAheadBody =>
      'Choose your drink, pick a pickup time, and collect it at the counter when it’s ready.';

  @override
  String get pointsTitle => 'Every dollar earns a point';

  @override
  String get pointsBody => 'Collect 50 points and your next drink is on us.';

  @override
  String get pointsSample => '+5 points';

  @override
  String get notifyTitle => 'Know when it’s ready';

  @override
  String get notifyBody =>
      'We send one notification when your order is ready to pick up, and nothing else.';

  @override
  String get yourPoints => 'Your points';

  @override
  String get sampleNotificationTitle => 'Order #1042 is ready';

  @override
  String get sampleNotificationBody => 'Come and pick it up at the counter.';

  @override
  String get now => 'now';

  @override
  String get showWelcomeAgain => 'Show welcome screens again';

  @override
  String get tabMenu => 'Menu';

  @override
  String get tabOrders => 'Orders';

  @override
  String get tabRewards => 'Rewards';

  @override
  String get tabAccount => 'Account';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String readyIn(int minutes) {
    return 'Ready for pickup in about $minutes min';
  }

  @override
  String get closedNow => 'We’re closed right now. You can still look around.';

  @override
  String get menuError =>
      'We couldn’t load the menu. Check your connection and try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get search => 'Search the menu';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get categories => 'Categories';

  @override
  String get all => 'All';

  @override
  String get favourites => 'Favourites';

  @override
  String noResults(String query) {
    return 'No items match “$query”';
  }

  @override
  String get noResultsHint => 'Try another word or category.';

  @override
  String get noFavourites => 'No favourites yet';

  @override
  String get noFavouritesHint => 'Tap the heart on any drink to save it here.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String addItem(String name) {
    return 'Add $name';
  }

  @override
  String get viewCart => 'View cart';

  @override
  String get back => 'Back';

  @override
  String get addFavourite => 'Add to favourites';

  @override
  String get removeFavourite => 'Remove from favourites';

  @override
  String get soldOut => 'Sold out';

  @override
  String get productMissing => 'This item is no longer on the menu.';

  @override
  String get note => 'Note for the barista (optional)';

  @override
  String get noteHint => 'e.g. extra hot, no lid';

  @override
  String get quantity => 'Quantity';

  @override
  String get decrease => 'Decrease quantity';

  @override
  String get increase => 'Increase quantity';

  @override
  String get addToCart => 'Add to cart';

  @override
  String added(String name) {
    return '$name added to cart';
  }

  @override
  String removed(String name) {
    return '$name removed';
  }

  @override
  String get undo => 'Undo';

  @override
  String get yourCart => 'Your cart';

  @override
  String each(String price) {
    return '$price each';
  }

  @override
  String get addMore => 'Add more items';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get toCheckout => 'Go to checkout';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get browseMenu => 'Browse the menu';

  @override
  String noteLine(String note) {
    return 'Note: $note';
  }

  @override
  String removeItem(String name) {
    return 'Remove $name';
  }

  @override
  String decreaseOf(String name) {
    return 'Decrease quantity of $name';
  }

  @override
  String increaseOf(String name) {
    return 'Increase quantity of $name';
  }

  @override
  String earnPoints(int points) {
    return 'You’ll earn $points points with this order';
  }

  @override
  String get noOrders => 'No past orders yet';

  @override
  String get noOrdersHint =>
      'Orders you place will show here, so you can track them and order again.';

  @override
  String get howItWorks => 'How it works';

  @override
  String get how1 => 'Earn 1 point for every \$1 you pay';

  @override
  String get how2 => '50 points = 1 free drink';

  @override
  String get how3 => 'We take your most expensive drink off the bill';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get orderAlerts => 'Order-ready alerts';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get checkout => 'Checkout';

  @override
  String get pickupTime => 'Pickup time';

  @override
  String get asap => 'As soon as possible';

  @override
  String readyInAbout(int minutes) {
    return 'Ready in about $minutes min';
  }

  @override
  String get scheduleLater => 'Schedule for later';

  @override
  String get chooseTimeBelow => 'Choose a time below';

  @override
  String get noSlotsToday => 'No more pickup times today';

  @override
  String get yourDetails => 'Your details';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone number';

  @override
  String get phoneHelp => 'We only call if there’s a problem with your order.';

  @override
  String get errName => 'Please enter your name';

  @override
  String get errPhoneMissing => 'Please enter your phone number';

  @override
  String get errPhone => 'Please enter a valid phone number';

  @override
  String get rewardsPromo => 'Rewards and promo code';

  @override
  String useReward(String amount) {
    return 'Use my free drink (−$amount)';
  }

  @override
  String get freeDrink => 'Free drink';

  @override
  String get promo => 'Promo code';

  @override
  String get apply => 'Apply';

  @override
  String promoApplied(String code) {
    return '$code applied';
  }

  @override
  String promoLine(String code) {
    return 'Promo $code';
  }

  @override
  String removePromo(String code) {
    return 'Remove promo code $code';
  }

  @override
  String get errPromoEmpty => 'Please enter a promo code';

  @override
  String get errPromoUnknown => 'That code isn’t valid';

  @override
  String errPromoMin(String code, String minimum) {
    return '$code needs an order of $minimum or more';
  }

  @override
  String remainingPoints(int count) {
    return '$count more points for a free drink';
  }

  @override
  String get haveReward => 'You have a free drink! Turn it on at checkout.';

  @override
  String get payment => 'Payment';

  @override
  String get payCounter => 'Pay at the counter';

  @override
  String get payKhqr => 'Pay with KHQR';

  @override
  String get soon => 'Coming soon';

  @override
  String get summary => 'Order summary';

  @override
  String get total => 'Total';

  @override
  String get placeOrder => 'Place order';

  @override
  String get checkFields => 'Please check the highlighted fields';

  @override
  String get statusTitle => 'Order status';

  @override
  String get showNumber => 'Show this number at the counter';

  @override
  String get statusReceived => 'Received';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusCollected => 'Picked up';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String receivedText(String time) {
    return 'We’ve got your order. Ready around $time.';
  }

  @override
  String preparingText(String time) {
    return 'We’re making your order. Ready around $time.';
  }

  @override
  String get readyText => 'Your order is ready to pick up!';

  @override
  String get collectedText => 'Picked up. Enjoy!';

  @override
  String get cancelledText => 'This order was cancelled.';

  @override
  String get pickupAsap => 'Pickup as soon as possible';

  @override
  String pickupAt(String time) {
    return 'Pickup at $time';
  }

  @override
  String get notifyMe => 'Notify me when it’s ready';

  @override
  String earnedTitle(int points) {
    return '+$points points';
  }

  @override
  String earnedBody(int balance) {
    return 'You now have $balance points.';
  }

  @override
  String get rewardReady =>
      'You’ve earned a free drink! Use it on your next order.';

  @override
  String get items => 'Items';

  @override
  String get backToMenu => 'Back to menu';

  @override
  String get close => 'Close';

  @override
  String get cancelOrder => 'Cancel order';

  @override
  String get cancelOrderTitle => 'Cancel this order?';

  @override
  String get cancelOrderBody =>
      'The barista hasn’t started it yet. A free drink you used goes back to your points.';

  @override
  String get keepOrder => 'Keep order';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get orderMissing => 'We couldn’t load this order.';

  @override
  String get inProgress => 'In progress';

  @override
  String get pastOrders => 'Past orders';

  @override
  String get track => 'Track';

  @override
  String get reorder => 'Reorder';

  @override
  String reorderLabel(int number) {
    return 'Reorder order #$number';
  }

  @override
  String reordered(int number) {
    return 'Order #$number added to cart';
  }

  @override
  String get reorderMissing => 'Those items aren’t on the menu now';

  @override
  String get loadMore => 'Show more';

  @override
  String pointsOutOf(int total) {
    return '/ $total points';
  }

  @override
  String get pointsLabel => 'Points';

  @override
  String get pointsHistory => 'Points history';

  @override
  String orderNumber(int number) {
    return 'Order #$number';
  }

  @override
  String get rewardUsed => 'Free drink used';

  @override
  String get rewardRefunded => 'Free drink given back';

  @override
  String get pointsAdjusted => 'Changed by the shop';

  @override
  String get noPointsYet => 'No points yet. Your first order starts it.';

  @override
  String get edit => 'Edit';

  @override
  String get signOut => 'Sign out';

  @override
  String get forgetRow => 'Forget my data';

  @override
  String get forgetTitle => 'Forget your data?';

  @override
  String get forgetBody =>
      'This deletes your account, points and favourites. Past orders stay in the shop’s records without your name or phone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get forget => 'Forget';

  @override
  String get forgotten => 'Your data was removed';

  @override
  String get addName => 'Add your name';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInTitle => 'Sign in to order';

  @override
  String get signInBody =>
      'Enter your email and we’ll send you a 6-digit code. No password needed.';

  @override
  String get signInHint =>
      'Sign in to keep your points and see your orders on any phone.';

  @override
  String get email => 'Email';

  @override
  String get sendCode => 'Send code';

  @override
  String get errEmail => 'Please enter a valid email address';

  @override
  String get codeTitle => 'Check your email';

  @override
  String codeBody(String email) {
    return 'We sent a 6-digit code to $email. It works for 10 minutes.';
  }

  @override
  String get code => 'Code';

  @override
  String get errCode => 'Please enter the 6 digits from the email';

  @override
  String errCodeWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'That code isn’t right. $count tries left.',
      one: 'That code isn’t right. 1 try left.',
      zero: 'That code isn’t right. Send a new code.',
    );
    return '$_temp0';
  }

  @override
  String get errCodeExpired => 'This code has expired. Send a new one.';

  @override
  String get sendNewCode => 'Send a new code';

  @override
  String get codeSent => 'We sent a new code';

  @override
  String get otherEmail => 'Use another email';

  @override
  String get errOffline => 'No connection. Check your internet and try again.';

  @override
  String get errTooMany => 'Too many tries. Please wait a minute.';

  @override
  String get errServer => 'Something went wrong. Please try again.';

  @override
  String get errSignedOut => 'Please sign in again.';

  @override
  String errItemUnavailable(String name) {
    return '$name is sold out now. Remove it to continue.';
  }

  @override
  String get errNoPoints => 'You don’t have enough points for a free drink.';

  @override
  String get errStoreClosed =>
      'The shop is closed right now. Choose a pickup time later today.';

  @override
  String get errOrdersPaused =>
      'The shop isn’t taking app orders right now. Please try again soon.';

  @override
  String get errPickupTime =>
      'Please choose a later pickup time while the shop is open.';

  @override
  String get errNotCancellable =>
      'The barista has started this order, so it can’t be cancelled now.';

  @override
  String get alertsBlocked =>
      'Notifications are off for HomeCoffee. Turn them on in your phone’s settings.';

  @override
  String get viewOrder => 'View';
}
