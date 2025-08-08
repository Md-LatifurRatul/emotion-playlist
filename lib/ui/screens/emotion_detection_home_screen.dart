import 'package:emo_music_app/controller/audio_emotion_provider.dart';
import 'package:emo_music_app/controller/current_track_notifier.dart';
import 'package:emo_music_app/controller/image_picker_provider.dart';
import 'package:emo_music_app/controller/navigation_provider.dart';
import 'package:emo_music_app/controller/song_provider.dart';
import 'package:emo_music_app/controller/video_provider.dart';
import 'package:emo_music_app/model/song_model.dart';
import 'package:emo_music_app/model/video_item.dart';
import 'package:emo_music_app/services/auth_exception.dart';
import 'package:emo_music_app/services/firebase_auth_service.dart';
import 'package:emo_music_app/ui/screens/auth/login_screen.dart';
import 'package:emo_music_app/ui/screens/video-player/video_player_screen.dart';
import 'package:emo_music_app/ui/widgets/confirm_alert_dialogue.dart';
import 'package:emo_music_app/ui/widgets/mood_detection_button.dart';
import 'package:emo_music_app/ui/widgets/snack_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmotionDetectionHomeScreen extends StatefulWidget {
  const EmotionDetectionHomeScreen({super.key});

  @override
  State<EmotionDetectionHomeScreen> createState() =>
      _EmotionDetectionHomeScreenState();
}

class _EmotionDetectionHomeScreenState
    extends State<EmotionDetectionHomeScreen> {
  late final ImagePickerProvider _imagePickerProvider;
  late final AudioEmotionProvider _audioEmotionProvider;
  late final VideoProvider _videoProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _imagePickerProvider = Provider.of<ImagePickerProvider>(
        context,
        listen: false,
      );

      _audioEmotionProvider = Provider.of<AudioEmotionProvider>(
        context,
        listen: false,
      );

      _videoProvider = Provider.of<VideoProvider>(context, listen: false);

      final songProvider = Provider.of<SongProvider>(context, listen: false);
      if (songProvider.currentMood.isEmpty || songProvider.songs.isEmpty) {
        songProvider.setMoodAndFetch("happy");
        _videoProvider.setMoodAndFetch("happy");
      }

      _imagePickerProvider.addListener(_onLabelChanged);
      _audioEmotionProvider.addListener(_onAudioEmotionChanged);
    });
  }

  Future<void> _signOut(BuildContext context) async {
    final firebaseAuthService = FirebaseAuthService();

    try {
      await firebaseAuthService.signOut();

      SnackMessage.showSnakMessage(context, "Sign out success");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } on AuthException catch (e) {
      print("Sign out error: ${e.message}");
      SnackMessage.showSnakMessage(context, "Sign out failed");
    } catch (e) {
      print(e.toString());
    }
  }

  void _onLabelChanged() {
    final labels = _imagePickerProvider.labels;
    if (labels.isNotEmpty) {
      final mood = labels.first.label.toLowerCase();
      Provider.of<SongProvider>(context, listen: false).setMoodAndFetch(mood);
      _videoProvider.setMoodAndFetch(mood);
    }
  }

  void _onAudioEmotionChanged() {
    final mood = _audioEmotionProvider.detectedEmotion.toLowerCase();
    if (mood.isNotEmpty) {
      Provider.of<SongProvider>(context, listen: false).setMoodAndFetch(mood);
      _videoProvider.setMoodAndFetch(mood);
    }
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = context.watch<SongProvider>();
    final audioProvider = context.watch<AudioEmotionProvider>();
    final videoProvider = context.watch<VideoProvider>();
    final currentSongs = songProvider.songs;
    final currentVideos = videoProvider.videos;
    final imageProvider = context.watch<ImagePickerProvider>();
    final selectedImage = imageProvider.image;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Emotion-Based Music",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [_buildLogOut(context)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MoodDetectionButton(
                  icon: Icons.camera_alt,
                  label: 'Face Detection',
                  image: selectedImage,
                  onTap: () {
                    imageProvider.pickImage();
                  },
                  onLongPress: () {
                    imageProvider.captureCameraImage();
                  },
                ),
                MoodDetectionButton(
                  icon: Icons.mic,
                  label: 'Speech Detection',
                  image: null,
                  isLoading:
                      audioProvider.isRecording || audioProvider.isProcessing,
                  onTap: () async {
                    await audioProvider.startRecordingAndPredict(context);
                    audioProvider.fetchSongs(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Songs List Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Mood Songs List (${songProvider.currentMood.toUpperCase()})",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Songs List
          Expanded(
            flex: 2,
            child: songProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : currentSongs.isEmpty
                ? const Center(
                    child: Text(
                      "No songs found for this mood",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: currentSongs.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      final SongModel song = currentSongs[index];
                      return _buildPlaylistCard(song, currentSongs, index);
                    },
                  ),
          ),

          const SizedBox(height: 10),

          // Videos Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Mood Videos List (${songProvider.currentMood.toUpperCase()})",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Videos List
          Expanded(
            flex: 2,
            child: videoProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : currentVideos.isEmpty
                ? const Center(
                    child: Text(
                      "No videos found for this mood",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: currentVideos.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      final video = currentVideos[index];
                      return _buildVideoCard(video);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogOut(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(backgroundColor: Colors.tealAccent),
      onPressed: () {
        ConfirmAlertDialogue.showAlertDialogue(
          context,
          title: "Sign Out",
          content: "Are you sure you want to log-out?",
          confirmString: "Log-out",
          onPressed: () {
            _signOut(context);
          },
        );
      },
      icon: const Icon(Icons.logout),
    );
  }

  Widget _buildPlaylistCard(
    SongModel song,
    List<SongModel> currentSongs,
    int index,
  ) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            song.coverpage,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          song.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          song.artist,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.play_arrow, color: Colors.white),
        onTap: () {
          context.read<CurrentTrackNotifier>().setPlayList(currentSongs, index);
          context.read<NavigationProvider>().setSelectedIndex(1);
        },
      ),
    );
  }

  Widget _buildVideoCard(VideoItem video) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            video.thumbnailUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          video.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.play_arrow, color: Colors.white),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(videoId: video.videoId),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _imagePickerProvider.removeListener(_onLabelChanged);
    _audioEmotionProvider.removeListener(_onAudioEmotionChanged);
    super.dispose();
  }
}
