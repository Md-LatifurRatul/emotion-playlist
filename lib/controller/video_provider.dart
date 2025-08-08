import 'dart:convert';
import 'dart:developer';

import 'package:emo_music_app/core/secret_key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/video_item.dart';

class VideoProvider extends ChangeNotifier {
  final String _apiKey = SecretKey.videoApiKey;
  final String regionCode = 'BD'; // Bangladesh
  final String videoCategoryId = '10'; // Music category

  List<VideoItem> _videos = [];
  bool _isLoading = false;
  String _currentMood = "happy";

  List<VideoItem> get videos => _videos;
  bool get isLoading => _isLoading;
  String get currentMood => _currentMood;

  /// Set mood and fetch videos for that mood
  Future<void> setMoodAndFetch(String mood, {int maxResults = 10}) async {
    // Avoid refetch if mood is same and we already have results
    if (mood == _currentMood && _videos.isNotEmpty) return;

    _currentMood = mood;
    _isLoading = true;
    notifyListeners();

    final query = "$mood Bangladesh songs";

    final Uri url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search'
      '?part=snippet'
      '&maxResults=$maxResults'
      '&q=$query'
      '&type=video'
      '&videoCategoryId=$videoCategoryId'
      '&regionCode=$regionCode'
      '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        _videos = items.map((item) {
          final snippet = item['snippet'];
          return VideoItem(
            videoId: item['id']['videoId'],
            title: snippet['title'],
            thumbnailUrl: snippet['thumbnails']['medium']['url'],
          );
        }).toList();
        log("Fetched ${_videos.length} videos for mood: $_currentMood");
      } else {
        _videos = [];
        debugPrint("YouTube API error: ${response.statusCode}");
      }
    } catch (e) {
      _videos = [];
      debugPrint("Video fetch error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
