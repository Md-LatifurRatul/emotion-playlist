import 'package:emo_music_app/model/song_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupbaseService {
  final _client = Supabase.instance.client;

  Future<List<SongModel>> fetchSongsByMood(String mood) async {
    final response = await _client
        .from('songs')
        .select()
        .eq('mood', mood)
        .order('created_at', ascending: false);
    // print(response);

    return (response as List).map((item) => SongModel.fromMap(item)).toList();
  }
}
