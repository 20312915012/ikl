import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:video_player/video_player.dart';

class BVideoPlayer extends BStatefulWidget {
  BVideoPlayer({
    Key key,
    String id,
    double width,
    double height,
    this.filePath,
    this.onPlayPauseTap,
    this.index,
  }) : super(
          key: key,
          id: id,
          width: width,
          height: height,
        );

  String filePath;
  Function onPlayPauseTap;
  int index;

  @override
  BState<BStatefulWidget> createState() => _BVideoPlayerState();
}

class _BVideoPlayerState extends BState<BVideoPlayer> {
  VideoPlayerController _controller;

  bool isPlay = false;
  double lengthOfAudioInSecs = 0.0;
  double seekValue = 0.0;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  void initVideo() async {
    _controller = VideoPlayerController.network(
      widget.filePath,
    )..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.setLooping(true);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller == null
        ? const SizedBox()
        : Container(
            child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    VideoPlayer(_controller),
                    _ControlsOverlay(controller: _controller),
                    VideoProgressIndicator(_controller, allowScrubbing: true),
                  ],
                )),
          );
  }

  String formatDuration(Duration o) {
    var mil_s = (o.inMilliseconds % 1000).toString().padLeft(3, '0');
    var sec_s = (o.inSeconds % 60).toString().padLeft(2, '0');
    //return o.inMinutes.toString() + ' m ' + sec_s + ' s ';/* + mil_s + ' ms'*/;
    return o.inMinutes.toString() + ':' + sec_s;
    /* + mil_s + ' ms'*/;
  }

  @override
  void updateValues() {
    // TODO: implement updateValues
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, @required this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
