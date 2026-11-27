/// The signed-in customer, from GET /api/v1/me.
class Account {
  const Account({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.language = 'en',
    this.points = 0,
    this.rewardPoints = 50,
    this.memberCode,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'] as int,
    email: json['email'] as String,
    name: json['name'] as String?,
    phone: json['phone'] as String?,
    language: json['language'] as String? ?? 'en',
    points: json['points'] as int? ?? 0,
    rewardPoints: json['reward_points'] as int? ?? 50,
    memberCode: json['member_code'] as String?,
  );

  final int id;
  final String email;
  final String? name;
  final String? phone;
  final String language;
  final int points;

  /// Points for one free drink.
  final int rewardPoints;

  /// 8 digits the barista scans or types to add points for a purchase at
  /// the counter.
  final String? memberCode;

  /// The text inside the member QR. The admin panel reads the 8 digits.
  String? get memberQr =>
      memberCode == null ? null : 'homecoffee:member:$memberCode';

  /// "1234 5678", easier to read out.
  String? get memberCodeLabel => switch (memberCode) {
    final code? when code.length == 8 =>
      '${code.substring(0, 4)} ${code.substring(4)}',
    final code => code,
  };

  bool get hasReward => points >= rewardPoints;

  /// Points still needed for the next free drink.
  int get pointsToReward => hasReward ? 0 : rewardPoints - points;

  Map<String, Object?> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'phone': phone,
    'language': language,
    'points': points,
    'reward_points': rewardPoints,
    'member_code': memberCode,
  };

  Account copyWith({int? points, String? name, String? phone}) => Account(
    id: id,
    email: email,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    language: language,
    points: points ?? this.points,
    rewardPoints: rewardPoints,
    memberCode: memberCode,
  );
}

/// What POST /auth/verify returns.
class SignIn {
  const SignIn({
    required this.token,
    required this.account,
    required this.newAccount,
  });

  factory SignIn.fromJson(Map<String, dynamic> json) => SignIn(
    token: json['token'] as String,
    account: Account.fromJson(json['user'] as Map<String, dynamic>),
    newAccount: json['new_account'] as bool? ?? false,
  );

  final String token;
  final Account account;
  final bool newAccount;
}

enum PointReason {
  order,
  reward,
  refund,

  /// Points for paying at the counter, added by the barista.
  counter,
  adjustment,
}

/// One line of the points history.
class PointEntry {
  const PointEntry({
    required this.id,
    required this.change,
    required this.reason,
    required this.createdAt,
    this.orderNumber,
  });

  factory PointEntry.fromJson(Map<String, dynamic> json) => PointEntry(
    id: json['id'] as int,
    change: json['change'] as int,
    reason:
        PointReason.values.asNameMap()[json['reason']] ??
        PointReason.adjustment,
    orderNumber: json['order_number'] as int?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final int id;
  final int change;
  final PointReason reason;
  final int? orderNumber;
  final DateTime createdAt;
}

/// One page of a list, and the next page number while there are more.
class Paged<T> {
  const Paged(this.items, {this.nextPage});

  final List<T> items;
  final int? nextPage;
}
