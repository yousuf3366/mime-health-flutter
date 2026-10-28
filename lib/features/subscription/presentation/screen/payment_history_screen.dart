import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/providers/core_providers.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';
import 'package:mime_health/core/widgets/app_button.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/subscription_entity.dart';
import '../provider/subscription_provider.dart';

/// Paged list of the user's payments (`GET /subscription/payments`) with an
/// invoice download per item.
class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final state = ref.watch(paymentHistoryNotifierProvider);
    final notifier = ref.read(paymentHistoryNotifierProvider.notifier);

    Future<void> download(PaymentEntity payment) async {
      final previewPath = await notifier.downloadInvoice(payment);
      if (previewPath == null) return;
      ref
          .read(snackbarServiceProvider)
          .showSuccess(l10n.t(L10nKeys.paymentHistorySaved));
      try {
        await OpenFilex.open(previewPath);
      } catch (error) {
        debugPrint('[PaymentHistory] preview invoice failed: $error');
      }
    }

    Future<void> pickDateRange() async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final from = state.fromDate;
      final to = state.toDate;
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: today,
        initialDateRange: from == null && to == null
            ? null
            : DateTimeRange(start: from ?? to!, end: to ?? today),
        helpText: l10n.t(L10nKeys.paymentHistoryFilterTitle),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryContainer,
              onPrimary: AppColors.onPrimaryContainer,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        ),
      );
      if (picked != null) {
        await notifier.setDateFilter(from: picked.start, to: picked.end);
      }
    }

    Widget body;
    if (state.isLoading) {
      body = const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      );
    } else if (state.errorMessage != null && state.items.isEmpty) {
      body = _MessageBody(
        icon: Icons.error_outline,
        message: state.errorMessage!,
        actionLabel: l10n.t(L10nKeys.retry),
        onAction: notifier.load,
      );
    } else if (state.items.isEmpty) {
      body = state.hasDateFilter
          ? _MessageBody(
              icon: Icons.event_busy_outlined,
              message: l10n.t(L10nKeys.paymentHistoryEmptyFiltered),
              actionLabel: l10n.t(L10nKeys.paymentHistoryClearFilter),
              onAction: notifier.clearDateFilter,
            )
          : _MessageBody(
              icon: Icons.receipt_long_outlined,
              message: l10n.t(L10nKeys.paymentHistoryEmpty),
            );
    } else {
      body = RefreshIndicator(
        color: AppColors.primaryContainer,
        onRefresh: () => notifier.load(showLoading: false),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            context.defaultPaddingSc,
            context.scaleHeight(16),
            context.defaultPaddingSc,
            context.scaleHeight(28),
          ),
          itemCount: state.items.length + (state.hasMore ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: context.scaleHeight(12)),
          itemBuilder: (context, index) {
            if (index >= state.items.length - 3) {
              Future.microtask(notifier.loadMore);
            }
            if (index == state.items.length) {
              return Padding(
                padding: EdgeInsets.all(context.scaleWidth(12)),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryContainer,
                  ),
                ),
              );
            }
            final payment = state.items[index];
            return _PaymentCard(
              payment: payment,
              t: l10n.t,
              isDownloading: state.downloadingIds.contains(payment.id),
              onDownload: payment.downloadUrl == null
                  ? null
                  : () => download(payment),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppAppBar(
        title: l10n.t(L10nKeys.paymentHistoryTitle),
        actions: [
          IconButton(
            onPressed: state.isLoading ? null : pickDateRange,
            tooltip: l10n.t(L10nKeys.paymentHistoryFilterTitle),
            icon: Badge(
              isLabelVisible: state.hasDateFilter,
              backgroundColor: AppColors.primaryContainer,
              smallSize: 8,
              child: const Icon(
                Icons.date_range_outlined,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (state.hasDateFilter)
              _DateFilterBar(
                from: state.fromDate,
                to: state.toDate,
                onEdit: pickDateRange,
                onClear: notifier.clearDateFilter,
                clearTooltip: l10n.t(L10nKeys.paymentHistoryClearFilter),
              ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// Active date range as a tappable chip with a clear button.
class _DateFilterBar extends StatelessWidget {
  const _DateFilterBar({
    required this.from,
    required this.to,
    required this.onEdit,
    required this.onClear,
    required this.clearTooltip,
  });

  final DateTime? from;
  final DateTime? to;
  final VoidCallback onEdit;
  final VoidCallback onClear;
  final String clearTooltip;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('dd MMM yyyy');
    final label = [
      from == null ? '…' : format.format(from!),
      to == null ? '…' : format.format(to!),
    ].join('  –  ');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.defaultPaddingSc,
        context.scaleHeight(12),
        context.defaultPaddingSc,
        0,
      ),
      child: Material(
        color: AppColors.pillSelected,
        borderRadius: BorderRadius.circular(context.scaleWidth(12)),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(context.scaleWidth(12)),
          child: Padding(
            padding: EdgeInsets.only(left: context.scaleWidth(14)),
            child: Row(
              children: [
                Icon(
                  Icons.date_range_outlined,
                  size: context.scaleWidth(18),
                  color: AppColors.primaryContainer,
                ),
                SizedBox(width: context.scaleWidth(10)),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClear,
                  tooltip: clearTooltip,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.t,
    required this.isDownloading,
    required this.onDownload,
  });

  final PaymentEntity payment;
  final String Function(String key) t;
  final bool isDownloading;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final titles = payment.lineItems
        .map((i) => i.title ?? i.code)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();
    final title = titles.isNotEmpty
        ? titles.join(', ')
        : _purposeLabel(payment.purpose);
    final (statusLabel, statusColor) = _status(payment.status);
    final paid = _formatDateTime(payment.paidAt);
    final created = _formatDateTime(payment.createdAt);
    final method = [
      _methodLabel(payment.paymentMethod),
      if (payment.gateway != null) _humanize(payment.gateway!),
    ].where((s) => s.isNotEmpty).join(' · ');

    final rows = <(String, String)>[
      if (payment.invoiceNumber != null)
        (t(L10nKeys.paymentHistoryInvoice), payment.invoiceNumber!),
      if (paid != null)
        (t(L10nKeys.paymentHistoryPaidOn), paid)
      else if (created != null)
        (t(L10nKeys.paymentHistoryCreatedOn), created),
      if (method.isNotEmpty) (t(L10nKeys.paymentHistoryMethod), method),
      if (payment.gatewayTransactionId != null)
        (t(L10nKeys.paymentHistoryTransaction), payment.gatewayTransactionId!),
      if (payment.failureReason != null)
        (t(L10nKeys.paymentHistoryFailure), payment.failureReason!),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.scaleWidth(16),
        context.scaleHeight(16),
        context.scaleWidth(12),
        context.scaleHeight(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(context.scaleWidth(16)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.fontSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: context.scaleHeight(2)),
                    Text(
                      _purposeLabel(payment.purpose),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.smallFontSize,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.scaleWidth(8)),
              _StatusChip(label: statusLabel, color: statusColor),
            ],
          ),
          SizedBox(height: context.scaleHeight(10)),
          Text(
            '৳${payment.amountBdt} ${payment.currency}',
            style: TextStyle(
              color: AppColors.primaryContainer,
              fontSize: context.titleFontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (payment.lineItems.length > 1) ...[
            SizedBox(height: context.scaleHeight(8)),
            for (final item in payment.lineItems)
              Padding(
                padding: EdgeInsets.only(bottom: context.scaleHeight(2)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        [
                          item.title ?? item.code ?? _humanize(item.type),
                          if (item.billingInterval != null)
                            _humanize(item.billingInterval!),
                        ].join(' · '),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: context.smallFontSize,
                        ),
                      ),
                    ),
                    Text(
                      '৳${item.amountBdt}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.smallFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          SizedBox(height: context.scaleHeight(8)),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
          SizedBox(height: context.scaleHeight(8)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (label, value) in rows)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: context.scaleHeight(2),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$label: ',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: value,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          style: TextStyle(fontSize: context.smallFontSize),
                        ),
                      ),
                  ],
                ),
              ),
              if (onDownload != null) ...[
                SizedBox(width: context.scaleWidth(8)),
                _DownloadButton(
                  tooltip: t(L10nKeys.paymentHistoryDownload),
                  isLoading: isDownloading,
                  onPressed: onDownload!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  (String, Color) _status(String status) =>
      switch (status.trim().toLowerCase()) {
        'completed' ||
        'paid' ||
        'success' => (t(L10nKeys.paymentStatusCompleted), AppColors.success),
        'pending' ||
        'processing' => (t(L10nKeys.paymentStatusPending), AppColors.warning),
        'failed' ||
        'cancelled' ||
        'canceled' => (t(L10nKeys.paymentStatusFailed), AppColors.error),
        _ => (_humanize(status), AppColors.textSecondary),
      };

  String _purposeLabel(String purpose) => switch (purpose) {
    'subscription' => t(L10nKeys.paymentPurposeSubscription),
    'service_subscription' => t(L10nKeys.paymentPurposeServices),
    _ => _humanize(purpose),
  };

  String _methodLabel(String method) => switch (method.toLowerCase()) {
    'bkash' => t(L10nKeys.paymentMethodBkash),
    'nagad' => t(L10nKeys.paymentMethodNagad),
    'card' => t(L10nKeys.paymentMethodCard),
    _ => _humanize(method),
  };
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({
    required this.tooltip,
    required this.isLoading,
    required this.onPressed,
  });

  final String tooltip;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = context.scaleWidth(40);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.pillSelected,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isLoading ? null : onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: context.scaleWidth(18),
                      height: context.scaleWidth(18),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryContainer,
                      ),
                    )
                  : Icon(
                      Icons.download_rounded,
                      size: context.scaleWidth(22),
                      color: AppColors.primaryContainer,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleWidth(10),
        vertical: context.scaleHeight(4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: context.smallFontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.defaultPaddingSc),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: context.scaleWidth(56), color: AppColors.textHint),
            SizedBox(height: context.scaleHeight(16)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.fontSize,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: context.scaleHeight(20)),
              AppButton(
                label: actionLabel!,
                expand: false,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String? _formatDateTime(String? raw) {
  final date = raw == null ? null : DateTime.tryParse(raw);
  return date == null
      ? null
      : DateFormat('dd MMM yyyy, h:mm a').format(date.toLocal());
}

String _humanize(String code) {
  final words = code
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase());
  return words.isEmpty ? '-' : words.join(' ');
}
