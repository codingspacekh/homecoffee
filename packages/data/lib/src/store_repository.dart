import 'package:dio/dio.dart';

import 'api_problem.dart';

/// Opening and closing time for one day, as "07:00" and "18:00".
typedef DayHours = ({String open, String close});

/// GET /api/v1/store: opening hours, whether the shop takes orders right now
/// and how long a drink takes.
class StoreInfo {
  const StoreInfo({
    required this.prepMinutes,
    required this.openNow,
    required this.canOrderNow,
    this.acceptingOrders = true,
    this.openingHours = const {},
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) => StoreInfo(
    prepMinutes: json['prep_minutes'] as int,
    openNow: json['open_now'] as bool,
    canOrderNow: json['can_order_now'] as bool,
    acceptingOrders: json['accepting_orders'] as bool? ?? true,
    openingHours: {
      for (final MapEntry(:key, :value)
          in (json['opening_hours'] as Map? ?? const {}).entries)
        if (value case {'open': final String open, 'close': final String close})
          '$key': (open: open, close: close),
    },
  );

  static const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

  final int prepMinutes;
  final bool openNow;
  final bool canOrderNow;

  /// False while the owner has paused orders.
  final bool acceptingOrders;

  /// 'mon' to 'sun'. A missing day means closed all day.
  final Map<String, DayHours> openingHours;

  /// The shop's hours on [day], in the shop's own time (Cambodia).
  DayHours? hoursOn(DateTime day) => openingHours[days[day.weekday - 1]];

  /// Pickup times the customer can choose later today: every 15 minutes
  /// from the prep time onwards, up to closing time.
  List<DateTime> pickupSlots(DateTime now, {int stepMinutes = 15}) {
    final hours = hoursOn(now);
    if (hours == null || !acceptingOrders) return const [];
    DateTime at(String hhmm) {
      final [h, m] = hhmm.split(':').map(int.parse).toList();
      return DateTime(now.year, now.month, now.day, h, m);
    }

    final open = at(hours.open);
    final close = at(hours.close);
    final earliest = now.add(Duration(minutes: prepMinutes));
    var slot = open;
    final slots = <DateTime>[];
    while (!slot.isAfter(close)) {
      if (!slot.isBefore(earliest)) slots.add(slot);
      slot = slot.add(Duration(minutes: stepMinutes));
    }
    return slots;
  }
}

abstract interface class StoreRepository {
  Future<StoreInfo> fetchStore();
}

class ApiStoreRepository implements StoreRepository {
  ApiStoreRepository(this._dio);

  final Dio _dio;

  @override
  Future<StoreInfo> fetchStore() => guard(() async {
    final response = await _dio.get<Map<String, dynamic>>('/store');
    return StoreInfo.fromJson(response.data!);
  });
}
