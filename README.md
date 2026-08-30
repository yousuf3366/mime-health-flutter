# Mime Health

Production-ready Flutter application built with Clean Architecture, Riverpod, and Dio.

## Stack

- Flutter 3.41 / Dart 3.11 / Material 3
- State management & DI: `flutter_riverpod`, `hooks_riverpod`, `flutter_hooks`
- Networking: Dio + Auth / Logging / Retry interceptors + `talker_dio_logger`
- Storage: `flutter_secure_storage` (tokens) + `shared_preferences` (prefs)
- Routing: GoRouter with auth redirects
- Connectivity: `connectivity_plus` + global offline banner
- Device info: `device_info_plus`
- Localization: English + Bangla via API-driven string maps

## Run

```bash
flutter pub get
flutter run
```

## API

1. Start your API so it listens on `0.0.0.0:8080` (not only `127.0.0.1`).
2. Point the app at a reachable host:

```bash
# Same Wi‑Fi physical device / iOS Simulator using this Mac's LAN IP
flutter run --dart-define=API_BASE_URL=http://192.168.20.237:8080

# Android emulator → host machine
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

# iOS Simulator / desktop localhost
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

`Connection refused` means nothing is accepting TCP on that host:port from the device.

## Architecture

```
UI → Controller → UseCase → Repository → Datasource → Dio
```

Feature-first folders under `lib/features/` with shared infrastructure in `lib/core/`.

## Debug network inspector

In debug builds, tap the floating bug icon to open Talker network logs.
