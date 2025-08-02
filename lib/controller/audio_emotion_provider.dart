import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound_processing/flutter_sound_processing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class AudioEmotionProvider extends ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  // For TFLite model
  Interpreter? _interpreter;
  List<String> _labels = [];

  bool _isRecording = false;
  bool _isProcessing = false;
  String _detectedEmotion = '';

  // Getters for the UI to read the state
  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  String get detectedEmotion => _detectedEmotion;

  AudioEmotionProvider() {
    // Load the model and labels when the provider is created
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/ml/emotion_audio.tflite',
      );
      final labelsData = await rootBundle.loadString(
        'assets/ml/labels_audio.txt',
      );
      _labels = labelsData
          .split('\n')
          .where((label) => label.isNotEmpty)
          .toList();
      print("Audio model and labels loaded successfully.");
    } catch (e) {
      print("Error loading audio model or labels: $e");
    }
  }

  /// Starting recording audio for 3 seconds and then triggers prediction.
  Future<void> startRecordingAndPrediction() async {
    if (_isRecording || _isProcessing) return; // Prevent multiple triggering

    if (await _audioRecorder.hasPermission()) {
      _isRecording = true;
      notifyListeners();

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/temp_audio.m4a';

      // Start recording
      await _audioRecorder.start(const RecordConfig(), path: filePath);

      // Wait for 3 seconds to match the training data duration
      await Future.delayed(const Duration(seconds: 3));

      // Stop recording and get the file path
      final audioPath = await _audioRecorder.stop();
      _isRecording = false;

      if (audioPath != null) {
        // Once recording is done, process the audio file
        await _processAndPredict(audioPath);
      } else {
        notifyListeners();
      }
    } else {
      print("Microphone permission denied.");
    }
  }

  /// Processes the recorded audio file, runs inference, and updates the state.
  Future<void> _processAndPredict(String audioPath) async {
    if (_interpreter == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final audioBytes = await File(audioPath).readAsBytes();
      final Int16List int16List = audioBytes.buffer.asInt16List();
      final List<double> doubleList = int16List
          .map((e) => e.toDouble())
          .toList();

      //Extract MFCC features using the same parameters as in training

      const int nMFCC = 40;

      final Float64List? mfccFeatures = await FlutterSoundProcessing()
          .getFeatureMatrix(
            signals: doubleList,
            sampleRate: 16000,
            nMels: 128,
            mfcc: nMFCC,
            fftSize: 512,
            hopLength: 256,
          );
      if (mfccFeatures == null || mfccFeatures.isEmpty) {
        throw Exception("Failed to extract MFCC features.");
      }

      // Average the features across time to get a single feature vector
      // This replicates the np.mean(..., axis=0) logic from Python
      final int numFrames = mfccFeatures.length ~/ nMFCC;
      if (numFrames == 0) {
        throw Exception("MFCC features resulted in zero frames.");
      }

      List<double> averagedMfcc = List.filled(nMFCC, 0.0);
      for (int i = 0; i < mfccFeatures.length; i++) {
        averagedMfcc[i % nMFCC] += mfccFeatures[i];
      }

      // Finalize the average by dividing by the number of frames
      for (int j = 0; j < nMFCC; j++) {
        averagedMfcc[j] /= numFrames;
      }
      //  Prepare the input for the TFLite model (shape: [1, 40, 1])
      var input = [
        averagedMfcc.map((e) => [e]).toList(),
      ];
      var output = List.filled(
        1 * _labels.length,
        0,
      ).reshape([1, _labels.length]);

      // Run inference
      _interpreter!.run(input, output);

      // Find the emotion with the highest probability
      List<double> outputList = output[0];
      int maxIndex = 0;
      double maxScore = 0.0;
      for (int i = 0; i < outputList.length; i++) {
        if (outputList[i] > maxScore) {
          maxScore = outputList[i];
          maxIndex = i;
        }
      }

      _detectedEmotion = _labels[maxIndex];
      print("Detected Audio Emotion: $_detectedEmotion");
    } catch (e) {
      print("Error during audio processing or prediction: $e");
    } finally {
      _isProcessing = false;
      notifyListeners(); // Notify UI to stop loading and update with emotion
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _interpreter?.close();
    super.dispose();
  }
}
