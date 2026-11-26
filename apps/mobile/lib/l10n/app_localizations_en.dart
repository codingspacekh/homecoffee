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
  String get comingSoon => 'Coming in a later version';

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
}
