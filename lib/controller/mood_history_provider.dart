import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MoodHistoryProvider extends ChangeNotifier {
  final SupabaseClient supabase;
  String? _userId;

  final Map<String, int> _moodCounts = {};
  Map<String, int> get moodCounts => Map.unmodifiable(_moodCounts);

  StreamSubscription<dynamic>? _subscription;

  MoodHistoryProvider({required this.supabase, String? userId}) {
    _userId = userId;
    if (_userId != null) {
      _initialize();
    }
  }

  /// Call this to set userId later after initialization
  void setUserId(String userId) {
    if (_userId != userId) {
      _userId = userId;
      _initialize();
    }
  }

  void _initialize() {
    fetchMoodHistoryFromSupabase();
    _startRealtimeSubscription();
  }

  Future<void> fetchMoodHistoryFromSupabase() async {
    final currentUserId = _userId;
    if (currentUserId == null) return;

    try {
      final List<dynamic> response = await supabase
          .from('mood_history')
          .select('mood')
          .eq('user_id', currentUserId);

      _moodCounts.clear();

      for (final item in response) {
        final mood = (item as Map<String, dynamic>)['mood'] as String;
        _moodCounts[mood] = (_moodCounts[mood] ?? 0) + 1;
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching moods: $e');
    }
  }

  Future<void> addMood(String mood) async {
    final currentUserId = _userId;
    if (currentUserId == null) {
      print('User ID is null, cannot add mood.');
      return;
    }
    try {
      await supabase.from('mood_history').insert({
        'user_id': currentUserId,
        'mood': mood,
      });
    } catch (e) {
      print('Error adding mood: $e');
    }
  }

  void _startRealtimeSubscription() {
    final currentUserId = _userId;
    if (currentUserId == null) return;

    _subscription?.cancel();

    _subscription = supabase
        .from('mood_history')
        .stream(primaryKey: ['id'])
        .eq('user_id', currentUserId)
        .listen((_) {
          fetchMoodHistoryFromSupabase();
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
