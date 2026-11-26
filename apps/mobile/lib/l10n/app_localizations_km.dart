// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class L10nKm extends L10n {
  L10nKm([String locale = 'km']) : super(locale);

  @override
  String get skip => 'រំលង';

  @override
  String get continueLabel => 'បន្ត';

  @override
  String get turnOnNotifications => 'បើកការជូនដំណឹង';

  @override
  String get notNow => 'មិនមែនឥឡូវនេះ';

  @override
  String stepOf(int step) {
    return 'ជំហាន $step នៃ 4';
  }

  @override
  String get welcomeTitle => 'សូមស្វាគមន៍មកកាន់ HomeCoffee';

  @override
  String get welcomeBody =>
      'ជ្រើសរើសភាសារបស់អ្នក។ អ្នកអាចប្តូរវាបានគ្រប់ពេលនៅក្នុងគណនី។';

  @override
  String get orderAheadTitle => 'បញ្ជាទិញមុន មិនបាច់តម្រង់ជួរ';

  @override
  String get orderAheadBody =>
      'ជ្រើសរើសភេសជ្ជៈ កំណត់ម៉ោងមកយក ហើយមកយកនៅបញ្ជរពេលវារួចរាល់។';

  @override
  String get pointsTitle => 'រាល់ \$1 ទទួលបាន 1 ពិន្ទុ';

  @override
  String get pointsBody =>
      'សន្សំបាន 50 ពិន្ទុ ហើយភេសជ្ជៈបន្ទាប់របស់អ្នកគឺឥតគិតថ្លៃ។';

  @override
  String get pointsSample => '+5 ពិន្ទុ';

  @override
  String get notifyTitle => 'ដឹងភ្លាមពេលរួចរាល់';

  @override
  String get notifyBody =>
      'យើងផ្ញើការជូនដំណឹងតែមួយ ពេលការបញ្ជាទិញរបស់អ្នករួចរាល់ ហើយគ្មានអ្វីផ្សេងទៀតទេ។';

  @override
  String get yourPoints => 'ពិន្ទុរបស់អ្នក';

  @override
  String get sampleNotificationTitle => 'ការបញ្ជាទិញ #1042 រួចរាល់ហើយ';

  @override
  String get sampleNotificationBody => 'សូមអញ្ជើញមកយកនៅបញ្ជរ។';

  @override
  String get now => 'ឥឡូវ';

  @override
  String get showWelcomeAgain => 'បង្ហាញទំព័រស្វាគមន៍ម្តងទៀត';

  @override
  String get tabMenu => 'ម៉ឺនុយ';

  @override
  String get tabOrders => 'ការបញ្ជាទិញ';

  @override
  String get tabRewards => 'រង្វាន់';

  @override
  String get tabAccount => 'គណនី';

  @override
  String get goodMorning => 'អរុណសួស្តី';

  @override
  String get goodAfternoon => 'ទិវាសួស្តី';

  @override
  String get goodEvening => 'សាយណ្ហសួស្តី';

  @override
  String readyIn(int minutes) {
    return 'រួចរាល់សម្រាប់មកយកក្នុងប្រហែល $minutes នាទី';
  }

  @override
  String get closedNow => 'ហាងបិទនៅពេលនេះ។ អ្នកនៅតែអាចមើលម៉ឺនុយបាន។';

  @override
  String get menuError =>
      'មិនអាចផ្ទុកម៉ឺនុយបានទេ។ សូមពិនិត្យការតភ្ជាប់ ហើយព្យាយាមម្តងទៀត។';

  @override
  String get tryAgain => 'ព្យាយាមម្តងទៀត';

  @override
  String get search => 'ស្វែងរកក្នុងម៉ឺនុយ';

  @override
  String get clearSearch => 'សម្អាតការស្វែងរក';

  @override
  String get categories => 'ប្រភេទ';

  @override
  String get all => 'ទាំងអស់';

  @override
  String get favourites => 'ចំណូលចិត្ត';

  @override
  String noResults(String query) {
    return 'រកមិនឃើញអ្វីដែលត្រូវនឹង “$query” ទេ';
  }

  @override
  String get noResultsHint => 'សាកល្បងពាក្យ ឬប្រភេទផ្សេង។';

  @override
  String get noFavourites => 'មិនទាន់មានចំណូលចិត្តនៅឡើយទេ';

  @override
  String get noFavouritesHint =>
      'ចុចរូបបេះដូងលើភេសជ្ជៈណាមួយ ដើម្បីរក្សាទុកវានៅទីនេះ។';

  @override
  String get clearFilters => 'សម្អាតតម្រង';

  @override
  String addItem(String name) {
    return 'បន្ថែម $name';
  }

  @override
  String get viewCart => 'មើលកន្ត្រក';

  @override
  String get back => 'ត្រឡប់';

  @override
  String get addFavourite => 'បន្ថែមទៅចំណូលចិត្ត';

  @override
  String get removeFavourite => 'ដកចេញពីចំណូលចិត្ត';

  @override
  String get soldOut => 'អស់ហើយ';

  @override
  String get productMissing => 'មុខទំនិញនេះលែងមាននៅក្នុងម៉ឺនុយទៀតហើយ។';

  @override
  String get note => 'កំណត់សម្គាល់សម្រាប់បារីស្តា (ស្រេចចិត្ត)';

  @override
  String get noteHint => 'ឧ. ក្តៅខ្លាំង គ្មានគម្រប';

  @override
  String get quantity => 'ចំនួន';

  @override
  String get decrease => 'បន្ថយចំនួន';

  @override
  String get increase => 'បង្កើនចំនួន';

  @override
  String get addToCart => 'ដាក់ចូលកន្ត្រក';

  @override
  String added(String name) {
    return 'បានដាក់ $name ចូលកន្ត្រក';
  }

  @override
  String removed(String name) {
    return 'បានដក $name ចេញ';
  }

  @override
  String get undo => 'មិនធ្វើវិញ';

  @override
  String get yourCart => 'កន្ត្រករបស់អ្នក';

  @override
  String each(String price) {
    return '$price ក្នុងមួយ';
  }

  @override
  String get addMore => 'បន្ថែមមុខទំនិញទៀត';

  @override
  String get subtotal => 'សរុបរង';

  @override
  String get toCheckout => 'បន្តទៅការទូទាត់';

  @override
  String get cartEmpty => 'កន្ត្រករបស់អ្នកនៅទទេ';

  @override
  String get browseMenu => 'មើលម៉ឺនុយ';

  @override
  String noteLine(String note) {
    return 'កំណត់សម្គាល់៖ $note';
  }

  @override
  String removeItem(String name) {
    return 'ដក $name ចេញ';
  }

  @override
  String decreaseOf(String name) {
    return 'បន្ថយចំនួន $name';
  }

  @override
  String increaseOf(String name) {
    return 'បង្កើនចំនួន $name';
  }

  @override
  String earnPoints(int points) {
    return 'អ្នកនឹងទទួលបាន $points ពិន្ទុ ពីការបញ្ជាទិញនេះ';
  }

  @override
  String get comingSoon => 'នឹងមាននៅកំណែក្រោយ';

  @override
  String get noOrders => 'មិនទាន់មានការបញ្ជាទិញពីមុនទេ';

  @override
  String get noOrdersHint =>
      'ការបញ្ជាទិញរបស់អ្នកនឹងបង្ហាញនៅទីនេះ ដើម្បីតាមដាន និងបញ្ជាទិញម្តងទៀត។';

  @override
  String get howItWorks => 'របៀបដំណើរការ';

  @override
  String get how1 => 'ទទួលបាន 1 ពិន្ទុ រាល់ការបង់ \$1';

  @override
  String get how2 => '50 ពិន្ទុ = ភេសជ្ជៈឥតគិតថ្លៃ 1';

  @override
  String get how3 => 'យើងដកតម្លៃភេសជ្ជៈដែលថ្លៃជាងគេចេញពីវិក្កយបត្រ';

  @override
  String get settings => 'ការកំណត់';

  @override
  String get language => 'ភាសា';

  @override
  String get appearance => 'រូបរាង';

  @override
  String get themeSystem => 'តាមប្រព័ន្ធ';

  @override
  String get themeLight => 'ភ្លឺ';

  @override
  String get themeDark => 'ងងឹត';

  @override
  String get orderAlerts => 'ជូនដំណឹងពេលរួចរាល់';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count មុខ',
    );
    return '$_temp0';
  }
}
