import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class TestPage extends HookWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final videoPlayerController = useMemoized(
      () => VideoPlayerController.network(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      ),
      [],
    );

    final chewieController = useState<ChewieController?>(null);

    useEffect(() {
      videoPlayerController.initialize().then((_) {
        chewieController.value = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: false,
          looping: false,
          aspectRatio: 16 / 9,
          allowFullScreen: true,
          playbackSpeeds: [0.5, 1.0, 1.5, 1.88, 2.0],
          placeholder: Container(
            color: Colors.transparent,
          ),
          allowMuting: true,
          allowPlaybackSpeedChanging: true,
          draggableProgressBar: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.red,
            handleColor: Colors.red,
            backgroundColor: Colors.transparent,
            bufferedColor: Colors.grey,
          ),
          errorBuilder: (context, errorMessage) {
            debugPrint(errorMessage);
            return Center(
              child: Text(errorMessage),
            );
          },
        );
      });

      return () {
        videoPlayerController.dispose();
        chewieController.value?.dispose();
      };
    }, [videoPlayerController]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chewie テスト'),
      ),
      body: Center(
        child: chewieController.value != null
            ? GestureDetector(
                onDoubleTapDown: (details) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isRightSide =
                      details.globalPosition.dx > screenWidth / 2;

                  if (isRightSide) {
                    // 右側のダブルタップ - 10秒早送り
                    final newPosition = videoPlayerController.value.position +
                        Duration(seconds: 10);
                    videoPlayerController.seekTo(newPosition);
                  } else {
                    // 左側のダブルタップ - 10秒巻き戻し
                    final newPosition = videoPlayerController.value.position -
                        Duration(seconds: 10);
                    videoPlayerController.seekTo(newPosition);
                  }
                },
                child: Chewie(controller: chewieController.value!))
            : const CircularProgressIndicator(),
      ),
    );
  }
}
