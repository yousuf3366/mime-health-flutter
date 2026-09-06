import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../utils/face_embedding_utils.dart';

/// On-device face detection + MobileFaceNet embedding generation.
class FaceRecognitionService {
  FaceRecognitionService();

  List<CameraDescription>? _cameras;
  Interpreter? _interpreter;
  FaceDetector? _detector;

  Future<void> ensureInitialized() async {
    _cameras ??= await availableCameras();
    _interpreter ??= await Interpreter.fromAsset(
      'assets/models/mobilefacenet.tflite',
    );
    _detector ??= FaceDetector(
      options: FaceDetectorOptions(enableClassification: false),
    );
  }

  List<CameraDescription> get cameras => _cameras ?? [];

  CameraDescription get preferredFrontCamera {
    final list = cameras;
    return list.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => list.first,
    );
  }

  Future<List<double>?> captureEmbeddingFromPhoto(XFile photo) async {
    await ensureInitialized();
    final detector = _detector!;
    final input = InputImage.fromFilePath(photo.path);
    final faces = await detector.processImage(input);
    if (faces.isEmpty) return null;

    final face = faces.first;
    final cropped = cropFaceImage(photo, face.boundingBox);
    final tensor = convertImageToTensor(cropped);
    return _runEmbedding(tensor);
  }

  Future<List<double>> _runEmbedding(List inputTensor) async {
    final interpreter = _interpreter!;
    final output = List.generate(1, (_) => List.filled(kFaceEmbeddingSize, 0.0));
    interpreter.run(inputTensor, output);
    return List<double>.from(output[0]);
  }

  Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
    _interpreter?.close();
    _interpreter = null;
  }
}

final faceRecognitionServiceProvider = Provider<FaceRecognitionService>(
  (ref) {
    final service = FaceRecognitionService();
    ref.onDispose(service.dispose);
    return service;
  },
);
