export '../controller/splash_controller.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/splash_controller.dart';

final splashControllerProvider =
    NotifierProvider<SplashController, SplashState>(SplashController.new);
