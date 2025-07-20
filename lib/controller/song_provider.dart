import 'dart:developer';

import 'package:emo_music_app/model/song_model.dart';
import 'package:emo_music_app/services/supbase_service.dart';
import 'package:flutter/material.dart';

class SongProvider with ChangeNotifier {
  final SupbaseService _supbaseService = SupbaseService();

  List<SongModel> _songs = [];

  bool _isLoading = false;
  String _currentMood = "happy";

  List<SongModel> get songs => _songs;
  bool get isLoading => _isLoading;

  String get currentMood => _currentMood;

  Future<void> setMoodAndFetch(String mood) async {
    if (mood == _currentMood && _songs.isNotEmpty) return;

    _currentMood = mood;
    _isLoading = true;
    notifyListeners();

    try {
      _songs = await _supbaseService.fetchSongsByMood(mood);
    } catch (e) {
      log('Error in fetch songs by mood: $e');
      _songs = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSongs() => setMoodAndFetch(_currentMood);
}
