import 'package:b_dep/src/utils/models.dart';
import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:rxdart/rxdart.dart';

class BAudioPlayer extends BStatefulWidget {
  BAudioPlayer({
    Key key,
    String id,
    double width,
    double height,
    this.filePath,
    this.onPlayPauseTap,
  }) : super(
          key: key,
          id: id,
          width: width,
          height: height,
        );

  String filePath;
  Function onPlayPauseTap;

  @override
  BState<BStatefulWidget> createState() => _BAudioPlayerState();
}

class _BAudioPlayerState extends BState<BAudioPlayer> {
  BAudioClass audioInstance;

  bool isPlay = false;
  double lengthOfAudioInSecs = 0.0;
  double seekValue = 0.0;

  @override
  void initState() {
    super.initState();
    initAudio();
  }

  void initAudio() async {
    setState(() async {
      audioInstance = BAudioClass(context);
      await audioInstance.setFilePath([widget.filePath]);
      lengthOfAudioInSecs = audioInstance.getDuration().toDouble();
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
    return audioInstance == null
        ? const SizedBox()
        : Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 5,
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 20,
                  iconSize: 32,
                  icon: Icon(
                    isPlay ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 32,
                  ),
                  color: Colors.black,
                  onPressed: () {
                    setState(() {
                      isPlay = !isPlay;
                      audioInstance.setPlay(isPlay);
                    });
                  },
                ),
                const SizedBox(
                  width: 0,
                ),
                StreamBuilder<Duration>(
                  stream: audioInstance.player.durationStream,
                  builder: (context, snapshot) {
                    //1/200;
                    Duration duration = snapshot.data ?? Duration.zero;
                    return StreamBuilder<PositionData>(
                      stream: Rx.combineLatest2<Duration, Duration, PositionData>(
                          audioInstance.player.positionStream,
                          audioInstance.player.bufferedPositionStream,
                          (position, bufferedPosition) => PositionData(position, bufferedPosition)),
                      builder: (context, snapshot) {
                        final positionData = snapshot.data ?? PositionData(Duration.zero, Duration.zero);
                        var position = positionData.position;
                        if (position > duration) {
                          position = duration;
                        }
                        var bufferedPosition = positionData.bufferedPosition;
                        if (bufferedPosition > duration) {
                          bufferedPosition = duration;
                        }
                        //print("stream builder val> "+snapshot.data.toString()+" >> "+bufferedPosition.toString()+" >> "+position.toString());

                        return widget.width > 200
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    formatDuration(position),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  SizedBox(
                                    width: widget.width > 160 ? widget.width - 160 : widget.width,
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 2,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                        trackShape: CustomTrackShape(),
                                      ),
                                      child: Slider(
                                          min: 0.0,
                                          max: duration.inMilliseconds.toDouble(),
                                          activeColor: Colors.black,
                                          inactiveColor: Colors.black.withOpacity(0.05),
                                          value: position.inMilliseconds.toDouble(),
                                          onChanged: (val) {
                                            /// 2secs: 2/100
                                            setState(() {
                                              //seekValue=val;
                                              //audioInstance._player.position;
                                              audioInstance.seekTo(Duration(milliseconds: val.toInt()));
                                            });
                                          }),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 14,
                                  ),
                                  Text(
                                    formatDuration(duration),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                ],
                              )
                            : const SizedBox();
                        /*return SeekBar(
                      duration: duration,
                      position: position,
                      bufferedPosition: bufferedPosition,
                      onChangeEnd: (newPosition) {
                        _player.seek(newPosition);
                      },
                    );*/
                      },
                    );
                  },
                ),
              ],
            ),
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
