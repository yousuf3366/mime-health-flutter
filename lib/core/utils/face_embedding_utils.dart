import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

/// Cosine similarity threshold for face match (MobileFaceNet POC).
const double kFaceMatchThreshold = 0.75;

/// MobileFaceNet output dimension.
const int kFaceEmbeddingSize = 192;

img.Image cropFaceImage(XFile file, Rect rect) {
  final bytes = File(file.path).readAsBytesSync();
  final originalImage = img.decodeImage(bytes)!;

  final croppedFace = img.copyCrop(
    originalImage,
    x: rect.left.toInt().clamp(0, originalImage.width - 1),
    y: rect.top.toInt().clamp(0, originalImage.height - 1),
    width: rect.width.toInt().clamp(1, originalImage.width),
    height: rect.height.toInt().clamp(1, originalImage.height),
  );
  return img.copyResize(croppedFace, width: 112, height: 112);
}

List convertImageToTensor(img.Image resizedFace) {
  return List.generate(
    1,
    (_) => List.generate(
      112,
      (y) => List.generate(112, (x) {
        final pixel = resizedFace.getPixel(x, y);
        return [
          (pixel.r - 127.5) / 127.5,
          (pixel.g - 127.5) / 127.5,
          (pixel.b - 127.5) / 127.5,
        ];
      }),
    ),
  );
}

double cosineSimilarity(List<double> a, List<double> b) {
  if (a.length != b.length || a.isEmpty) return 0;
  var dot = 0.0;
  var normA = 0.0;
  var normB = 0.0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  if (normA == 0 || normB == 0) return 0;
  return dot / (sqrt(normA) * sqrt(normB));
}

String encodeEmbedding(List<double> embedding) => jsonEncode(embedding);

List<double>? decodeEmbedding(String? encoded) {
  if (encoded == null || encoded.trim().isEmpty) return null;
  try {
    final decoded = jsonDecode(encoded);
    if (decoded is! List) return null;
    return decoded.map((e) => (e as num).toDouble()).toList();
  } catch (_) {
    return null;
  }
}

bool facesMatch(List<double> stored, List<double> live) {
  return cosineSimilarity(stored, live) > kFaceMatchThreshold;
}
