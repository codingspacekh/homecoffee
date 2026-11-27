import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homecoffee_data/homecoffee_data.dart';

import '../settings/settings.dart';
import 'token_store.dart';

final tokenStoreProvider = Provider<TokenStore>(
  (ref) => throw UnimplementedError('Loaded in main()'),
);

/// The HomeCoffee API, with the customer's token once they have signed in.
/// A 401 means the token is gone (signed out on the server), so the app
/// forgets it too.
final apiClientProvider = Provider<Dio>(
  (ref) => createApiClient(
    token: () => ref.read(sessionProvider)?.token,
    onSignedOut: () => ref.read(sessionProvider.notifier).forget(),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(ref.watch(apiClientProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ApiProfileRepository(ref.watch(apiClientProvider)),
);

/// A signed-in phone: the token and the account it belongs to.
class Session {
  const Session({required this.token, required this.account});

  final String token;
  final Account account;
}

/// Who is signed in, or null. The account is kept on the phone too, so the
/// app opens signed in with no signal; it is refreshed from the server when
/// it can be.
class SessionNotifier extends Notifier<Session?> {
  static const _accountKey = 'account';

  @override
  Session? build() {
    final token = ref.watch(tokenStoreProvider).token;
    final saved = ref.watch(preferencesProvider).getString(_accountKey);
    if (token == null || saved == null) return null;
    Future.microtask(refresh);
    return Session(
      token: token,
      account: Account.fromJson(jsonDecode(saved) as Map<String, dynamic>),
    );
  }

  Future<void> sendCode(String email) =>
      ref.read(authRepositoryProvider).sendCode(email, language: _language);

  /// Signs in with the emailed code. Throws an [ApiProblem] when the code is
  /// wrong or old.
  Future<SignIn> verify(String email, String code) async {
    final signIn = await ref
        .read(authRepositoryProvider)
        .verify(email, code, language: _language);
    await ref.read(tokenStoreProvider).save(signIn.token);
    _setAccount(signIn.account, token: signIn.token);
    return signIn;
  }

  /// Reads points, name and phone again, for example after an order.
  Future<void> refresh() async {
    if (state == null) return;
    try {
      _setAccount(await ref.read(profileRepositoryProvider).fetchMe());
    } on ApiProblem {
      // No signal: keep what we have. A 401 already signed the phone out.
    }
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    final account = await ref
        .read(profileRepositoryProvider)
        .update(name: name, phone: phone);
    _setAccount(account);
  }

  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on ApiProblem {
      // Signed out on this phone anyway
    }
    await forget();
  }

  /// Forget my data: deletes the account on the server, then everything
  /// about it on this phone.
  Future<void> deleteAccount() async {
    await ref.read(profileRepositoryProvider).deleteMe();
    await forget();
  }

  /// Forgets the token and account on this phone.
  Future<void> forget() async {
    if (state == null) return;
    state = null;
    await ref.read(preferencesProvider).remove(_accountKey);
    await ref.read(tokenStoreProvider).save(null);
  }

  String get _language => ref.read(settingsProvider).language ?? 'en';

  void _setAccount(Account account, {String? token}) {
    final current = token ?? state?.token;
    if (current == null) return;
    state = Session(token: current, account: account);
    ref
        .read(preferencesProvider)
        .setString(_accountKey, jsonEncode(account.toJson()));
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);

/// The signed-in customer, or null.
final accountProvider = Provider<Account?>(
  (ref) => ref.watch(sessionProvider)?.account,
);

final signedInProvider = Provider<bool>(
  (ref) => ref.watch(sessionProvider) != null,
);
