import 'package:emo_music_app/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class EmotionDetecterPlaylistApp extends StatelessWidget {
  const EmotionDetecterPlaylistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Emotion Playlist App",
      home: SplashScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: _inputStyleDecorationTheme(),
      ),

      // home: const MainBottomNavBarScreen(),
      // home: MusicPlayerScreen(),
    );
  }

  InputDecorationTheme _inputStyleDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(),
    );
  }
}
