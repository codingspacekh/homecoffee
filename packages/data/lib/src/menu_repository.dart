import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';

/// Screens ask this for the menu and never know where it comes from.
abstract interface class MenuRepository {
  /// The latest menu, or the saved one when the phone has no signal.
  Future<List<Category>> fetchMenu();
}

/// The last menu the phone downloaded, kept on the phone.
class SavedMenu {
  const SavedMenu({required this.etag, required this.json});

  final String etag;
  final String json;
}

/// Where the menu is kept between app starts. The app stores it on the phone;
/// tests keep it in memory.
abstract interface class MenuStore {
  Future<SavedMenu?> read();
  Future<void> write(SavedMenu menu);
}

class MemoryMenuStore implements MenuStore {
  SavedMenu? saved;

  @override
  Future<SavedMenu?> read() async => saved;

  @override
  Future<void> write(SavedMenu menu) async => saved = menu;
}

/// Reads GET /api/v1/menu.
///
/// Sends the ETag of the saved menu, so the server answers an empty 304 when
/// nothing changed. With no signal, it returns the saved menu instead of an
/// error, so customers can still browse and build a cart.
class ApiMenuRepository implements MenuRepository {
  ApiMenuRepository(this._dio, this._store);

  final Dio _dio;
  final MenuStore _store;

  @override
  Future<List<Category>> fetchMenu() async {
    final saved = await _store.read();
    try {
      final response = await _dio.get<String>(
        '/menu',
        options: Options(
          responseType: ResponseType.plain,
          headers: {if (saved != null) 'If-None-Match': saved.etag},
          validateStatus: (status) => status == 200 || status == 304,
        ),
      );
      if (response.statusCode == 304 && saved != null) {
        return parseMenu(saved.json);
      }
      final json = response.data!;
      final menu = parseMenu(json);
      final etag = response.headers.value('etag');
      if (etag != null) await _store.write(SavedMenu(etag: etag, json: json));
      return menu;
    } on DioException {
      if (saved != null) return parseMenu(saved.json);
      rethrow;
    }
  }

  static List<Category> parseMenu(String json) => [
    for (final category
        in (jsonDecode(json) as Map<String, dynamic>)['categories'] as List)
      Category.fromJson(category as Map<String, dynamic>),
  ];
}
