// // lib/controller/live_camera_emotion_provider.dart
// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:camera/camera.dart';
// import 'package:emo_music_app/utils/model_loader.dart';
// import 'package:flutter/material.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// enum DetectionState { initial, detecting, success, error }

// class LiveCameraEmotionProvider extends ChangeNotifier {
//   CameraController? _cameraController;
//   Interpreter? _interpreter;
//   List<String> _labels = [];

//   bool _isCameraInitialized = false;
//   bool _isDetecting = false;
//   DetectionState _detectionState = DetectionState.initial;
//   String _detectedEmotion = '';
//   String _errorMessage = '';

//   // Model input
//   final int modelInputSize = 224;
//   final double detectionConfidenceThreshold = 0.60;

//   bool get isCameraInitialized => _isCameraInitialized;
//   DetectionState get detectionState => _detectionState;
//   String get detectedEmotion => _detectedEmotion;
//   String get errorMessage => _errorMessage;
//   CameraController? get cameraController => _cameraController;

//   ///  initialize model + camera
//   Future<void> initialize() async {
//     if (_isCameraInitialized) return;

//     try {
//       await _loadModelAndLabels();
//       await _initializeCamera();
//       _isCameraInitialized = true;
//       _detectionState = DetectionState.initial;
//       log('LiveCameraEmotionProvider: initialized');
//     } catch (e, st) {
//       _detectionState = DetectionState.error;
//       _errorMessage = 'Initialization failed: $e';
//       log('Init error: $e\n$st');
//     } finally {
//       notifyListeners();
//     }
//   }

//   /// start camera + detection
//   Future<void> startCameraAndDetect() async {
//     if (!_isCameraInitialized) {
//       await initialize();
//     }
//     startDetection();
//   }

//   /// Start streaming frames and detecting
//   void startDetection() {
//     if (!_isCameraInitialized) {
//       log('startDetection: camera not initialized');
//       return;
//     }
//     if (_detectionState == DetectionState.detecting) return;

//     _detectionState = DetectionState.detecting;
//     notifyListeners();

//     _cameraController?.startImageStream((CameraImage image) {
//       if (_isDetecting) return;
//       _isDetecting = true;
//       _runModelOnFrame(image).whenComplete(() => _isDetecting = false);
//     });
//   }

//   /// Stop the image stream
//   Future<void> stopDetection() async {
//     try {
//       await _cameraController?.stopImageStream();
//     } catch (_) {
//     } finally {
//       _detectionState = DetectionState.initial;
//       notifyListeners();
//     }
//   }

//   /// Shut down camera and interpreter
//   Future<void> stopCamera() async {
//     await stopDetection();
//     try {
//       await _cameraController?.dispose();
//     } catch (_) {}
//     _cameraController = null;
//     _isCameraInitialized = false;
//     notifyListeners();
//   }

//   /// Reset to initial state
//   Future<void> reset() async {
//     await stopDetection();
//     _detectedEmotion = '';
//     _errorMessage = '';
//     _detectionState = DetectionState.initial;
//     notifyListeners();
//   }

//   // ---------------- Model & labels ----------------
//   Future<void> _loadModelAndLabels() async {
//     final modelPath = await ModelLoader.getModelPath(
//       'assets/ml/model_emotion.tflite',
//     );
//     _interpreter = Interpreter.fromFile(File(modelPath));

//     final labelsPath = await ModelLoader.getModelPath('assets/ml/labels.txt');
//     final labelsData = await File(labelsPath).readAsString();
//     _labels = labelsData
//         .split('\n')
//         .map((s) => s.trim())
//         .where((s) => s.isNotEmpty)
//         .toList();

//     if (_labels.isEmpty) throw Exception('labels.txt is empty');
//     log('Loaded model and ${_labels.length} labels');
//   }

//   // ---------------- Camera init ----------------
//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final frontCamera = cameras.firstWhere(
//       (c) => c.lensDirection == CameraLensDirection.front,
//       orElse: () => cameras.first,
//     );

//     _cameraController = CameraController(
//       frontCamera,
//       ResolutionPreset.medium,
//       enableAudio: false,
//       imageFormatGroup: ImageFormatGroup.yuv420,
//     );

//     await _cameraController!.initialize();
//     log('Camera initialized: ${frontCamera.name}');
//   }

//   // ---------------- Inference on frame ----------------
//   Future<void> _runModelOnFrame(CameraImage image) async {
//     try {
//       if (_interpreter == null) {
//         log('Interpreter not loaded - skipping frame');
//         return;
//       }

//       // Converting YUV420 -> RGB bytes (R,G,B per pixel)
//       final Uint8List rgbBytes = _yuv420ToRgb(image);

//       final int srcW = image.width;
//       final int srcH = image.height;
//       final int dst = modelInputSize;

//       final double xRatio = srcW / dst;
//       final double yRatio = srcH / dst;

//       // Build nested dart lists [1, dst, dst, 3] normalized 0..1
//       final input = [
//         List.generate(dst, (y) {
//           final int sy = (y * yRatio).floor().clamp(0, srcH - 1);
//           return List.generate(dst, (x) {
//             final int sx = (x * xRatio).floor().clamp(0, srcW - 1);
//             final int base = (sy * srcW + sx) * 3;
//             final int r = rgbBytes[base];
//             final int g = rgbBytes[base + 1];
//             final int b = rgbBytes[base + 2];
//             return [r / 255.0, g / 255.0, b / 255.0];
//           });
//         }),
//       ];

//       // Output buffer [1, num_labels]
//       final output = List.generate(
//         1,
//         (_) => List<double>.filled(_labels.length, 0.0),
//       );

//       // Run inference
//       _interpreter!.run(input, output);

//       final scores = output[0];
//       int bestIdx = 0;
//       double bestScore = scores[0];
//       for (int i = 1; i < scores.length; i++) {
//         if (scores[i] > bestScore) {
//           bestScore = scores[i];
//           bestIdx = i;
//         }
//       }

//       // If low confidence, keep running stream
//       if (bestScore < detectionConfidenceThreshold) {
//         log(
//           'Low confidence ${bestScore.toStringAsFixed(3)} -> continue streaming',
//         );
//         return;
//       }

//       _detectedEmotion = _labels[bestIdx];
//       _detectionState = DetectionState.success;
//       log('Detected emotion: $_detectedEmotion (score: $bestScore)');

//       // Stop detection (keeps camera preview available). UI will typically close screen.
//       await stopDetection();
//       notifyListeners();
//     } catch (e, st) {
//       log('Inference error: $e\n$st');
//       _detectionState = DetectionState.error;
//       _errorMessage = 'Inference failed: $e';
//       await stopDetection();
//       notifyListeners();
//     }
//   }

//   /// Convert YUV420 -> RGB bytes with order R,G,B per pixel
//   Uint8List _yuv420ToRgb(CameraImage image) {
//     final int width = image.width;
//     final int height = image.height;

//     final Uint8List yBuf = image.planes[0].bytes;
//     final Uint8List uBuf = image.planes[1].bytes;
//     final Uint8List vBuf = image.planes[2].bytes;

//     final int yRowStride = image.planes[0].bytesPerRow;
//     final int uvRowStride = image.planes[1].bytesPerRow;
//     final int uvPixelStride = image.planes[1].bytesPerPixel!;

//     final Uint8List rgb = Uint8List(width * height * 3);
//     int index = 0;

//     for (int y = 0; y < height; y++) {
//       for (int x = 0; x < width; x++) {
//         final int yIndex = y * yRowStride + x;
//         final int uvIndex = (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;

//         final int yVal = yBuf[yIndex] & 0xff;
//         final int uVal = uBuf[uvIndex] & 0xff;
//         final int vVal = vBuf[uvIndex] & 0xff;

//         final double yf = yVal.toDouble();
//         final double uf = uVal.toDouble() - 128.0;
//         final double vf = vVal.toDouble() - 128.0;

//         // BT.601 conversion
//         int r = (yf + 1.402 * vf).round().clamp(0, 255);
//         int g = (yf - 0.344136 * uf - 0.714136 * vf).round().clamp(0, 255);
//         int b = (yf + 1.772 * uf).round().clamp(0, 255);

//         rgb[index++] = r;
//         rgb[index++] = g;
//         rgb[index++] = b;
//       }
//     }
//     return rgb;
//   }

//   @override
//   void dispose() {
//     stopDetection();
//     _cameraController?.dispose();
//     _interpreter?.close();
//     super.dispose();
//   }
// }
