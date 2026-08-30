import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../providers/core_providers.dart';

/// Network image that allows bad SSL certificates for **image downloads only**.
///
/// Attaches the Bearer token only when [url] is under [AppConfig.baseUrl]
/// (API-hosted media). Absolute storage URLs (e.g. `:8443/storage/...`) are
/// loaded without auth.
class AppNetworkImage extends ConsumerWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.errorBuilder,
    this.loadingBuilder,
    this.withAuth,
  });

  final String url;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  /// When null, auth is applied only if [url] starts with [AppConfig.baseUrl].
  final bool? withAuth;

  bool get _shouldAttachAuth {
    if (withAuth != null) return withAuth!;
    final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    return url.startsWith(base);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_shouldAttachAuth) {
      return Image(
        image: AppNetworkImageProvider(url),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
      );
    }

    return FutureBuilder<String?>(
      future: ref.read(secureStorageProvider).getAccessToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final token = snapshot.data;
        return Image(
          image: AppNetworkImageProvider(
            url,
            authToken: (token != null && token.isNotEmpty) ? token : null,
          ),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
        );
      },
    );
  }
}

@immutable
class AppNetworkImageProvider extends ImageProvider<AppNetworkImageProvider> {
  const AppNetworkImageProvider(this.url, {this.authToken});

  final String url;
  final String? authToken;

  @override
  Future<AppNetworkImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AppNetworkImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    AppNetworkImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode, chunkEvents),
      chunkEvents: chunkEvents.stream,
      scale: 1.0,
      debugLabel: url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<String>('URL', url),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    AppNetworkImageProvider key,
    ImageDecoderCallback decode,
    StreamController<ImageChunkEvent> chunkEvents,
  ) async {
    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    client.connectionTimeout = AppConfig.connectTimeout;

    try {
      var uri = Uri.parse(key.url);
      // Plain HTTP against an HTTPS storage port returns 400.
      if (uri.scheme == 'http' &&
          (uri.port == 8443 || uri.path.contains('/storage/'))) {
        uri = uri.replace(scheme: 'https');
      }
      if (!uri.hasScheme || uri.host.isEmpty) {
        throw ArgumentError('Invalid avatar URL: ${key.url}');
      }

      final request = await client.getUrl(uri);
      request.followRedirects = true;
      final token = key.authToken;
      if (token != null && token.isNotEmpty) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          '${AppConstants.bearerPrefix}$token',
        );
      }

      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        if (kDebugMode) {
          debugPrint(
            '[AppNetworkImage] HTTP ${response.statusCode} for ${key.url}',
          );
        }
        throw NetworkImageLoadException(
          statusCode: response.statusCode,
          uri: uri,
        );
      }

      final bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (cumulative, total) {
          chunkEvents.add(
            ImageChunkEvent(
              cumulativeBytesLoaded: cumulative,
              expectedTotalBytes: total,
            ),
          );
        },
      );

      if (bytes.isEmpty) {
        throw StateError('Empty image body for $url');
      }

      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AppNetworkImage] failed for $url: $error');
        debugPrint('$stackTrace');
      }
      rethrow;
    } finally {
      chunkEvents.close();
      client.close(force: true);
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AppNetworkImageProvider &&
        other.url == url &&
        other.authToken == authToken;
  }

  @override
  int get hashCode => Object.hash(url, authToken);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'AppNetworkImageProvider')}("$url")';
}
