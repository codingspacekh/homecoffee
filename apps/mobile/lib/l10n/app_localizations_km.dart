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

  @override
  String get checkout => 'ការទូទាត់';

  @override
  String get pickupTime => 'ម៉ោងមកយក';

  @override
  String get asap => 'ឱ្យបានឆាប់បំផុត';

  @override
  String readyInAbout(int minutes) {
    return 'រួចរាល់ក្នុងប្រហែល $minutes នាទី';
  }

  @override
  String get scheduleLater => 'កំណត់ម៉ោងមកយក';

  @override
  String get chooseTimeBelow => 'ជ្រើសរើសម៉ោងខាងក្រោម';

  @override
  String get noSlotsToday => 'ថ្ងៃនេះគ្មានម៉ោងមកយកទៀតទេ';

  @override
  String get yourDetails => 'ព័ត៌មានរបស់អ្នក';

  @override
  String get name => 'ឈ្មោះ';

  @override
  String get phone => 'លេខទូរស័ព្ទ';

  @override
  String get phoneHelp =>
      'យើងនឹងទូរស័ព្ទមកតែពេលមានបញ្ហាជាមួយការបញ្ជាទិញប៉ុណ្ណោះ។';

  @override
  String get errName => 'សូមបញ្ចូលឈ្មោះរបស់អ្នក';

  @override
  String get errPhoneMissing => 'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក';

  @override
  String get errPhone => 'សូមបញ្ចូលលេខទូរស័ព្ទឱ្យបានត្រឹមត្រូវ';

  @override
  String get rewardsPromo => 'រង្វាន់ និងលេខកូដបញ្ចុះតម្លៃ';

  @override
  String useReward(String amount) {
    return 'ប្រើភេសជ្ជៈឥតគិតថ្លៃរបស់ខ្ញុំ (−$amount)';
  }

  @override
  String get freeDrink => 'ភេសជ្ជៈឥតគិតថ្លៃ';

  @override
  String get promo => 'លេខកូដបញ្ចុះតម្លៃ';

  @override
  String get apply => 'ប្រើ';

  @override
  String promoApplied(String code) {
    return 'បានប្រើ $code';
  }

  @override
  String promoLine(String code) {
    return 'បញ្ចុះតម្លៃ $code';
  }

  @override
  String removePromo(String code) {
    return 'ដកលេខកូដបញ្ចុះតម្លៃ $code ចេញ';
  }

  @override
  String get errPromoEmpty => 'សូមបញ្ចូលលេខកូដបញ្ចុះតម្លៃ';

  @override
  String get errPromoUnknown => 'លេខកូដនេះមិនត្រឹមត្រូវទេ';

  @override
  String errPromoMin(String code, String minimum) {
    return '$code ត្រូវការការបញ្ជាទិញចាប់ពី $minimum ឡើងទៅ';
  }

  @override
  String remainingPoints(int count) {
    return 'ត្រូវការ $count ពិន្ទុទៀត ដើម្បីទទួលបានភេសជ្ជៈឥតគិតថ្លៃ';
  }

  @override
  String get haveReward => 'អ្នកមានភេសជ្ជៈឥតគិតថ្លៃ! បើកវានៅពេលទូទាត់។';

  @override
  String get payment => 'ការបង់ប្រាក់';

  @override
  String get payCounter => 'បង់ប្រាក់នៅបញ្ជរ';

  @override
  String get payKhqr => 'បង់ប្រាក់តាម KHQR';

  @override
  String get soon => 'នឹងមានឆាប់ៗ';

  @override
  String get summary => 'សង្ខេបការបញ្ជាទិញ';

  @override
  String get total => 'សរុប';

  @override
  String get placeOrder => 'បញ្ជាទិញ';

  @override
  String get checkFields => 'សូមពិនិត្យប្រអប់ដែលបានសម្គាល់';

  @override
  String get statusTitle => 'ស្ថានភាពការបញ្ជាទិញ';

  @override
  String get showNumber => 'សូមបង្ហាញលេខនេះនៅបញ្ជរ';

  @override
  String get statusReceived => 'បានទទួល';

  @override
  String get statusPreparing => 'កំពុងរៀបចំ';

  @override
  String get statusReady => 'រួចរាល់';

  @override
  String get statusCollected => 'បានមកយកហើយ';

  @override
  String get statusCancelled => 'បានបោះបង់';

  @override
  String receivedText(String time) {
    return 'យើងបានទទួលការបញ្ជាទិញរបស់អ្នកហើយ។ នឹងរួចរាល់ប្រហែលម៉ោង $time។';
  }

  @override
  String preparingText(String time) {
    return 'យើងកំពុងរៀបចំការបញ្ជាទិញរបស់អ្នក។ នឹងរួចរាល់ប្រហែលម៉ោង $time។';
  }

  @override
  String get readyText => 'ការបញ្ជាទិញរបស់អ្នករួចរាល់ហើយ សូមអញ្ជើញមកយក!';

  @override
  String get collectedText => 'បានមកយកហើយ។ សូមរីករាយ!';

  @override
  String get cancelledText => 'ការបញ្ជាទិញនេះត្រូវបានបោះបង់។';

  @override
  String get pickupAsap => 'មកយកឱ្យបានឆាប់បំផុត';

  @override
  String pickupAt(String time) {
    return 'មកយកនៅម៉ោង $time';
  }

  @override
  String get notifyMe => 'ជូនដំណឹងខ្ញុំពេលរួចរាល់';

  @override
  String earnedTitle(int points) {
    return '+$points ពិន្ទុ';
  }

  @override
  String earnedBody(int balance) {
    return 'ឥឡូវអ្នកមាន $balance ពិន្ទុ។';
  }

  @override
  String get rewardReady =>
      'អ្នកទទួលបានភេសជ្ជៈឥតគិតថ្លៃ! ប្រើវានៅការបញ្ជាទិញលើកក្រោយ។';

  @override
  String get items => 'មុខទំនិញ';

  @override
  String get backToMenu => 'ត្រឡប់ទៅម៉ឺនុយវិញ';

  @override
  String get close => 'បិទ';

  @override
  String get cancelOrder => 'បោះបង់ការបញ្ជាទិញ';

  @override
  String get cancelOrderTitle => 'បោះបង់ការបញ្ជាទិញនេះ?';

  @override
  String get cancelOrderBody =>
      'បារីស្តាមិនទាន់ចាប់ផ្តើមធ្វើទេ។ ភេសជ្ជៈឥតគិតថ្លៃដែលអ្នកបានប្រើ នឹងត្រឡប់ទៅពិន្ទុរបស់អ្នកវិញ។';

  @override
  String get keepOrder => 'រក្សាការបញ្ជាទិញ';

  @override
  String get orderCancelled => 'បានបោះបង់ការបញ្ជាទិញ';

  @override
  String get orderMissing => 'យើងមិនអាចបើកការបញ្ជាទិញនេះបានទេ។';

  @override
  String get inProgress => 'កំពុងដំណើរការ';

  @override
  String get pastOrders => 'ការបញ្ជាទិញពីមុន';

  @override
  String get track => 'តាមដាន';

  @override
  String get reorder => 'បញ្ជាទិញម្តងទៀត';

  @override
  String reorderLabel(int number) {
    return 'បញ្ជាទិញម្តងទៀតនូវការបញ្ជាទិញ #$number';
  }

  @override
  String reordered(int number) {
    return 'បានដាក់ការបញ្ជាទិញ #$number ចូលកន្ត្រក';
  }

  @override
  String get reorderMissing => 'មុខទំនិញទាំងនោះមិនមាននៅក្នុងម៉ឺនុយឥឡូវនេះទេ';

  @override
  String get loadMore => 'បង្ហាញបន្ថែម';

  @override
  String pointsOutOf(int total) {
    return '/ $total ពិន្ទុ';
  }

  @override
  String get pointsLabel => 'ពិន្ទុ';

  @override
  String get pointsHistory => 'ប្រវត្តិពិន្ទុ';

  @override
  String orderNumber(int number) {
    return 'ការបញ្ជាទិញ #$number';
  }

  @override
  String get rewardUsed => 'បានប្រើភេសជ្ជៈឥតគិតថ្លៃ';

  @override
  String get rewardRefunded => 'បានប្រគល់ភេសជ្ជៈឥតគិតថ្លៃវិញ';

  @override
  String get pointsAdjusted => 'កែប្រែដោយហាង';

  @override
  String get noPointsYet =>
      'មិនទាន់មានពិន្ទុទេ។ ការបញ្ជាទិញដំបូងរបស់អ្នកនឹងចាប់ផ្តើមវា។';

  @override
  String get edit => 'កែប្រែ';

  @override
  String get signOut => 'ចាកចេញ';

  @override
  String get forgetRow => 'លុបទិន្នន័យរបស់ខ្ញុំ';

  @override
  String get forgetTitle => 'លុបទិន្នន័យរបស់អ្នក?';

  @override
  String get forgetBody =>
      'វានឹងលុបគណនី ពិន្ទុ និងចំណូលចិត្តរបស់អ្នក។ ការបញ្ជាទិញពីមុននៅតែមានក្នុងបញ្ជីរបស់ហាង ដោយគ្មានឈ្មោះ ឬលេខទូរស័ព្ទរបស់អ្នក។';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get forget => 'លុប';

  @override
  String get forgotten => 'បានលុបទិន្នន័យរបស់អ្នក';

  @override
  String get addName => 'បន្ថែមឈ្មោះរបស់អ្នក';

  @override
  String get save => 'រក្សាទុក';

  @override
  String get saved => 'បានរក្សាទុក';

  @override
  String get signIn => 'ចូលគណនី';

  @override
  String get signInTitle => 'ចូលគណនីដើម្បីបញ្ជាទិញ';

  @override
  String get signInBody =>
      'បញ្ចូលអ៊ីមែលរបស់អ្នក ហើយយើងនឹងផ្ញើលេខកូដ 6 ខ្ទង់ទៅអ្នក។ មិនត្រូវការពាក្យសម្ងាត់ទេ។';

  @override
  String get signInHint =>
      'ចូលគណនី ដើម្បីរក្សាពិន្ទុ និងមើលការបញ្ជាទិញរបស់អ្នកនៅលើទូរស័ព្ទណាក៏បាន។';

  @override
  String get email => 'អ៊ីមែល';

  @override
  String get sendCode => 'ផ្ញើលេខកូដ';

  @override
  String get errEmail => 'សូមបញ្ចូលអ៊ីមែលឱ្យបានត្រឹមត្រូវ';

  @override
  String get codeTitle => 'សូមពិនិត្យអ៊ីមែលរបស់អ្នក';

  @override
  String codeBody(String email) {
    return 'យើងបានផ្ញើលេខកូដ 6 ខ្ទង់ទៅ $email។ វាប្រើបានរយៈពេល 10 នាទី។';
  }

  @override
  String get code => 'លេខកូដ';

  @override
  String get errCode => 'សូមបញ្ចូលលេខ 6 ខ្ទង់ពីអ៊ីមែល';

  @override
  String errCodeWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'លេខកូដនេះមិនត្រឹមត្រូវទេ។ នៅសល់ $count ដងទៀត។',
      zero: 'លេខកូដនេះមិនត្រឹមត្រូវទេ។ សូមផ្ញើលេខកូដថ្មី។',
    );
    return '$_temp0';
  }

  @override
  String get errCodeExpired => 'លេខកូដនេះផុតកំណត់ហើយ។ សូមផ្ញើលេខកូដថ្មី។';

  @override
  String get sendNewCode => 'ផ្ញើលេខកូដថ្មី';

  @override
  String get codeSent => 'យើងបានផ្ញើលេខកូដថ្មីហើយ';

  @override
  String get otherEmail => 'ប្រើអ៊ីមែលផ្សេង';

  @override
  String get errOffline =>
      'គ្មានការតភ្ជាប់។ សូមពិនិត្យអ៊ីនធឺណិត ហើយព្យាយាមម្តងទៀត។';

  @override
  String get errTooMany => 'ព្យាយាមច្រើនដងពេក។ សូមរង់ចាំមួយនាទី។';

  @override
  String get errServer => 'មានបញ្ហាអ្វីមួយ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get errSignedOut => 'សូមចូលគណនីម្តងទៀត។';

  @override
  String errItemUnavailable(String name) {
    return '$name អស់ហើយ។ សូមដកវាចេញដើម្បីបន្ត។';
  }

  @override
  String get errNoPoints =>
      'អ្នកមិនមានពិន្ទុគ្រប់គ្រាន់សម្រាប់ភេសជ្ជៈឥតគិតថ្លៃទេ។';

  @override
  String get errStoreClosed =>
      'ហាងបិទនៅពេលនេះ។ សូមជ្រើសរើសម៉ោងមកយកនៅពេលក្រោយថ្ងៃនេះ។';

  @override
  String get errOrdersPaused =>
      'ហាងមិនទទួលការបញ្ជាទិញតាមកម្មវិធីនៅពេលនេះទេ។ សូមព្យាយាមម្តងទៀតឆាប់ៗ។';

  @override
  String get errPickupTime => 'សូមជ្រើសរើសម៉ោងមកយកយឺតជាងនេះ ពេលហាងបើក។';

  @override
  String get errNotCancellable =>
      'បារីស្តាបានចាប់ផ្តើមធ្វើការបញ្ជាទិញនេះហើយ ដូច្នេះមិនអាចបោះបង់បានទេ។';
}
