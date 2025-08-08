import 'package:emo_music_app/controller/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../video-player/video_player_screen.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final videoProvider = Provider.of<VideoProvider>(context, listen: false);

      // If empty, fetch for default mood
      if (videoProvider.videos.isEmpty) {
        videoProvider.setMoodAndFetch(videoProvider.currentMood);
      }

      // Listen for mood changes in real-time
      videoProvider.addListener(() {
        if (mounted) {
          setState(() {
            // This triggers rebuild so updated videos show immediately
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = context.watch<VideoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("YouTube Videos - ${videoProvider.currentMood}"),
      ),
      body: videoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : videoProvider.videos.isEmpty
          ? const Center(child: Text("No videos found for this mood"))
          : RefreshIndicator(
              onRefresh: () async {
                await videoProvider.setMoodAndFetch(videoProvider.currentMood);
              },
              child: ListView.builder(
                itemCount: videoProvider.videos.length,
                itemBuilder: (context, index) {
                  final video = videoProvider.videos[index];
                  return ListTile(
                    leading: Image.network(video.thumbnailUrl),
                    title: Text(video.title),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VideoPlayerScreen(videoId: video.videoId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
