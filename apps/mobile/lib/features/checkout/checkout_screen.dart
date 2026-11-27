import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/problems.dart';
import '../../core/session/session.dart';
import '../../core/settings/settings.dart';
import '../cart/presentation/cart_notifier.dart';
import '../menu/data/menu_providers.dart';
import '../orders/data/orders_providers.dart';

/// The server's totals for the cart, with a promo code and the free drink.
final checkoutQuoteProvider = FutureProvider.autoDispose
    .family<Quote, ({String? promo, bool freeDrink})>((ref, choice) {
      final cart = ref.watch(cartProvider);
      return ref
          .watch(ordersRepositoryProvider)
          .quote(
            Checkout(
              lines: cart,
              promoCode: choice.promo,
              useFreeDrink: choice.freeDrink,
            ),
          );
    });

/// Same rule as the server (UpdateProfileRequest::PHONE_PATTERN): a
/// Cambodian number, starting 0 or +855.
final phonePattern = RegExp(r'^(\+?855|0)[1-9][0-9 ]{6,10}$');

String formatTime(BuildContext context, DateTime time) =>
    MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(time.toLocal()));

/// Pickup time, name and phone, free drink and promo code, then Place order.
/// Payment is at the counter for now; KHQR comes later.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  /// One key for everything the customer does on this screen, so tapping
  /// Place order again after a lost answer can't make a second order.
  final _idempotencyKey = newIdempotencyKey();
  late final _name = TextEditingController(
    text: ref.read(accountProvider)?.name,
  );
  late final _phone = TextEditingController(
    text: ref.read(accountProvider)?.phone,
  );
  final _promo = TextEditingController();

  bool _later = false;
  DateTime? _slot;
  bool _freeDrink = false;
  String? _appliedPromo;
  String? _promoError;
  String? _nameError;
  String? _phoneError;
  bool _checkingPromo = false;
  bool _placing = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _promo.dispose();
    super.dispose();
  }

  String _productName(int id) {
    final language = context.language;
    return ref
            .read(cartProvider)
            .where((line) => line.product.id == id)
            .firstOrNull
            ?.product
            .nameIn(language) ??
        '';
  }

  void _say(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _applyPromo() async {
    final t = context.l10n;
    final code = normalizeCode(_promo.text);
    if (code.isEmpty) {
      setState(() => _promoError = t.errPromoEmpty);
      return;
    }
    setState(() {
      _checkingPromo = true;
      _promoError = null;
    });
    try {
      await ref
          .read(ordersRepositoryProvider)
          .quote(
            Checkout(
              lines: ref.read(cartProvider),
              promoCode: code,
              useFreeDrink: _freeDrink,
            ),
          );
      if (mounted) setState(() => _appliedPromo = code);
    } on ApiProblem catch (problem) {
      if (mounted) {
        setState(
          () => _promoError = problemText(
            t,
            problem,
            promoCode: code,
            productName: _productName,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _checkingPromo = false);
    }
  }

  bool _validate() {
    final t = context.l10n;
    final phone = _phone.text.trim();
    setState(() {
      _nameError = _name.text.trim().isEmpty ? t.errName : null;
      _phoneError = phone.isEmpty
          ? t.errPhoneMissing
          : (phonePattern.hasMatch(phone) ? null : t.errPhone);
    });
    return _nameError == null && _phoneError == null;
  }

  Future<void> _place() async {
    final t = context.l10n;
    if (!_validate()) {
      _say(t.checkFields);
      return;
    }
    if (_later && _slot == null) {
      _say(t.errPickupTime);
      return;
    }
    setState(() => _placing = true);
    final cart = ref.read(cartProvider);
    try {
      final order = await ref
          .read(ordersRepositoryProvider)
          .place(
            Checkout(
              lines: cart,
              promoCode: _appliedPromo,
              useFreeDrink: _freeDrink,
              pickupAt: _later ? _slot : null,
              customerName: _name.text.trim(),
              customerPhone: _phone.text.trim(),
            ),
            idempotencyKey: _idempotencyKey,
          );
      if (!mounted) return;
      ref.read(cartProvider.notifier).clear();
      ref.read(ordersProvider.notifier).replace(order);
      // The name, phone and any free drink used changed the account
      ref.read(sessionProvider.notifier).refresh();
      context.go('/order/${order.id}');
    } on ApiProblem catch (problem) {
      if (!mounted) return;
      switch (problem.code) {
        case 'item_unavailable':
          ref.invalidate(menuProvider);
        case 'promo_invalid' || 'promo_minimum':
          setState(() => _appliedPromo = null);
        case 'not_enough_points':
          setState(() => _freeDrink = false);
          ref.read(sessionProvider.notifier).refresh();
        case 'store_closed':
          setState(() => _later = true);
        case 'invalid' when problem.fields.contains('customer_phone'):
          setState(() => _phoneError = t.errPhone);
      }
      _say(
        problemText(
          t,
          problem,
          productName: _productName,
          promoCode: _appliedPromo ?? '',
        ),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final cart = ref.watch(cartProvider);
    final account = ref.watch(accountProvider);
    final store = ref.watch(storeProvider).value;
    final now = ref.watch(clockProvider)();
    final points = account?.points ?? 0;
    final canUseReward =
        (account?.hasReward ?? false) && rewardItem(cart) != null;
    final freeDrink = _freeDrink && canUseReward;

    final local = orderTotals(
      cart,
      points: points,
      useReward: freeDrink,
      promoCode: _appliedPromo ?? '',
    );
    final quote = ref
        .watch(
          checkoutQuoteProvider((promo: _appliedPromo, freeDrink: freeDrink)),
        )
        .value;
    final subtotal = quote?.subtotalCents ?? local.subtotal;
    final discount = quote?.discountCents ?? local.discount;
    final promoCents = quote?.promoCents ?? local.promoAmount;
    final total = quote?.totalCents ?? local.total;
    final earned = quote?.pointsEarned ?? pointsFor(local.total);

    final slots = store?.pickupSlots(now) ?? const <DateTime>[];
    final asapOpen = store == null || store.canOrderNow;
    final later = _later || !asapOpen;

    final quiet = TextStyle(fontSize: 14, color: scheme.onSurfaceVariant);
    final heading = const TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    );

    Widget section({
      required List<Widget> children,
      EdgeInsets padding = const EdgeInsets.all(16),
    }) => Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );

    Widget summaryRow(String label, String value, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: color ?? scheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color ?? scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(t.checkout)),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/'),
            child: Text(t.browseMenu),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.checkout)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          section(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(t.pickupTime, style: heading),
                  ],
                ),
              ),
              RadioGroup<bool>(
                groupValue: later,
                onChanged: (value) => setState(() {
                  _later = value!;
                  if (_later) _slot ??= slots.firstOrNull;
                }),
                child: Column(
                  children: [
                    RadioListTile<bool>(
                      value: false,
                      enabled: asapOpen,
                      minTileHeight: 56,
                      title: Text(t.asap),
                      subtitle: Text(
                        asapOpen
                            ? t.readyInAbout(store?.prepMinutes ?? 7)
                            : t.errStoreClosed,
                        style: quiet,
                      ),
                    ),
                    RadioListTile<bool>(
                      value: true,
                      enabled: slots.isNotEmpty,
                      minTileHeight: 56,
                      title: Text(t.scheduleLater),
                      subtitle: Text(
                        slots.isEmpty ? t.noSlotsToday : t.chooseTimeBelow,
                        style: quiet,
                      ),
                    ),
                  ],
                ),
              ),
              if (later && slots.isNotEmpty)
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    itemCount: slots.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final slot = slots[i];
                      return ChoiceChip(
                        label: Text(formatTime(context, slot)),
                        selected: _slot == slot,
                        showCheckmark: false,
                        onSelected: (_) => setState(() {
                          _later = true;
                          _slot = slot;
                        }),
                      );
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          section(
            children: [
              Text(t.yourDetails, style: heading),
              const SizedBox(height: 14),
              TextField(
                key: const Key('name'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: t.name,
                  border: fieldBorder,
                  errorText: _nameError,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const Key('phone'),
                controller: _phone,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                decoration: InputDecoration(
                  labelText: t.phone,
                  border: fieldBorder,
                  helperText: t.phoneHelp,
                  helperMaxLines: 2,
                  errorText: _phoneError,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          section(
            children: [
              Text(t.rewardsPromo, style: heading),
              const SizedBox(height: 8),
              if (canUseReward)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    t.useReward(formatPrice(rewardDiscount(cart, points))),
                  ),
                  value: freeDrink,
                  onChanged: (on) => setState(() => _freeDrink = on),
                )
              else if (account != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.star_outline, color: scheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          account.hasReward
                              ? t.haveReward
                              : t.remainingPoints(account.pointsToReward),
                          style: quiet,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              if (_appliedPromo case final code?)
                Material(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: scheme.onTertiaryContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.promoApplied(code),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: scheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: t.removePromo(code),
                          color: scheme.onTertiaryContainer,
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _appliedPromo = null;
                            _promo.clear();
                          }),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('promo'),
                        controller: _promo,
                        textCapitalization: TextCapitalization.characters,
                        autocorrect: false,
                        onSubmitted: (_) => _applyPromo(),
                        decoration: InputDecoration(
                          labelText: t.promo,
                          border: fieldBorder,
                          errorText: _promoError,
                          errorMaxLines: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(56, 56),
                      ),
                      onPressed: _checkingPromo ? null : _applyPromo,
                      child: Text(t.apply),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          section(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(t.payment, style: heading),
              ),
              RadioGroup<String>(
                groupValue: 'counter',
                onChanged: (_) {},
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'counter',
                      minTileHeight: 56,
                      title: Text(t.payCounter),
                    ),
                    RadioListTile<String>(
                      value: 'khqr',
                      enabled: false,
                      minTileHeight: 56,
                      title: Text(t.payKhqr),
                      secondary: Text(t.soon, style: quiet),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          section(
            children: [
              Text(t.summary, style: heading),
              const SizedBox(height: 8),
              summaryRow(t.subtotal, formatPrice(subtotal)),
              if (discount > 0)
                summaryRow(
                  t.freeDrink,
                  formatPrice(-discount),
                  color: scheme.tertiary,
                ),
              if (promoCents > 0)
                summaryRow(
                  t.promoLine(_appliedPromo ?? ''),
                  formatPrice(-promoCents),
                  color: scheme.tertiary,
                ),
              Divider(height: 17, color: scheme.outlineVariant),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      t.total,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    formatPrice(total),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(t.earnPoints(earned), style: quiet),
            ],
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: FilledButton(
              key: const Key('place-order'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                textStyle: context.largeButtonText,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              onPressed: _placing ? null : _place,
              child: _placing
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Row(
                      children: [
                        Expanded(child: Text(t.placeOrder)),
                        Text(formatPrice(total)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
