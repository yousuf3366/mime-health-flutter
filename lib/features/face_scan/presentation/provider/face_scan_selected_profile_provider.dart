import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/domain/entity/profile_entity.dart';

/// Profile chosen on the face-scan profile picker. `null` shows the picker.
final faceScanSelectedProfileProvider = StateProvider<ProfileEntity?>(
  (ref) => null,
);
