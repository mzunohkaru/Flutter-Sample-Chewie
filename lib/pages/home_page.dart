import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:chewie_sample/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  TargetPlatform? _platform;
  late VideoPlayerController _videoPlayerController1;
  late VideoPlayerController _videoPlayerController2;
  ChewieController? _chewieController;
  int? bufferDelay;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  List<String> srcs = [
    "https://assets.mixkit.co/videos/preview/mixkit-spinning-around-the-earth-29351-large.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4"
  ];

  Future<void> initializePlayer() async {
    _videoPlayerController1 =
        VideoPlayerController.networkUrl(Uri.parse(srcs[currPlayIndex]));
    _videoPlayerController2 =
        VideoPlayerController.networkUrl(Uri.parse(srcs[currPlayIndex]));
    await Future.wait([
      _videoPlayerController1.initialize(),
      _videoPlayerController2.initialize()
    ]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      progressIndicatorDelay:
          bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,

      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: toggleVideo,
            iconData: Icons.live_tv_sharp,
            title: 'Toggle Video Src',
          ),
        ];
      },
      subtitle: _buildSubtitleController_1(),
      subtitleBuilder: (context, dynamic subtitle) => Container(
        padding: const EdgeInsets.all(10.0),
        child: subtitle is InlineSpan
            ? RichText(
                text: subtitle,
              )
            : Text(
                subtitle.toString(),
                style: const TextStyle(color: Colors.black),
              ),
      ),

      hideControlsTimer: const Duration(seconds: 1),

      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
  }

  int currPlayIndex = 0;

  Future toggleVideo() async {
    await _videoPlayerController1.pause();
    currPlayIndex += 1;
    if (currPlayIndex >= srcs.length) {
      currPlayIndex = 0;
    }
    await initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
                child: _chewieController != null &&
                        _chewieController!
                            .videoPlayerController.value.isInitialized
                    ? Chewie(
                        controller: _chewieController!,
                      )
                    : const CircularProgressIndicator()),
          ),
          TextButton(
            onPressed: () {
              _chewieController?.enterFullScreen();
            },
            child: const Text('Full Screen'),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _videoPlayerController1.pause();
                      _videoPlayerController1.seekTo(Duration.zero);
                      _createChewieController();
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text("Landscape Video"),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _videoPlayerController2.pause();
                      _videoPlayerController2.seekTo(Duration.zero);
                      _chewieController = _chewieController!.copyWith(
                        videoPlayerController: _videoPlayerController2,
                        autoPlay: true,
                        looping: true,
                        subtitle: _buildSubtitleController_2(),
                        subtitleBuilder: (context, subtitle) => Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            subtitle,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    });
                  },
                  child: const Text("Portrait Video"),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      // ビデオコントロールはMaterial Designのガイドラインに従います
                      _platform = TargetPlatform.android;
                    });
                  },
                  child: const Text("Android controls"),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      // ビデオコントロールはiOSのガイドラインに従います
                      _platform = TargetPlatform.iOS;
                    });
                  },
                  child: const Text("iOS controls"),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      // デスクトップ向けのビデオコントロールは、一般的にマウスとキーボードの操作に最適化されています
                      _platform = TargetPlatform.windows;
                    });
                  },
                  child: const Text("Desktop controls"),
                ),
              ),
            ],
          ),
          if (Platform.isAndroid)
            ListTile(
              title: const Text("Delay"),
              subtitle: DelaySlider(
                delay:
                    _chewieController?.progressIndicatorDelay?.inMilliseconds,
                onSave: (delay) async {
                  if (delay != null) {
                    bufferDelay = delay == 0 ? null : delay;
                    await initializePlayer();
                  }
                },
              ),
            )
        ],
      ),
    );
  }

  Subtitles _buildSubtitleController_1() {
    return Subtitles([
      Subtitle(
        index: 0,
        start: Duration.zero,
        end: const Duration(seconds: 10),
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'こちら Landscape',
              style: TextStyle(color: Colors.red, fontSize: 18),
            )
          ],
        ),
      ),
      Subtitle(
        index: 0,
        start: const Duration(seconds: 10),
        end: const Duration(seconds: 15),
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Hello',
              style: TextStyle(color: Colors.red, fontSize: 22),
            ),
            TextSpan(
              text: ' from ',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            TextSpan(
              text: 'Subtitles',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            )
          ],
        ),
      ),
    ]);
  }

  Subtitles _buildSubtitleController_2() {
    return Subtitles([
      Subtitle(
        index: 0,
        start: Duration.zero,
        end: const Duration(seconds: 10),
        text: 'こちら Portrait',
      ),
      Subtitle(
        index: 0,
        start: const Duration(seconds: 10),
        end: const Duration(seconds: 20),
        text: 'Hello form Subtitles',
      ),
    ]);
  }
}
