import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The phone's saved preferences. main() loads them before the first frame,
/// so screens never wait for them.
final preferencesProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError('Loaded in main()'),
);

/// What the customer chose in the welcome screens and in Account.
@immutable
class AppSettings {
  const AppSettings({
    this.language,
    this.themeMode = ThemeMode.system,
    this.welcomed = false,
    this.orderAlerts = false,
  });

  /// 'en' or 'km'. Null until chosen, so the phone's language decides.
  final String? language;
  final ThemeMode themeMode;

  /// True once the welcome screens are done or skipped.
  final bool welcomed;

  /// The customer said yes to a notification when an order is ready. The
  /// notifications themselves arrive with orders.
  final bool orderAlerts;

  AppSettings copyWith({
    String? language,
    ThemeMode? themeMode,
    bool? welcomed,
    bool? orderAlerts,
  }) => AppSettings(
    language: language ?? this.language,
    themeMode: themeMode ?? this.themeMode,
    welcomed: welcomed ?? this.welcomed,
    orderAlerts: orderAlerts ?? this.orderAlerts,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const keys = (
    language: 'settings.language',
    theme: 'settings.theme',
    welcomed: 'settings.welcomed',
    alerts: 'settings.orderAlerts',
  );

  SharedPreferencesWithCache get _prefs => ref.read(preferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(preferencesProvider);
    return AppSettings(
      language: prefs.getString(keys.language),
      themeMode:
          ThemeMode.values.asNameMap()[prefs.getString(keys.theme)] ??
          ThemeMode.system,
      welcomed: prefs.getBool(keys.welcomed) ?? false,
      orderAlerts: prefs.getBool(keys.alerts) ?? false,
    );
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
    _prefs.setString(keys.language, language);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setString(keys.theme, mode.name);
  }

  void setOrderAlerts(bool on) {
    state = state.copyWith(orderAlerts: on);
    _prefs.setBool(keys.alerts, on);
  }

  void finishWelcome() {
    state = state.copyWith(welcomed: true);
    _prefs.setBool(keys.welcomed, true);
  }

  void showWelcomeAgain() {
    state = state.copyWith(welcomed: false);
    _prefs.setBool(keys.welcomed, false);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

/// The language the app shows: the customer's choice, else the phone's
/// language when it is Khmer, else English.
String resolveLanguage(String? chosen, Locale device) =>
    chosen ?? (device.languageCode == 'km' ? 'km' : 'en');

/// The clock, so tests can pick the time of day.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
