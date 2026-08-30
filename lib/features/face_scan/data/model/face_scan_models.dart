import '../../domain/entity/face_scan_entity.dart';

class EnsureUserRequestModel {
  const EnsureUserRequestModel({
    required this.externalUserId,
    required this.language,
    this.sex,
  });

  final String externalUserId;
  final String language;
  final String? sex;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'external_user_id': externalUserId,
      'language': language,
      if (sex != null) 'sex': sex,
    };
  }
}

class FaceScanQuestionAnswerRequestModel {
  const FaceScanQuestionAnswerRequestModel({
    required this.lookupKey,
    required this.value,
    required this.timezone,
  });

  final String lookupKey;
  final Object value;
  final String timezone;

  factory FaceScanQuestionAnswerRequestModel.fromEntity(
    FaceScanQuestionAnswer answer, {
    required String timezone,
  }) {
    return FaceScanQuestionAnswerRequestModel(
      lookupKey: answer.lookupKey,
      value: answer.value,
      timezone: timezone,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lookup_key': lookupKey,
      'value': value,
      'timezone': timezone,
    };
  }
}

class IntelliProveUserResponseModel {
  const IntelliProveUserResponseModel({required this.userId});

  final String userId;

  factory IntelliProveUserResponseModel.fromJson(Map<String, dynamic> json) {
    return IntelliProveUserResponseModel(
      userId: json['user_id']?.toString() ?? '',
    );
  }
}
