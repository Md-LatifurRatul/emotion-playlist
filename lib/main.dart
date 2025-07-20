import 'package:emo_music_app/app.dart';
import 'package:emo_music_app/controller/current_track_notifier.dart';
import 'package:emo_music_app/controller/image_picker_provider.dart';
import 'package:emo_music_app/controller/navigation_provider.dart';
import 'package:emo_music_app/controller/song_provider.dart';
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
      ],

      child: const EmotionDetecterPlaylistApp(),
    ),
  );
}
