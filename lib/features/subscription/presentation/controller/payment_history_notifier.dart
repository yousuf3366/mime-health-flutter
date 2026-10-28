import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entity/subscription_entity.dart';
import '../provider/subscription_di.dart';
import '../state/payment_history_state.dart';

/// Payment history screen: paged `GET /subscription/payments` and invoice
/// downloads.
class PaymentHistoryNotifier extends AutoDisposeNotifier<PaymentHistoryState> {
  static const _perPage = 10;

  @override
  PaymentHistoryState build() {
    Future.microtask(load);
    return const PaymentHistoryState(isLoading: true);
  }

  /// Reloads from page 1. [showLoading] is false for pull-to-refresh.
  Future<void> load({bool showLoading = true}) async {
    state = state.copyWith(isLoading: showLoading, errorMessage: null);
    final result = await ref
        .read(getPaymentHistoryUseCaseProvider)
        .call(
          page: 1,
          perPage: _perPage,
          fromDate: state.fromDate,
          toDate: state.toDate,
        );
    result.when(
      success: (page) {
        state = state.copyWith(
          items: page.items,
          page: page.currentPage,
          hasMore: page.hasMore,
          isLoading: false,
        );
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }

  /// Applies a `from_date` / `to_date` filter (either may be null) and reloads
  /// from page 1. Pass both null to clear the filter.
  Future<void> setDateFilter({DateTime? from, DateTime? to}) {
    state = state.copyWith(
      fromDate: from,
      toDate: to,
      items: const [],
      page: 0,
      hasMore: false,
    );
    return load();
  }

  Future<void> clearDateFilter() => setDateFilter();

  /// Appends the next page when the list nears its end.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final from = state.fromDate;
    final to = state.toDate;
    final result = await ref
        .read(getPaymentHistoryUseCaseProvider)
        .call(
          page: state.page + 1,
          perPage: _perPage,
          fromDate: from,
          toDate: to,
        );
    // The filter changed while this page was loading; drop the stale page.
    if (state.fromDate != from || state.toDate != to) {
      state = state.copyWith(isLoadingMore: false);
      return;
    }
    result.when(
      success: (page) {
        state = state.copyWith(
          items: [...state.items, ...page.items],
          page: page.currentPage,
          hasMore: page.hasMore,
          isLoadingMore: false,
        );
      },
      failure: (error) {
        state = state.copyWith(isLoadingMore: false);
        ref.read(snackbarServiceProvider).showError(error.message);
      },
    );
  }

  /// Downloads [payment]'s invoice (authenticated) and lets the user save it
  /// permanently via the system "Save" sheet (Downloads / Files / Drive ...).
  ///
  /// Returns the cached copy for previewing once saved, or `null` when the
  /// download failed (shown as a snackbar) or the user cancelled saving.
  Future<String?> downloadInvoice(PaymentEntity payment) async {
    final url = payment.downloadUrl;
    if (url == null || state.downloadingIds.contains(payment.id)) return null;
    state = state.copyWith(
      downloadingIds: {...state.downloadingIds, payment.id},
    );
    try {
      final dir = Directory('${(await getTemporaryDirectory()).path}/invoices');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final fileName =
          '${(payment.invoiceNumber ?? 'invoice-${payment.id}').replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}.pdf';

      final result = await ref
          .read(downloadInvoiceUseCaseProvider)
          .call(url: url, savePath: '${dir.path}/$fileName');
      final cachedPath = result.when(
        success: (path) => path,
        failure: (error) {
          ref.read(snackbarServiceProvider).showError(error.message);
          return null;
        },
      );
      if (cachedPath == null) return null;

      final savedPath = await FilePicker.saveFile(
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        bytes: await File(cachedPath).readAsBytes(),
      );
      return savedPath == null ? null : cachedPath;
    } catch (error) {
      ref.read(snackbarServiceProvider).showError('$error');
      return null;
    } finally {
      state = state.copyWith(
        downloadingIds: {...state.downloadingIds}..remove(payment.id),
      );
    }
  }
}

final paymentHistoryNotifierProvider =
    NotifierProvider.autoDispose<PaymentHistoryNotifier, PaymentHistoryState>(
      PaymentHistoryNotifier.new,
    );
