import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/problems.dart';
import '../../core/session/session.dart';
import '../../core/settings/settings.dart';
import '../checkout/checkout_screen.dart' show phonePattern;
import '../welcome/welcome_screen.dart';

/// Your profile (or Sign in), then settings: language, light or dark, order
/// alerts, the welcome screens again, sign out and forget my data.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);
    final account = ref.watch(accountProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final label = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );

    Widget titled(IconData icon, String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, color: scheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(title, style: label),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: Semantics(
                header: true,
                child: Text(
                  t.tabAccount,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontSize: 30, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            if (account != null)
              _Profile(account: account)
            else
              Material(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.signInHint,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.push('/sign-in'),
                        child: Text(t.signIn),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                t.settings,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            Material(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titled(
                      Icons.language,
                      t.language,
                      SegmentedButton<String>(
                        segments: [
                          for (final (code, name) in languages)
                            ButtonSegment(value: code, label: Text(name)),
                        ],
                        selected: {context.language},
                        onSelectionChanged: (v) =>
                            notifier.setLanguage(v.single),
                      ),
                    ),
                    const SizedBox(height: 16),
                    titled(
                      Icons.dark_mode_outlined,
                      t.appearance,
                      SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(t.themeSystem),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(t.themeLight),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(t.themeDark),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (v) =>
                            notifier.setThemeMode(v.single),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.notifications_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                      title: Text(t.orderAlerts, style: label),
                      value: settings.orderAlerts,
                      onChanged: notifier.setOrderAlerts,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                minTileHeight: 56,
                leading: const Icon(Icons.waving_hand_outlined),
                title: Text(t.showWelcomeAgain),
                trailing: const Icon(Icons.chevron_right),
                onTap: notifier.showWelcomeAgain,
              ),
            ),
            if (account != null) ...[
              const SizedBox(height: 16),
              Material(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      minTileHeight: 56,
                      leading: const Icon(Icons.logout),
                      title: Text(t.signOut),
                      onTap: () => ref.read(sessionProvider.notifier).signOut(),
                    ),
                    Divider(height: 1, color: scheme.outlineVariant),
                    ListTile(
                      minTileHeight: 56,
                      iconColor: scheme.error,
                      textColor: scheme.error,
                      leading: const Icon(Icons.delete_outline),
                      title: Text(t.forgetRow),
                      onTap: () => _forget(context, ref),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _forget(BuildContext context, WidgetRef ref) async {
  final t = context.l10n;
  final sure = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.forgetTitle),
      content: Text(t.forgetBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(t.forget),
        ),
      ],
    ),
  );
  if (sure != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(sessionProvider.notifier).deleteAccount();
    messenger.showSnackBar(SnackBar(content: Text(t.forgotten)));
  } on ApiProblem catch (problem) {
    messenger.showSnackBar(SnackBar(content: Text(problemText(t, problem))));
  }
}

/// Initial, name and email, with Edit for the name and phone.
class _Profile extends ConsumerWidget {
  const _Profile({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final name = account.name;
    final initial = (name == null || name.isEmpty ? account.email : name)
        .characters
        .first
        .toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: Text(
              initial,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name == null || name.isEmpty ? t.addName : name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  [account.email, ?account.phone].join('\n'),
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => _EditProfile(account: account),
            ),
            child: Text(t.edit),
          ),
        ],
      ),
    );
  }
}

class _EditProfile extends ConsumerStatefulWidget {
  const _EditProfile({required this.account});

  final Account account;

  @override
  ConsumerState<_EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<_EditProfile> {
  late final _name = TextEditingController(text: widget.account.name);
  late final _phone = TextEditingController(text: widget.account.phone);
  String? _phoneError;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.l10n;
    final phone = _phone.text.trim();
    if (phone.isNotEmpty && !phonePattern.hasMatch(phone)) {
      setState(() => _phoneError = t.errPhone);
      return;
    }
    setState(() {
      _saving = true;
      _phoneError = null;
      _error = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .updateProfile(name: _name.text.trim(), phone: phone);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(t.saved)));
    } on ApiProblem catch (problem) {
      if (mounted) setState(() => _error = problemText(t, problem));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.yourDetails,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: t.name, border: border),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: t.phone,
              border: border,
              errorText: _phoneError,
            ),
          ),
          if (_error case final error?) ...[
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              textStyle: context.largeButtonText,
            ),
            onPressed: _saving ? null : _save,
            child: Text(t.save),
          ),
        ],
      ),
    );
  }
}
