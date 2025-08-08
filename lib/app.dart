import 'package:emo_music_app/controller/song_provider.dart';
import 'package:emo_music_app/ui/screens/splash_screen.dart';
import 'package:emo_music_app/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmotionDetecterPlaylistApp extends StatelessWidget {
  const EmotionDetecterPlaylistApp({super.key});

  @override
  Widget build(BuildContext context) {
    final songProvider = context.watch<SongProvider>();
    final currentMood = songProvider.currentMood;

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Emotion Playlist App",
      home: SplashScreen(),
      theme: getThemeForMood(currentMood),

      // home: const MainBottomNavBarScreen(),
      // home: MusicPlayerScreen(),
    );
  }
}
