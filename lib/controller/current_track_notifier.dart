import 'dart:developer';

import 'package:audio_session/audio_session.dart';
import 'package:emo_music_app/model/song_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum RepeatMode { off, repeatOne, repeatAll }

class CurrentTrackNotifier extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  RepeatMode _repeatMode = RepeatMode.off;

  List<SongModel> _playlist = [];
  int _currentIndex = -1;

  AudioPlayer get player => _player;
  RepeatMode get repeatMode => _repeatMode;
  // Expose positionStream and duration for UI slider
  Stream<Duration> get positionStream => _player.positionStream;
  Duration? get duration => _player.duration;

  CurrentTrackNotifier() {
    _initAudioSession();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  // Set a new playlist and start playback at [startIndex].

  Future<void> setPlayList(List<SongModel> songs, int startIndex) async {
    if (songs.isEmpty || startIndex < 0 || startIndex >= songs.length) return;

    _playlist = songs;
    _currentIndex = startIndex;
    await _loadAndPlayCurrent();
    notifyListeners();
  }

  SongModel? get currentTrack =>
      (_currentIndex >= 0 && _currentIndex < _playlist.length)
      ? _playlist[_currentIndex]
      : null;

  bool get isPlaying => _player.playing;

  Future<void> playPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await _loadAndPlayCurrent();
    notifyListeners();
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;

    await _loadAndPlayCurrent();
    notifyListeners();
  }

  Future<void> _loadAndPlayCurrent() async {
    final track = currentTrack;
    if (track == null) return;
    try {
      await _player.stop();
      await _player.setUrl(track.audioUrl);
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      log("Error loading audio: $e");
    }
  }

  void toggleRepeatMode() {
    if (_repeatMode == RepeatMode.off) {
      _repeatMode = RepeatMode.repeatOne;
      _player.setLoopMode(LoopMode.one);
    } else if (_repeatMode == RepeatMode.repeatOne) {
      _repeatMode = RepeatMode.repeatAll;
      _player.setLoopMode(LoopMode.all);
    } else {
      _repeatMode = RepeatMode.off;
      _player.setLoopMode(LoopMode.off);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
