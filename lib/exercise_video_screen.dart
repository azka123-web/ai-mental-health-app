import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class ExerciseVideoScreen extends StatefulWidget {
  final String title;
  final String image;

  const ExerciseVideoScreen({
    super.key,
    required this.title,
    required this.image,
  });

  @override
  State<ExerciseVideoScreen> createState() =>
      _ExerciseVideoScreenState();
}

class _ExerciseVideoScreenState extends State<ExerciseVideoScreen> {
  late VideoPlayerController _controller;

  bool showControls = true;
  bool isMuted = false;
  bool startVideo = false;

  Timer? hideTimer;

  String videoPath = "";
  String duration = "10 minutes";
  String level = "Beginner";
  String tips = "";
  String frequency = "";

  @override
  void initState() {
    super.initState();

    if (widget.title.toLowerCase().contains("stress")) {
      videoPath = "assets/stressvideo.mp4";
      tips = "Focus on deep breathing and slow movements.";
      frequency = "Daily practice recommended.";
      duration = "46 seconds";
      level = "Beginner";
    } else if (widget.title.toLowerCase().contains("depression")) {
      videoPath = "assets/depressionvideo.mp4";
      tips = "Stay calm and focus on positive thoughts.";
      frequency = "5 times a week.";
      duration = "43 seconds";
      level = "Easy";
    }

    _controller = VideoPlayerController.asset(videoPath)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  /// ✅ ONLY BUTTON CALLS THIS
  void beginVideo() {
    setState(() {
      startVideo = true;
    });

    /// 🔥 FULL SCREEN VERTICAL MODE ONLY
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controller.play();
    _controller.setVolume(1);

    startHideTimer();
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    _controller.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  void startHideTimer() {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 4), () {
      if (_controller.value.isPlaying) {
        setState(() => showControls = false);
      }
    });
  }

  void toggleControls() {
    setState(() => showControls = !showControls);
    if (showControls) startHideTimer();
  }

  void togglePlay() {
    setState(() {
      _controller.value.isPlaying
          ? _controller.pause()
          : _controller.play();
    });

    startHideTimer();
  }

  void seekForward() {
    _controller.seekTo(
      _controller.value.position + const Duration(seconds: 10),
    );
  }

  void seekBackward() {
    _controller.seekTo(
      _controller.value.position - const Duration(seconds: 10),
    );
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
      _controller.setVolume(isMuted ? 0 : 1);
    });
  }

  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    if (!startVideo) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),

        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(28),
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: Image.asset(
                          widget.image,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 18),

                            Row(
                              children: [
                                infoCard(Icons.timer, duration),
                                const SizedBox(width: 10),
                                infoCard(Icons.star, level),
                              ],
                            ),

                            const SizedBox(height: 22),

                            const Text(
                              "Instructions",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 12),

                            instructionTile("Find a quiet place."),
                            instructionTile(tips),
                            instructionTile(frequency),
                            instructionTile("Use headphones for better focus."),

                            const SizedBox(height: 28),

                            /// ✅ ONLY BUTTON STARTS VIDEO
                            GestureDetector(
                              onTap: beginVideo,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0EA5E9),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_circle_fill,
                                        color: Colors.white, size: 28),
                                    SizedBox(width: 10),
                                    Text(
                                      "Start Exercise",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    /// 🎥 VIDEO SCREEN
    /// 🎥 VIDEO SCREEN (FULL CONTROLS RESTORED)
    return Scaffold(
      backgroundColor: Colors.black,

      body: GestureDetector(
        onTap: toggleControls,

        child: Stack(
          children: [

            /// 🎥 VIDEO
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : const SizedBox(),
            ),

            /// 🌑 DARK OVERLAY
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showControls ? 1 : 0,
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),

            /// 🎮 CONTROLS
            if (showControls)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// 🔝 TOP BAR (BACK + TITLE)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [

                          /// 🔙 BACK BUTTON
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),

                          /// 🎬 TITLE
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          /// 🔇 MUTE
                          IconButton(
                            icon: Icon(
                              isMuted
                                  ? Icons.volume_off
                                  : Icons.volume_up,
                              color: Colors.white,
                            ),
                            onPressed: toggleMute,
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// ▶ CENTER PLAY / PAUSE
                  GestureDetector(
                    onTap: togglePlay,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 55,
                      ),
                    ),
                  ),

                  /// 📊 BOTTOM CONTROLS
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),

                    child: Column(
                      children: [

                        /// ⏱ TIME
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDuration(
                                  _controller.value.position),
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              formatDuration(
                                  _controller.value.duration),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// 📊 PROGRESS BAR
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.red,
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.white24,
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// ⏪ ⏯ ⏩ CONTROLS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            IconButton(
                              onPressed: seekBackward,
                              icon: const Icon(
                                Icons.replay_10,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),

                            const SizedBox(width: 15),

                            IconButton(
                              onPressed: togglePlay,
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),

                            const SizedBox(width: 15),

                            IconButton(
                              onPressed: seekForward,
                              icon: const Icon(
                                Icons.forward_10,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  Widget infoCard(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(text,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget instructionTile(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              color: Color(0xFF38BDF8), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}