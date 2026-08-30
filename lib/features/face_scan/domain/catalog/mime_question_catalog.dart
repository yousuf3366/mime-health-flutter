import '../entity/mime_question.dart';

/// Static catalog of post-scan IntelliProve questionnaire items.
abstract final class MimeQuestionCatalog {
  static const postScanQuestions = <MimeQuestion>[
    MimeQuestion(
      lookupKey: 'average_sleep_hours',
      questionEn: 'On average, how many hours do you sleep at night?',
      questionBn: 'গড়ে রাতে কত ঘণ্টা ঘুমান?',
      subtitleEn: 'Based on the last few weeks',
      subtitleBn: 'সাম্প্রতিক কয়েক সপ্তাহের অভিজ্ঞতা অনুযায়ী',
      options: [
        MimeQuestionOption(
          value: 1,
          labelEn: 'Less than 4 hours',
          labelBn: '৪ ঘণ্টার কম',
        ),
        MimeQuestionOption(
          value: 2,
          labelEn: '4–6 hours',
          labelBn: '৪–৬ ঘণ্টা',
        ),
        MimeQuestionOption(
          value: 3,
          labelEn: '6–7 hours',
          labelBn: '৬–৭ ঘণ্টা',
        ),
        MimeQuestionOption(
          value: 4,
          labelEn: '7–8 hours',
          labelBn: '৭–৮ ঘণ্টা',
        ),
        MimeQuestionOption(
          value: 5,
          labelEn: 'More than 8 hours',
          labelBn: '৮ ঘণ্টার বেশি',
        ),
      ],
    ),
    MimeQuestion(
      lookupKey: 'feeling_stressed_last_month',
      questionEn: 'How stressed have you felt in the last month?',
      questionBn: 'গত এক মাসে আপনি কতটা চাপ অনুভব করেছেন?',
      options: [
        MimeQuestionOption(
          value: 1,
          labelEn: 'Not at all',
          labelBn: 'একদম না',
        ),
        MimeQuestionOption(
          value: 2,
          labelEn: 'Slightly',
          labelBn: 'সামান্য',
        ),
        MimeQuestionOption(
          value: 3,
          labelEn: 'Moderately',
          labelBn: 'মাঝারি',
        ),
        MimeQuestionOption(
          value: 4,
          labelEn: 'Very',
          labelBn: 'বেশি',
        ),
        MimeQuestionOption(
          value: 5,
          labelEn: 'Extremely',
          labelBn: 'খুব বেশি',
        ),
      ],
    ),
    MimeQuestion(
      lookupKey: 'daily_activities',
      questionEn: 'How is your energy for daily activities?',
      questionBn: 'দৈনন্দিন কাজকর্মে আপনার শক্তি কেমন?',
      options: [
        MimeQuestionOption(
          value: 1,
          labelEn: 'Very low',
          labelBn: 'খুব কম',
        ),
        MimeQuestionOption(
          value: 2,
          labelEn: 'Low',
          labelBn: 'কম',
        ),
        MimeQuestionOption(
          value: 3,
          labelEn: 'Moderate',
          labelBn: 'মাঝারি',
        ),
        MimeQuestionOption(
          value: 4,
          labelEn: 'Good',
          labelBn: 'ভালো',
        ),
        MimeQuestionOption(
          value: 5,
          labelEn: 'Very good',
          labelBn: 'খুব ভালো',
        ),
      ],
    ),
    MimeQuestion(
      lookupKey: 'hours_sport_week',
      questionEn: 'How many hours of physical activity do you do per week?',
      questionBn: 'সপ্তাহে কত ঘণ্টা শারীরিক কার্যকলাপ করেন?',
      options: [
        MimeQuestionOption(
          value: 1,
          labelEn: 'None',
          labelBn: 'কিছুই না',
        ),
        MimeQuestionOption(
          value: 2,
          labelEn: 'Less than 1 hour',
          labelBn: '১ ঘণ্টার কম',
        ),
        MimeQuestionOption(
          value: 3,
          labelEn: '1–3 hours',
          labelBn: '১–৩ ঘণ্টা',
        ),
        MimeQuestionOption(
          value: 4,
          labelEn: '3–5 hours',
          labelBn: '৩–৫ ঘণ্টা',
        ),
        MimeQuestionOption(
          value: 5,
          labelEn: 'More than 5 hours',
          labelBn: '৫ ঘণ্টার বেশি',
        ),
      ],
    ),
    MimeQuestion(
      lookupKey: 'nightly_wake_ups',
      questionEn: 'How often do you wake up during the night?',
      questionBn: 'রাতে ঘুমের মাঝে কতবার জেগে ওঠেন?',
      options: [
        MimeQuestionOption(
          value: 1,
          labelEn: 'Never',
          labelBn: 'কখনো না',
        ),
        MimeQuestionOption(
          value: 2,
          labelEn: 'Once',
          labelBn: '১ বার',
        ),
        MimeQuestionOption(
          value: 3,
          labelEn: 'Twice',
          labelBn: '২ বার',
        ),
        MimeQuestionOption(
          value: 4,
          labelEn: '3 times',
          labelBn: '৩ বার',
        ),
        MimeQuestionOption(
          value: 5,
          labelEn: 'More than 3 times',
          labelBn: '৩ বারের বেশি',
        ),
      ],
    ),
  ];
}
