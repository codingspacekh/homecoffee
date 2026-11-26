import 'package:dio/dio.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';

/// Screens ask this for the menu and never know where it comes from.
abstract interface class MenuRepository {
  Future<List<Category>> fetchMenu();
}

/// Until `GET /api/v1/menu` exists (Phase 1), the app reads the menu.json
/// the website already serves.
class WebsiteMenuRepository implements MenuRepository {
  WebsiteMenuRepository(this._dio);

  static const siteUrl = 'https://vanillacoffee-three.vercel.app';

  final Dio _dio;

  @override
  Future<List<Category>> fetchMenu() async {
    final response = await _dio.get<List<dynamic>>('$siteUrl/data/menu.json');
    return [
      for (final json in response.data!)
        Category.fromJson(json as Map<String, dynamic>),
    ];
  }

  static String imageUrl(Product product) =>
      '$siteUrl/data/images/${product.image}';
}
