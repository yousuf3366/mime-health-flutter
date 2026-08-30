/// Translation keys returned by `/translations/locales/{locale}`.
///
/// Keep UI keyed to these constants so refactors stay type-safe.
class L10nKeys {
  L10nKeys._();

  // Auth
  static const loginTitle = 'mobile.auth.login_title';
  static const nameLabel = 'mobile.auth.name_label';
  static const otpLabel = 'mobile.auth.otp_label';
  static const phoneLabel = 'mobile.auth.phone_label';
  static const resendOtp = 'mobile.auth.resend_otp';
  static const sendOtp = 'mobile.auth.send_otp';
  static const verifyOtp = 'mobile.auth.verify_otp';
  static const signInAsGuest = 'mobile.auth.sign_in_as_guest';
  static const signIn = 'mobile.auth.sign_in';
  static const orContinueWith = 'mobile.auth.or_continue_with';
  static const continueWithGoogle = 'mobile.auth.continue_with_google';

  // Errors
  static const genericError = 'mobile.errors.generic_error';
  static const networkError = 'mobile.errors.network_error';

  // Home
  static const homeStartScan = 'mobile.home.start_scan';
  static const homeWelcome = 'mobile.home.welcome';
  static const homeCreateProfile = 'mobile.home.create_profile';
  static const homeDateOfBirth = 'mobile.home.date_of_birth';
  static const homeMonth = 'mobile.home.month';
  static const homeDay = 'mobile.home.day';
  static const homeYear = 'mobile.home.year';
  static const homeGender = 'mobile.home.gender';
  static const homeMale = 'mobile.home.male';
  static const homeFemale = 'mobile.home.female';
  static const homeLifestyle = 'mobile.home.lifestyle';
  static const homeActive = 'mobile.home.active';
  static const homeModerate = 'mobile.home.moderate';
  static const homeInactive = 'mobile.home.inactive';
  static const homeSelf = 'mobile.home.self';
  static const homeFamily = 'mobile.home.family';
  static const homeOther = 'mobile.home.other';
  static const homeDisplayName = 'mobile.home.display_name';
  static const homeWellBeingTitle = 'mobile.home.well_being_title';
  static const homeSmoker = 'mobile.home.smoker';
  static const homeDiabetes = 'mobile.home.diabetes';
  static const homeHypertension = 'mobile.home.hypertension';
  static const homeHighGlucose = 'mobile.home.high_glucose';

  // Home / Health Hub
  static const homeHubTitle = 'mobile.home.hub_title';
  static const homeHubHeadline = 'mobile.home.hub_headline';
  static const homeHubSubtitle = 'mobile.home.hub_subtitle';
  static const homeNavHome = 'mobile.home.nav_home';
  static const homeNavHealthHub = 'mobile.home.nav_health_hub';
  static const healthHubNoScan = 'mobile.home.health_hub_no_scan';
  static const homeNavFaceScan = 'mobile.home.nav_face_scan';
  static const homeNavTrends = 'mobile.home.nav_trends';
  static const homeNavProfile = 'mobile.home.nav_profile';

  // Feedback
  static const feedbackTooltip = 'mobile.feedback.tooltip';
  static const feedbackTitle = 'mobile.feedback.title';
  static const feedbackMessage = 'mobile.feedback.message';
  static const feedbackRecordVoice = 'mobile.feedback.record_voice';
  static const feedbackStopRecording = 'mobile.feedback.stop_recording';
  static const feedbackAudioReady = 'mobile.feedback.audio_ready';
  static const feedbackRemoveAudio = 'mobile.feedback.remove_audio';
  static const feedbackSend = 'mobile.feedback.send';
  static const feedbackCancel = 'mobile.feedback.cancel';
  static const feedbackRequired = 'mobile.feedback.required';
  static const feedbackMicrophonePermission =
      'mobile.feedback.microphone_permission';

  // Profile details
  static const profileDetailsTitle = 'mobile.profile.details_title';
  static const profileEdit = 'mobile.profile.edit';
  static const profileAddPhoto = 'mobile.profile.add_photo';
  static const profileUpdatePhoto = 'mobile.profile.update_photo';
  static const profileBloodGroup = 'mobile.profile.blood_group';
  static const profileHeight = 'mobile.profile.height';
  static const profileHeightFeet = 'mobile.profile.height_feet';
  static const profileHeightInches = 'mobile.profile.height_inches';
  static const profileWeight = 'mobile.profile.weight';
  static const profileWeightKg = 'mobile.profile.weight_kg';
  static const profileAge = 'mobile.profile.age';
  static const profilePhone = 'mobile.profile.phone';
  static const profileEmail = 'mobile.profile.email';
  static const profileStatus = 'mobile.profile.status';
  static const profileKind = 'mobile.profile.kind';
  static const profileYes = 'mobile.common.yes';
  static const profileNo = 'mobile.common.no';
  static const profileNotSet = 'mobile.common.not_set';
  static const profilePhotoSoon = 'mobile.profile.photo_soon';
  static const profilePhotoChoose = 'mobile.profile.photo_choose';
  static const profilePhotoUploadSuccess =
      'mobile.profile.photo_upload_success';
  static const mediaCamera = 'mobile.media.camera';
  static const mediaGallery = 'mobile.media.gallery';
  static const mediaFiles = 'mobile.media.files';
  static const mediaCancel = 'mobile.media.cancel';
  static const mediaChooseSource = 'mobile.media.choose_source';

  // Face scan
  static const faceScanTitle = 'mobile.face_scan.title';
  static const faceScanIntro = 'mobile.face_scan.intro';
  static const faceScanTipLightingTitle = 'mobile.face_scan.tip_lighting_title';
  static const faceScanTipLightingBody = 'mobile.face_scan.tip_lighting_body';
  static const faceScanTipHoldStillTitle =
      'mobile.face_scan.tip_hold_still_title';
  static const faceScanTipHoldStillBody =
      'mobile.face_scan.tip_hold_still_body';
  static const faceScanTipScreenOnTitle =
      'mobile.face_scan.tip_screen_on_title';
  static const faceScanTipScreenOnBody = 'mobile.face_scan.tip_screen_on_body';
  static const faceScanConsent = 'mobile.face_scan.consent';
  static const faceScanStart = 'mobile.face_scan.start';
  static const questionnaireTitle = 'mobile.face_scan.questionnaire_title';
  static const questionnaireProgress =
      'mobile.face_scan.questionnaire_progress';
  static const questionnaireSkip = 'mobile.face_scan.questionnaire_skip';
  static const faceScanChoosePlan = 'mobile.face_scan.choose_plan';
  static const faceScanPlanRequired = 'mobile.face_scan.plan_required';
  static const faceScanUrlFailedMessage = 'mobile.face_scan.face_scan_url_failed';
  static const faceScanResultsLoadingTitle =
      'mobile.face_scan.results_loading_title';
  static const faceScanResultsLoadingSubtitle =
      'mobile.face_scan.results_loading_subtitle';
  static const healthDashboardTitle = 'mobile.health_dashboard.title';
  static const healthDashboardOverallScore =
      'mobile.health_dashboard.overall_score';
  static const healthDashboardBiomarkers = 'mobile.health_dashboard.biomarkers';
  static const healthDashboardHeartRate = 'mobile.health_dashboard.heart_rate';
  static const healthDashboardBloodPressure =
      'mobile.health_dashboard.blood_pressure';
  static const healthDashboardRespRate = 'mobile.health_dashboard.resp_rate';
  static const healthDashboardSpo2 = 'mobile.health_dashboard.spo2';
  static const healthDashboardHrv = 'mobile.health_dashboard.hrv';
  static const healthDashboardMetrics = 'mobile.health_dashboard.metrics';
  static const healthDashboardUpgradeTitle =
      'mobile.health_dashboard.upgrade_title';
  static const healthDashboardUpgradeBody =
      'mobile.health_dashboard.upgrade_body';
  static const healthDashboardUpgradeCta =
      'mobile.health_dashboard.upgrade_cta';
  static const healthDashboardConsult =
      'mobile.health_dashboard.consult_doctors';
  static const healthDashboardLabTest = 'mobile.health_dashboard.book_lab_test';
  static const healthDashboardMedicine =
      'mobile.health_dashboard.order_medicine';

  // Subscription
  static const subscriptionTitle = 'mobile.subscription.title';
  static const subscriptionSubtitle = 'mobile.subscription.subtitle';
  static const subscriptionMonthly = 'mobile.subscription.monthly';
  static const subscriptionAnnual = 'mobile.subscription.annual';
  static const subscriptionContinue = 'mobile.subscription.continue';
  static const subscriptionUnlimited = 'mobile.subscription.unlimited';
  static const subscriptionProfiles = 'mobile.subscription.profiles';
  static const subscriptionScans = 'mobile.subscription.scans';
  static const subscriptionTrial = 'mobile.subscription.trial';
  static const subscriptionBiomarkers = 'mobile.subscription.biomarkers';
  static const subscriptionDevices = 'mobile.subscription.devices';
  static const subscriptionPayNow = 'mobile.subscription.pay_now';
  static const subscriptionHealthCheckup = 'mobile.subscription.health_checkup';

  // Settings
  static const language = 'mobile.settings.language';
  static const languageBn = 'mobile.settings.language_bn';
  static const languageEn = 'mobile.settings.language_en';

  // Local-only keys (not yet provided by the API)
  static const appName = 'mobile.app.name';
  static const changePhone = 'mobile.auth.change_phone';
  static const otpSentTo = 'mobile.auth.otp_sent_to';
  static const resendOtpIn = 'mobile.auth.resend_otp_in';
  static const logout = 'mobile.settings.logout';
  static const logoutConfirmTitle = 'mobile.settings.logout_confirm_title';
  static const logoutConfirmMessage = 'mobile.settings.logout_confirm_message';
  static const retry = 'mobile.common.retry';
  static const splashLoading = 'mobile.splash.loading';
  static const notFoundTitle = 'mobile.errors.not_found_title';
  static const notFoundMessage = 'mobile.errors.not_found_message';
  static const goHome = 'mobile.common.go_home';
  static const homeTitle = 'mobile.home.title';
}
