import 'package:homecoffee_domain/homecoffee_domain.dart';

/// Where an order is. It only moves forward, except that an order can be
/// cancelled while it is still open.
enum OrderStatus {
  received,
  preparing,
  ready,
  collected,
  cancelled;

  static OrderStatus parse(String value) =>
      values.asNameMap()[value] ?? received;

  /// Still on its way to the customer.
  bool get isOpen => this == received || this == preparing || this == ready;
}

/// One line of a placed order. Names and choices are saved with the order,
/// so an old order still reads right after the menu changes.
class OrderLine {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.options,
    required this.unitCents,
    required this.quantity,
    required this.lineCents,
    this.choices = '',
    this.note,
    this.translations = const {},
  });

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
    productId: json['product_id'] as int?,
    name: json['name'] as String,
    options: {
      for (final MapEntry(:key, :value)
          in (json['options'] as Map? ?? const {}).entries)
        '$key': '$value',
    },
    choices: json['choices'] as String? ?? '',
    note: json['note'] as String?,
    unitCents: json['unit_cents'] as int,
    quantity: json['quantity'] as int,
    lineCents: json['line_cents'] as int,
    translations: {
      for (final MapEntry(:key, :value)
          in (json['translations'] as Map? ?? const {}).entries)
        '$key': Map<String, String>.from(value as Map),
    },
  );

  /// Null when the product was later removed from the menu.
  final int? productId;
  final String name;
  final Selection options;
  final String choices;
  final String? note;
  final int unitCents;
  final int quantity;
  final int lineCents;
  final Map<String, Map<String, String>> translations;

  String nameIn(String language) => translations[language]?['name'] ?? name;

  String choicesIn(String language) =>
      translations[language]?['choices'] ?? choices;
}

/// A placed order, from POST /orders and GET /orders/{id}.
class Order {
  const Order({
    required this.id,
    required this.number,
    required this.status,
    required this.customerName,
    required this.estimatedReadyAt,
    required this.createdAt,
    required this.subtotalCents,
    required this.totalCents,
    required this.lines,
    this.pickupAt,
    this.preparingAt,
    this.readyAt,
    this.collectedAt,
    this.cancelledAt,
    this.discountCents = 0,
    this.promoCode,
    this.promoCents = 0,
    this.pointsSpent = 0,
    this.pointsEarned = 0,
    this.canCancel = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    DateTime? time(String key) => switch (json[key]) {
      final String value => DateTime.parse(value),
      _ => null,
    };
    return Order(
      id: json['id'] as int,
      number: json['number'] as int,
      status: OrderStatus.parse(json['status'] as String),
      customerName: json['customer_name'] as String? ?? '',
      pickupAt: time('pickup_at'),
      estimatedReadyAt: time('estimated_ready_at')!,
      createdAt: time('created_at')!,
      preparingAt: time('preparing_at'),
      readyAt: time('ready_at'),
      collectedAt: time('collected_at'),
      cancelledAt: time('cancelled_at'),
      subtotalCents: json['subtotal_cents'] as int,
      discountCents: json['discount_cents'] as int? ?? 0,
      promoCode: json['promo_code'] as String?,
      promoCents: json['promo_cents'] as int? ?? 0,
      totalCents: json['total_cents'] as int,
      pointsSpent: json['points_spent'] as int? ?? 0,
      pointsEarned: json['points_earned'] as int? ?? 0,
      canCancel: json['can_cancel'] as bool? ?? false,
      lines: [
        for (final line in json['lines'] as List? ?? const [])
          OrderLine.fromJson(line as Map<String, dynamic>),
      ],
    );
  }

  final int id;

  /// The number the customer shows at the counter, like 1042.
  final int number;
  final OrderStatus status;
  final String customerName;

  /// Null for "as soon as possible".
  final DateTime? pickupAt;
  final DateTime estimatedReadyAt;
  final DateTime createdAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final DateTime? collectedAt;
  final DateTime? cancelledAt;
  final int subtotalCents;
  final int discountCents;
  final String? promoCode;
  final int promoCents;
  final int totalCents;
  final int pointsSpent;
  final int pointsEarned;
  final bool canCancel;
  final List<OrderLine> lines;
}

/// The server's totals for a cart, from POST /checkout/quote.
class Quote {
  const Quote({
    required this.subtotalCents,
    required this.totalCents,
    this.discountCents = 0,
    this.promoCode,
    this.promoCents = 0,
    this.pointsSpent = 0,
    this.pointsEarned = 0,
  });

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    subtotalCents: json['subtotal_cents'] as int,
    discountCents: json['discount_cents'] as int? ?? 0,
    promoCode: json['promo_code'] as String?,
    promoCents: json['promo_cents'] as int? ?? 0,
    totalCents: json['total_cents'] as int,
    pointsSpent: json['points_spent'] as int? ?? 0,
    pointsEarned: json['points_earned'] as int? ?? 0,
  );

  final int subtotalCents;
  final int discountCents;
  final String? promoCode;
  final int promoCents;
  final int totalCents;
  final int pointsSpent;
  final int pointsEarned;
}

/// What the customer chose at checkout. Prices are never sent: the server
/// prices the cart again from the menu.
class Checkout {
  const Checkout({
    required this.lines,
    this.promoCode,
    this.useFreeDrink = false,
    this.pickupAt,
    this.customerName = '',
    this.customerPhone,
  });

  final List<CartItem> lines;
  final String? promoCode;
  final bool useFreeDrink;

  /// Null for "as soon as possible".
  final DateTime? pickupAt;
  final String customerName;
  final String? customerPhone;

  Map<String, Object?> toQuoteJson() => {
    'lines': [
      for (final line in lines)
        {
          'product_id': line.product.id,
          'options': line.options,
          'quantity': line.quantity,
          if (line.note.isNotEmpty) 'note': line.note,
        },
    ],
    if (promoCode case final code? when code.isNotEmpty) 'promo_code': code,
    'use_free_drink': useFreeDrink,
  };

  Map<String, Object?> toOrderJson() => {
    ...toQuoteJson(),
    'pickup_at': pickupAt?.toUtc().toIso8601String() ?? 'asap',
    'customer_name': customerName,
    if (customerPhone case final phone? when phone.isNotEmpty)
      'customer_phone': phone,
  };
}
