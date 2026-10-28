import '../../domain/entity/subscription_entity.dart';
import '../model/subscription_models.dart';

class SubscriptionMapper {
  SubscriptionMapper._();

  static CheckoutEntity toCheckoutEntity(
    CheckoutPaymentModel payment,
    String redirectUrl,
  ) {
    return CheckoutEntity(
      paymentId: payment.id,
      status: payment.status,
      amountBdt: payment.amountBdt,
      currency: payment.currency,
      redirectUrl: redirectUrl,
      invoiceNumber: payment.invoiceNumber,
      gatewayReference: payment.gatewayReference,
    );
  }

  static SubscriptionPlanEntity toPlanEntity(SubscriptionPlanModel model) {
    return SubscriptionPlanEntity(
      code: model.code,
      name: model.name,
      tierType: model.tierType,
      maxProfiles: model.maxProfiles,
      includedPrimaryDevices: model.includedPrimaryDevices,
      includedSecondaryDevices: model.includedSecondaryDevices,
      maxAdditionalDevices: model.maxAdditionalDevices,
      monthlyScanQuota: model.monthlyScanQuota,
      biomarkerCodes: model.biomarkerCodes,
      metricCodes: model.metricCodes,
      historyRetentionDays: model.historyRetentionDays,
      monthlyPriceBdt: model.monthlyPriceBdt,
      annualPriceBdt: model.annualPriceBdt,
      trialDays: model.trialDays,
      sortOrder: model.sortOrder,
      services: toServiceEntities(model.services),
      pricingMode: model.pricingMode,
      image: model.image,
    );
  }

  static List<SubscriptionServiceEntity> toServiceEntities(
    List<SubscriptionServiceModel> models,
  ) {
    return models
        .map(
          (s) => SubscriptionServiceEntity(
            code: s.code,
            name: s.name,
            type: s.type,
          ),
        )
        .toList(growable: false);
  }

  static List<SubscriptionPlanEntity> toPlanEntities(
    List<SubscriptionPlanModel> models,
  ) {
    return models.map(toPlanEntity).toList(growable: false);
  }

  static SelectedSubscriptionEntity toSelectedEntity(
    SelectedSubscriptionModel model,
  ) {
    return SelectedSubscriptionEntity(
      id: model.id,
      status: model.status,
      billingInterval: BillingInterval.fromApi(model.billingInterval),
      currentPeriodStart: model.currentPeriodStart,
      currentPeriodEnd: model.currentPeriodEnd,
      externalUserId: model.externalUserId,
      trialEndsAt: model.trialEndsAt,
      cancelAt: model.cancelAt,
      cancelledAt: model.cancelledAt,
      cancelReason: model.cancelReason,
      isTrialing: model.isTrialing,
      isCancelScheduled: model.isCancelScheduled,
      plan: toPlanEntity(model.plan),
    );
  }

  static PaymentHistoryPageEntity toPaymentHistoryPage(
    PaymentHistoryResponseModel model,
  ) {
    final pagination = model.pagination;
    return PaymentHistoryPageEntity(
      items: model.items.map(toPaymentEntity).toList(growable: false),
      currentPage: pagination?.currentPage ?? 1,
      lastPage: pagination?.lastPage ?? 1,
      total: pagination?.total ?? model.items.length,
    );
  }

  static PaymentEntity toPaymentEntity(PaymentModel model) {
    return PaymentEntity(
      id: model.id,
      subscriptionId: model.subscriptionId,
      parentUserId: model.parentUserId,
      purpose: model.purpose,
      amountBdt: model.amountBdt,
      currency: model.currency,
      paymentMethod: model.paymentMethod,
      status: model.status,
      gateway: model.gateway,
      gatewayReference: model.gatewayReference,
      gatewayTransactionId: model.gatewayTransactionId,
      invoiceNumber: model.invoiceNumber,
      lineItems: model.lineItems
          .map(
            (item) => PaymentLineItemEntity(
              type: item.type,
              code: item.code,
              title: item.title,
              amountBdt: item.amountBdt,
              billingInterval: item.billingInterval,
            ),
          )
          .toList(growable: false),
      paidAt: model.paidAt,
      reconciledAt: model.reconciledAt,
      failureReason: model.failureReason,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      downloadUrl: model.downloadUrl,
    );
  }

  static SubscriptionEligibilityEntity toEligibilityEntity(
    SubscriptionEligibilityModel model,
  ) {
    return SubscriptionEligibilityEntity(
      trialConsumed: model.trialConsumed,
      freePlanConsumed: model.freePlanConsumed,
      trialAvailable: model.trialAvailable,
      trialConsumedAt: model.trialConsumedAt,
      freePlanConsumedAt: model.freePlanConsumedAt,
    );
  }

  static SubscriptionServiceOfferEntity toServiceOfferEntity(
    SubscriptionServiceOfferModel model,
  ) {
    return SubscriptionServiceOfferEntity(
      code: model.code,
      name: model.name,
      type: model.type,
      monthlyPriceBdt: model.monthlyPriceBdt,
      annualPriceBdt: model.annualPriceBdt,
      description: model.description,
    );
  }

  static SubscriptionAddonEntity toAddonEntity(SubscriptionAddonModel model) {
    return SubscriptionAddonEntity(
      id: model.id,
      code: model.code,
      name: model.name,
      status: model.status,
      billingInterval: model.billingInterval,
      amountBdt: model.amountBdt,
      purchaseType: model.purchaseType,
      serviceType: model.serviceType,
      startsAt: model.startsAt,
      endsAt: model.endsAt,
      daysUntilExpiry: model.daysUntilExpiry,
      subscriptionId: model.subscriptionId,
      lastPaymentId: model.lastPaymentId,
    );
  }

  static MySubscriptionEntity? toMySubscriptionEntity(
    MySubscriptionDataModel? data,
  ) {
    if (data == null) return null;
    final subscription = data.subscription;
    final eligibility = data.eligibility;
    final quota = data.quota;
    return MySubscriptionEntity(
      status: data.status,
      subscription: subscription == null
          ? null
          : toSelectedEntity(subscription),
      pendingPlanChange: data.pendingPlanChange,
      eligibility: eligibility == null
          ? null
          : toEligibilityEntity(eligibility),
      addons: data.addons.map(toAddonEntity).toList(growable: false),
      quota: quota == null
          ? null
          : SubscriptionQuotaEntity(
              periodYear: quota.periodYear,
              periodMonth: quota.periodMonth,
              scansUsed: quota.scansUsed,
              quotaLimit: quota.quotaLimit,
              remaining: quota.remaining,
            ),
    );
  }
}
