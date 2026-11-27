import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/problems.dart';
import '../../core/session/session.dart';

/// Email-code sign-in in two steps: the email, then the 6-digit code from
/// the email. No passwords to forget.
///
/// [next] is where to go once signed in, for example the checkout.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.next});

  final String? next;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _email = TextEditingController();
  final _code = TextEditingController();
  String? _sentTo;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on ApiProblem catch (problem) {
      if (!mounted) return;
      final t = context.l10n;
      setState(
        () => _error = problem.code == 'invalid'
            ? (_sentTo == null ? t.errEmail : t.errCode)
            : problemText(t, problem),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode({bool again = false}) async {
    final email = (again ? _sentTo : _email.text.trim().toLowerCase()) ?? '';
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = context.l10n.errEmail);
      return;
    }
    await _run(() async {
      await ref.read(sessionProvider.notifier).sendCode(email);
      if (!mounted) return;
      setState(() {
        _sentTo = email;
        _code.clear();
      });
      if (again) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(context.l10n.codeSent)));
      }
    });
  }

  Future<void> _verify() async {
    final code = _code.text.replaceAll(' ', '');
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = context.l10n.errCode);
      return;
    }
    await _run(() async {
      await ref.read(sessionProvider.notifier).verify(_sentTo!, code);
      if (!mounted) return;
      final next = widget.next;
      if (next != null) {
        context.pushReplacement(next);
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final atCode = _sentTo != null;
    final title = Theme.of(context).textTheme.headlineSmall
        ?.copyWith(fontWeight: FontWeight.w800);
    final body = TextStyle(fontSize: 16, color: context.extras.bodyText);
    final field = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      errorText: _error,
      errorMaxLines: 3,
    );

    return Scaffold(
      appBar: AppBar(
        leading: atCode
            ? BackButton(
                onPressed: () => setState(() {
                  _sentTo = null;
                  _error = null;
                }),
              )
            : CloseButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Icon(
                atCode ? Icons.mark_email_read_outlined : Icons.mail_outline,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(atCode ? t.codeTitle : t.signInTitle, style: title),
            ),
            const SizedBox(height: 8),
            Text(atCode ? t.codeBody(_sentTo!) : t.signInBody, style: body),
            const SizedBox(height: 24),
            if (!atCode)
              TextField(
                key: const Key('email'),
                controller: _email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendCode(),
                decoration: field.copyWith(labelText: t.email),
              )
            else
              TextField(
                key: const Key('code'),
                controller: _code,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _verify(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                ),
                decoration: field.copyWith(labelText: t.code),
              ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                textStyle: context.largeButtonText,
              ),
              onPressed: _busy ? null : (atCode ? _verify : _sendCode),
              child: _busy
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Text(atCode ? t.signIn : t.sendCode),
            ),
            if (atCode) ...[
              const SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: _busy ? null : () => _sendCode(again: true),
                child: Text(t.sendNewCode),
              ),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        _sentTo = null;
                        _error = null;
                      }),
                child: Text(t.otherEmail),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Opens the checkout, asking the customer to sign in first if they
/// haven't.
void openCheckout(BuildContext context, WidgetRef ref) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ref.read(signedInProvider)
      ? context.push('/checkout')
      : context.push('/sign-in?next=/checkout');
}
