import 'package:emo_music_app/app.dart';
import 'package:emo_music_app/controller/audio_emotion_provider.dart';
import 'package:emo_music_app/controller/current_track_notifier.dart';
import 'package:emo_music_app/controller/image_picker_provider.dart';
import 'package:emo_music_app/controller/mood_history_provider.dart';
import 'package:emo_music_app/controller/navigation_provider.dart';
import 'package:emo_music_app/controller/song_provider.dart';
import 'package:emo_music_app/controller/video_provider.dart';
import 'package:emo_music_app/core/supabase_key.dart';
import 'package:emo_music_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: SupabaseKey.supabaseUrl,
    anonKey: SupabaseKey.supabaseKey,
  );
  final supabaseClient = Supabase.instance.client;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),
        ChangeNotifierProvider<SongProvider>(create: (_) => SongProvider()),
        ChangeNotifierProvider<CurrentTrackNotifier>(
          create: (_) => CurrentTrackNotifier(),
        ),
        ChangeNotifierProvider<ImagePickerProvider>(
          create: (_) => ImagePickerProvider(),
        ),
        ChangeNotifierProvider<AudioEmotionProvider>(
          create: (_) => AudioEmotionProvider(),
        ),

        // ChangeNotifierProvider<LiveCameraEmotionProvider>(
        //   create: (_) => LiveCameraEmotionProvider(),
        // ),
        ChangeNotifierProvider<VideoProvider>(create: (_) => VideoProvider()),
        ChangeNotifierProvider<MoodHistoryProvider>(
          create: (_) => MoodHistoryProvider(supabase: supabaseClient),
        ),
      ],

      child: const EmotionDetecterPlaylistApp(),
    ),
  );
}
