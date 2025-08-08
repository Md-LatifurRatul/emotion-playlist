import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import 'song_provider.dart';

class AudioEmotionProvider extends ChangeNotifier {
  final _recorder = AudioRecorder();
  bool isRecording = false;
  bool isProcessing = false;
  String detectedEmotion = "";

  Timer? _stopTimer;

  /// Starts recording and handles the prediction + song fetch flow
  Future<void> startRecordingAndPredict(BuildContext context) async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        print("Microphone permission not granted.");
        return;
      }

      isRecording = true;
      isProcessing = false;
      detectedEmotion = "";
      notifyListeners();

      final tempDir = await getTemporaryDirectory();
      final path = p.join(tempDir.path, 'audio.wav');

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 16000,
        ),
        path: path,
      );

      await Future.delayed(const Duration(seconds: 3));

      final filePath = await _recorder.stop();

      isRecording = false;
      isProcessing = true;
      notifyListeners();

      if (filePath != null) {
        await _sendToAPI(File(filePath), context);
      }
    } catch (e) {
      print("Recording error: $e");
    } finally {
      isRecording = false;
      isProcessing = false;
      notifyListeners();
    }
  }

  /// Sends recorded audio to Flask API for prediction
  Future<void> _sendToAPI(File audioFile, BuildContext context) async {
    try {
      final uri = Uri.parse("http://192.168.0.100:5000/predict");

      final request = http.MultipartRequest("POST", uri);
      request.files.add(
        await http.MultipartFile.fromPath("audio", audioFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = json.decode(responseBody);
        detectedEmotion = decoded["emotion"] ?? "";
        print("Detected emotion: $detectedEmotion");

        notifyListeners();

        // Automatically fetch songs based on detected emotion
        fetchSongs(context);
      } else {
        print("API Error: ${response.statusCode}");
        print("Response body: $responseBody");
      }
    } catch (e) {
      print("Error sending audio to API: $e");
    }
  }

  /// Calls SongProvider to fetch songs based on emotion
  void fetchSongs(BuildContext context) {
    if (detectedEmotion.isNotEmpty) {
      final songProvider = Provider.of<SongProvider>(context, listen: false);
      songProvider.setMoodAndFetch(detectedEmotion);
    }
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    super.dispose();
  }
}
