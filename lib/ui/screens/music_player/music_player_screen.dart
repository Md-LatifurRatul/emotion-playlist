import 'package:emo_music_app/controller/current_track_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key, this.track});
  final Map<String, String>? track;

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _imageAnimation;
  // final ItemScrollController _scrollController = ItemScrollController();
  // List<String> _lyrics = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _imageAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    final notifier = context.read<CurrentTrackNotifier>();
    notifier.addListener(_onTrackChanged);

    if (notifier.currentTrack != null) {
      _onTrackChanged();
    }
  }

  Future<void> _onTrackChanged() async {
    final notifier = context.read<CurrentTrackNotifier>();
    final track = notifier.currentTrack;
    if (track == null) return;
    // _loadLyrics(track.title, track.artist);

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (_scrollController.isAttached) {
    //     _scrollController.jumpTo(index: 0);
    //   }
    // });
  }

  // Future<void> _loadLyrics(String title, String artist) async {
  //   final artistEnc = Uri.encodeComponent(artist);
  //   final titleEnc = Uri.encodeComponent(title);
  //   final res = await get(
  //     Uri.parse("https://api.lyrics.ovh/v1/$artistEnc/$titleEnc"),
  //   );

  //   if (res.statusCode == 200) {
  //     final text = jsonDecode(res.body)['lyrics'] as String;
  //     setState(() {
  //       _lyrics =
  //           text.split("\n").where((line) => line.trim().isNotEmpty).toList();
  //     });
  //   } else {
  //     setState(() => _lyrics = ['Lyrics not found.']);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final trackNotifier = context.watch<CurrentTrackNotifier>();
    final currentTrack = trackNotifier.currentTrack;
    final player = trackNotifier.player;

    if (currentTrack == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No Track Selected",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Now Playing: ${currentTrack.title}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ScaleTransition(
              scale: _imageAnimation,

              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(currentTrack.coverpage),
                    fit: BoxFit.cover,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.white12,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            Text(
              currentTrack.title,
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              currentTrack.artist,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),

            StreamBuilder<Duration>(
              stream: trackNotifier.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;

                final total = trackNotifier.duration ?? Duration.zero;
                final max = total.inSeconds > 0
                    ? total.inSeconds.toDouble()
                    : 1.0;
                final val = position.inSeconds
                    .clamp(0, total.inSeconds)
                    .toDouble();

                return Slider(
                  min: 0.0,
                  value: val,
                  max: max,

                  onChanged: (value) {
                    player.seek(Duration(seconds: value.toInt()));
                  },
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.white24,
                );
              },
            ),

            _buildMusicControllerButton(trackNotifier),
            SizedBox(height: 10),

            _buildMusicLyrics(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.chat),
        onPressed: () {},
      ),
    );
  }

  Widget _buildMusicControllerButton(CurrentTrackNotifier trackNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.skip_previous, color: Colors.white),
          iconSize: 36,
          onPressed: trackNotifier.playPrevious,
        ),
        const SizedBox(width: 10),

        ElevatedButton(
          onPressed: () {
            trackNotifier.playPause();
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.all(18),
          ),

          child: Icon(
            trackNotifier.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: Icon(Icons.skip_next, color: Colors.white),
          color: Colors.white,
          iconSize: 36,
          onPressed: trackNotifier.playNext,
        ),
        const SizedBox(width: 10),

        IconButton(
          onPressed: () {
            trackNotifier.toggleRepeatMode();
          },
          icon: Icon(_getRepeatIcon(trackNotifier.repeatMode)),

          color: trackNotifier.repeatMode == RepeatMode.off
              ? Colors.grey
              : Colors.green,
        ),
      ],
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.repeatOne:
        return Icons.repeat_one;
      case RepeatMode.repeatAll:
        return Icons.repeat;
      case RepeatMode.off:
        return Icons.repeat;
    }
  }

  Widget _buildMusicLyrics() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListView(
          children: [
            Text(
              'Lyrics Line 1',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              "Lyrics Line 2",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              "Lyrics Line 3",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),

        // ScrollablePositionedList.builder(
        //   itemScrollController: _scrollController,

        //   itemCount: _lyrics.length,
        //   itemBuilder: (context, i) {
        //     final currentLine = (player.position.inSeconds ~/ 5).clamp(
        //       0,
        //       _lyrics.length,
        //     );

        //     final isActice = i == currentLine;

        //     return Padding(
        //       padding: const EdgeInsets.symmetric(vertical: 4),
        //       child: Text(
        //         _lyrics[i],
        //         style: TextStyle(
        //           color: isActice ? Colors.blueAccent : Colors.white,
        //           fontSize: 16,
        //         ),
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}


  // void _playPause() {
  //   if (_audioPlayer.playing) {
  //     _audioPlayer.pause();
  //     _animationController.stop();
  //     setState(() {
  //       isPlaying = false;
  //     });
  //   } else {
  //     _audioPlayer.play();
  //     _animationController.repeat();
  //     setState(() {
  //       isPlaying = true;
  //     });
  //   }
  // }

  // void _playNext() {
  //   if (_currentIndex < _songs.length - 1) {
  //     _currentIndex++;
  //     _loadAndPlay();
  //   } else {
  //     _currentIndex = 0;
  //     _loadAndPlay();
  //   }
  // }

  // void _playPrevious() {
  //   if (_currentIndex > 0) {
  //     _currentIndex--;
  //     _loadAndPlay();
  //   }
  // }

  // Future<void> _loadAndPlay() async {
  //   await _audioPlayer.setUrl(_songs[_currentIndex]['url']!);
  //   _audioPlayer.play();
  //   setState(() {
  //     isPlaying = true;
  //   });
  // }



  // final List<Map<String, String>> _songs = [
  //   {
  //     "title": "Chill Vibes",
  //     "artist": "Warfaze",

  //     "url":
  //         "https://www.music.com.bd/download/Music/W/Warfaze/Shotto/04.%20Warfaze%20-%20Purnota%20(music.com.bd).mp3",

  //     "image":
  //         "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRI6oe0i5K8vjoaCdABY5I9uJffX2M1NIkSQA&s",
  //   },

  //   {
  //     "title": "Mood Booster",
  //     "artist": "Artcell",

  //     "url":
  //         "https://music.com.bd/download/Music/A/Artcell/Oniket%20Prantor/Artcell%20-%20Oniket%20Prantor%20(music.com.bd).mp3",

  //     "image":
  //         "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRI6oe0i5K8vjoaCdABY5I9uJffX2M1NIkSQA&s",
  //   },

  //   {
  //     "title": "Chill Vibes",
  //     "artist": "Warfaze",

  //     "url":
  //         "https://www.music.com.bd/download/Music/W/Warfaze/Shotto/04.%20Warfaze%20-%20Purnota%20(music.com.bd).mp3",

  //     "image":
  //         "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRI6oe0i5K8vjoaCdABY5I9uJffX2M1NIkSQA&s",
  //   },
  // ];