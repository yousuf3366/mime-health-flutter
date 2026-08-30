import '../../domain/entity/subscription_entity.dart';
import '../model/subscription_models.dart';

class SubscriptionMapper {
  SubscriptionMapper._();

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
      image: model.image,
    );
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
      plan: toPlanEntity(model.plan),
    );
  }

  static MySubscriptionEntity? toMySubscriptionEntity(
    MySubscriptionDataModel? data,
  ) {
    final subscription = data?.subscription;
    if (subscription == null) return null;
    final entitlements = data?.entitlements;
    final quota = data?.quota;
    return MySubscriptionEntity(
      subscription: toSelectedEntity(subscription),
      entitlements: entitlements == null
          ? null
          : SubscriptionEntitlementsEntity(
              maxProfiles: entitlements.maxProfiles,
              monthlyScanQuota: entitlements.monthlyScanQuota,
              biomarkerCodes: entitlements.biomarkerCodes,
              metricCodes: entitlements.metricCodes,
              historyRetentionDays: entitlements.historyRetentionDays,
              isPaid: entitlements.isPaid,
              daysUntilPeriodEnd: entitlements.daysUntilPeriodEnd,
            ),
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
