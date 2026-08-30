import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entity/profile_entity.dart';
import '../widget/create_profile_form.dart';

class CreateProfilePage extends ConsumerWidget {
  const CreateProfilePage({super.key, this.profile});

  final ProfileEntity? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CreateProfileForm(profile: profile),
    );
  }
}
