import 'package:dio/dio.dart';

/// GET /api/v1/store: whether the shop takes orders right now and how long
/// a drink takes.
class StoreInfo {
  const StoreInfo({
    required this.prepMinutes,
    required this.openNow,
    required this.canOrderNow,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) => StoreInfo(
    prepMinutes: json['prep_minutes'] as int,
    openNow: json['open_now'] as bool,
    canOrderNow: json['can_order_now'] as bool,
  );

  final int prepMinutes;
  final bool openNow;
  final bool canOrderNow;
}

abstract interface class StoreRepository {
  Future<StoreInfo> fetchStore();
}

class ApiStoreRepository implements StoreRepository {
  ApiStoreRepository(this._dio);

  final Dio _dio;

  @override
  Future<StoreInfo> fetchStore() async {
    final response = await _dio.get<Map<String, dynamic>>('/store');
    return StoreInfo.fromJson(response.data!);
  }
}
