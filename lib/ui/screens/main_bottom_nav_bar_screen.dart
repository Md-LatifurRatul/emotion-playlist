import 'package:emo_music_app/controller/navigation_provider.dart';
import 'package:emo_music_app/ui/screens/chat-screen/chat_screen.dart';
import 'package:emo_music_app/ui/screens/emotion_detection_home_screen.dart';
import 'package:emo_music_app/ui/screens/music_player/music_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainBottomNavBarScreen extends StatefulWidget {
  const MainBottomNavBarScreen({super.key});

  @override
  State<MainBottomNavBarScreen> createState() => _MainBottomNavBarScreenState();
}

class _MainBottomNavBarScreenState extends State<MainBottomNavBarScreen> {
  final List<Widget> _pages = [
    const EmotionDetectionHomeScreen(),
    const MusicPlayerScreen(),
    const ChatScreen(),
  ];
  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Music"),
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    return Scaffold(
      body: _pages[nav.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,

        currentIndex: nav.selectedIndex,
        onTap: (index) =>
            context.read<NavigationProvider>().setSelectedIndex(index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        showSelectedLabels: true,

        items: _navItems,
      ),
    );
  }
}
