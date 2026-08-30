import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Snapshot of device metadata used for analytics / headers.
class DeviceInfo {
  const DeviceInfo({
    required this.platform,
    required this.brand,
    required this.model,
    required this.osVersion,
    required this.sdkVersion,
    required this.manufacturer,
    required this.isPhysicalDevice,
    required this.uniqueId,
  });

  final String platform;
  final String brand;
  final String model;
  final String osVersion;
  final String sdkVersion;
  final String manufacturer;
  final bool isPhysicalDevice;
  final String uniqueId;

  Map<String, String> toHeaders() => {
        'X-Device-Platform': platform,
        'X-Device-Model': model,
        'X-Device-OS': osVersion,
        'X-Device-Id': uniqueId,
      };
}

/// Collects platform-specific device information via [device_info_plus].
class DeviceInfoService {
  DeviceInfoService({DeviceInfoPlugin? plugin})
      : _plugin = plugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _plugin;
  DeviceInfo? _cached;

  Future<DeviceInfo> getDeviceInfo() async {
    if (_cached != null) return _cached!;

    if (kIsWeb) {
      final web = await _plugin.webBrowserInfo;
      _cached = DeviceInfo(
        platform: 'web',
        brand: web.browserName.name,
        model: web.appName ?? 'browser',
        osVersion: web.appVersion ?? 'unknown',
        sdkVersion: web.productSub ?? 'unknown',
        manufacturer: web.vendor ?? 'unknown',
        isPhysicalDevice: true,
        uniqueId: const Uuid().v4(),
      );
      return _cached!;
    }

    if (Platform.isAndroid) {
      final android = await _plugin.androidInfo;
      _cached = DeviceInfo(
        platform: 'android',
        brand: android.brand,
        model: android.model,
        osVersion: android.version.release,
        sdkVersion: '${android.version.sdkInt}',
        manufacturer: android.manufacturer,
        isPhysicalDevice: android.isPhysicalDevice,
        uniqueId: android.id,
      );
    } else if (Platform.isIOS) {
      final ios = await _plugin.iosInfo;
      _cached = DeviceInfo(
        platform: 'ios',
        brand: 'Apple',
        model: ios.utsname.machine,
        osVersion: ios.systemVersion,
        sdkVersion: ios.systemVersion,
        manufacturer: 'Apple',
        isPhysicalDevice: ios.isPhysicalDevice,
        uniqueId: ios.identifierForVendor ?? const Uuid().v4(),
      );
    } else if (Platform.isMacOS) {
      final mac = await _plugin.macOsInfo;
      _cached = DeviceInfo(
        platform: 'macos',
        brand: 'Apple',
        model: mac.model,
        osVersion: mac.osRelease,
        sdkVersion: mac.majorVersion.toString(),
        manufacturer: 'Apple',
        isPhysicalDevice: true,
        uniqueId: mac.systemGUID ?? const Uuid().v4(),
      );
    } else {
      _cached = DeviceInfo(
        platform: defaultTargetPlatform.name,
        brand: 'unknown',
        model: 'unknown',
        osVersion: 'unknown',
        sdkVersion: 'unknown',
        manufacturer: 'unknown',
        isPhysicalDevice: true,
        uniqueId: const Uuid().v4(),
      );
    }

    return _cached!;
  }
}
