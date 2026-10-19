import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';
import 'package:mime_health/core/widgets/app_button.dart';
import 'package:mime_health/core/widgets/app_dropdown_field.dart';
import 'package:mime_health/core/widgets/app_text_field1.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/route_names.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/subscription_entity.dart';
import '../provider/subscription_provider.dart';
import 'payment_webview_screen.dart';

extension on PaymentMethod {
  String get iconAsset => switch (this) {
    PaymentMethod.bkash => 'assets/images/bkash.png',
    PaymentMethod.nagad => 'assets/images/nagad.svg',
    PaymentMethod.card => 'assets/images/card.svg',
  };

  String get labelKey => switch (this) {
    PaymentMethod.bkash => L10nKeys.paymentMethodBkash,
    PaymentMethod.nagad => L10nKeys.paymentMethodNagad,
    PaymentMethod.card => L10nKeys.paymentMethodCard,
  };
}

/// Checkout for a subscription package (or, when [addons] is given, for
/// add-on services only): promo code, amount and payment method. Pops `true`
/// once the gateway reports a successful payment.
class SubscriptionPaymentScreen extends HookConsumerWidget {
  const SubscriptionPaymentScreen({
    super.key,
    this.initialPlanCode,
    this.addons,
  });

  final String? initialPlanCode;
  final List<SubscriptionServiceOfferEntity>? addons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final state = ref.watch(subscriptionPlansNotifierProvider);
    final notifier = ref.read(subscriptionPlansNotifierProvider.notifier);
    final isSubmitting = ref.watch(
      subscriptionCheckoutNotifierProvider.select((s) => s.isSubmitting),
    );
    final checkoutNotifier = ref.read(
      subscriptionCheckoutNotifierProvider.notifier,
    );
    final promoCode = useState('');
    final method = useState<PaymentMethod?>(null);

    useEffect(() {
      final code = initialPlanCode;
      if (code != null) {
        Future.microtask(() => notifier.selectPlanCode(code));
      }
      return null;
    }, [initialPlanCode]);

    final addons = this.addons;
    final isAddonMode = addons != null;
    final plan = state.selectedPlan;
    final period = l10n.t(
      state.billingInterval == BillingInterval.annual
          ? L10nKeys.subscriptionAnnual
          : L10nKeys.subscriptionMonthly,
    );
    final price = isAddonMode
        ? addonsTotal(addons, state.billingInterval)
        : plan?.priceFor(state.billingInterval);
    final amount = price == null ? '' : '৳$price / ${period.toLowerCase()}';
    final canCheckout = isAddonMode ? addons.isNotEmpty : plan != null;

    Future<void> checkout() async {
      final selectedMethod = method.value;
      if (selectedMethod == null) return;
      final CheckoutEntity? created;
      if (isAddonMode) {
        created = await checkoutNotifier.checkoutServices(
          serviceCodes: addons.map((a) => a.code).toList(growable: false),
          billingInterval: state.billingInterval,
          paymentMethod: selectedMethod,
        );
      } else {
        if (plan == null) return;
        created = await checkoutNotifier.checkoutPlan(
          planCode: plan.code,
          billingInterval: state.billingInterval,
          paymentMethod: selectedMethod,
        );
      }
      if (created == null || !context.mounted) return;

      final outcome = await context.push<PaymentOutcome>(
        RouteNames.paymentWebView,
        extra: created,
      );
      checkoutNotifier.refreshAfterPayment();
      if (!context.mounted) return;

      final snackbar = ref.read(snackbarServiceProvider);
      switch (outcome) {
        case PaymentOutcome.success:
          snackbar.showSuccess(l10n.t(L10nKeys.paymentSuccess));
          context.pop(true);
        case PaymentOutcome.failed:
          snackbar.showError(l10n.t(L10nKeys.paymentFailed));
        case PaymentOutcome.cancelled:
          snackbar.showWarning(l10n.t(L10nKeys.paymentCancelled));
        case PaymentOutcome.unknown || null:
          snackbar.showInfo(l10n.t(L10nKeys.paymentNotCompleted));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppAppBar(title: l10n.t(L10nKeys.paymentTitle)),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryContainer,
                ),
              )
            : ListView(
                padding: EdgeInsets.fromLTRB(
                  context.defaultPaddingSc,
                  context.scaleHeight(20),
                  context.defaultPaddingSc,
                  context.scaleHeight(28),
                ),
                children: [
                  if (isAddonMode)
                    _SelectedAddonsCard(
                      title: l10n.t(L10nKeys.paymentSelectedAddons),
                      addons: addons,
                      interval: state.billingInterval,
                    )
                  else
                    AppDropdownField<String>(
                      label: l10n.t(L10nKeys.paymentSelectPackage),
                      mandatory: true,
                      value: plan?.code,
                      items: state.plans.map((p) => p.code).toList(),
                      itemLabelBuilder: (code) =>
                          state.plans.firstWhere((p) => p.code == code).name,
                      enabled: !isSubmitting,
                      onChanged: (code) {
                        if (code != null) notifier.selectPlanCode(code);
                      },
                    ),
                  SizedBox(height: context.scaleHeight(18)),
                  AppTextField1(
                    label: l10n.t(L10nKeys.paymentPromoCode),
                    initialValue: promoCode.value,
                    isReadOnly: isSubmitting,
                    onChanged: (value) => promoCode.value = value.trim(),
                  ),
                  SizedBox(height: context.scaleHeight(18)),
                  AppTextField1(
                    label: l10n.t(L10nKeys.paymentAmount),
                    initialValue: amount,
                    isReadOnly: true,
                    onChanged: (_) {},
                  ),
                  SizedBox(height: context.scaleHeight(24)),
                  Padding(
                    padding: EdgeInsets.only(left: context.scaleWidth(4)),
                    child: Text(
                      l10n.t(L10nKeys.paymentMethod),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.fontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: context.scaleHeight(10)),
                  _PaymentMethodCard(
                    selected: method.value,
                    labelOf: (m) => l10n.t(m.labelKey),
                    onChanged: isSubmitting ? null : (m) => method.value = m,
                  ),
                  SizedBox(height: context.scaleHeight(32)),
                  AppButton(
                    label: l10n.t(L10nKeys.paymentCheckout),
                    isLoading: isSubmitting,
                    isEnabled: canCheckout && method.value != null,
                    onPressed: checkout,
                  ),
                  SizedBox(height: context.scaleHeight(12)),
                  AppButton(
                    label: l10n.t(L10nKeys.paymentCancel),
                    btnStyle: AppButtonStyle.cancel,
                    isEnabled: !isSubmitting,
                    onPressed: () => context.pop(false),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Sum of [addons] prices for [interval], formatted like the API (`"2.00"`).
String addonsTotal(
  List<SubscriptionServiceOfferEntity> addons,
  BillingInterval interval,
) {
  final total = addons.fold<double>(
    0,
    (sum, a) => sum + (double.tryParse(a.priceFor(interval)) ?? 0),
  );
  return total.toStringAsFixed(2);
}

class _SelectedAddonsCard extends StatelessWidget {
  const _SelectedAddonsCard({
    required this.title,
    required this.addons,
    required this.interval,
  });

  final String title;
  final List<SubscriptionServiceOfferEntity> addons;
  final BillingInterval interval;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.defaultPaddingSc,
        vertical: context.scaleHeight(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(context.scaleWidth(10)),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (${addons.length})',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.smallFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.scaleHeight(6)),
          for (final addon in addons)
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.scaleHeight(4)),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: context.scaleWidth(16),
                    color: AppColors.primaryContainer,
                  ),
                  SizedBox(width: context.scaleWidth(8)),
                  Expanded(
                    child: Text(
                      addon.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '৳${addon.priceFor(interval)}',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final PaymentMethod? selected;
  final String Function(PaymentMethod method) labelOf;
  final ValueChanged<PaymentMethod>? onChanged;

  @override
  Widget build(BuildContext context) {
    final methods = PaymentMethod.values;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: RadioGroup<PaymentMethod>(
        groupValue: selected,
        onChanged: (m) {
          if (m != null) onChanged?.call(m);
        },
        child: Column(
          children: [
            for (var i = 0; i < methods.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.glassBorder,
                ),
              _PaymentMethodTile(
                method: methods[i],
                label: labelOf(methods[i]),
                selected: methods[i] == selected,
                onTap: onChanged == null ? null : () => onChanged!(methods[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.pillSelected : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.defaultPaddingSc,
            vertical: context.scaleHeight(12),
          ),
          child: Row(
            children: [
              Container(
                width: context.scaleWidth(44),
                height: context.scaleWidth(40),
                padding: EdgeInsets.all(context.scaleWidth(6)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: method.iconAsset.endsWith('.svg')
                    ? SvgPicture.asset(method.iconAsset, fit: BoxFit.contain)
                    : Image.asset(method.iconAsset, fit: BoxFit.contain),
              ),
              SizedBox(width: context.scaleWidth(14)),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Radio<PaymentMethod>(
                value: method,
                enabled: onTap != null,
                activeColor: AppColors.primaryContainer,
                fillColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.primaryContainer
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
