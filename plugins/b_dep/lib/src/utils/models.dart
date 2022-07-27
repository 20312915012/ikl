import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share/share.dart';

class BAudioClass {
  BAudioClass(this.context);

  final player = AudioPlayer();
  Duration _duration = const Duration(seconds: 0);
  BuildContext context;
  bool isMultiFiles = false;

  bool isPlay, isStop, isNext, isPrevious, isLoopAll, isLoopOne, isLoopOff, isShuffle;
  bool isPropUpdate = false;
  int seekToMilliseconds;
  double volume, speed;

  void setPlay(bool isPlay) async {
    //print("isPlay> "+isPlay.toString());
    if (isPlay != null) {
      if (isPlay) {
        player.play();

        if (this.isPlay == null || !this.isPlay) {
          this.isPlay = true;
          isPropUpdate = true;
        }
      } else {
        player.pause();

        if (this.isPlay == null || this.isPlay) {
          this.isPlay = false;
          isPropUpdate = true;
        }
      }
    }
  }

  void setStop(bool isStop) {
    //print("isStop> "+isStop.toString());
    if (isStop != null && isStop) {
      player.stop();

      if (this.isStop == null || !this.isStop) {
        this.isStop = true;
        isPropUpdate = true;
      }
    } else {
      if (this.isStop == null || this.isStop) {
        this.isStop = false;
        isPropUpdate = true;
      }
    }
  }

  void setNext(bool isNext) {
    if (isNext != null && isNext && isMultiFiles) {
      player.seekToNext();

      if (this.isNext == null || !this.isNext) {
        this.isNext = true;
        isPropUpdate = true;
      }
    } else {
      if (this.isNext == null || this.isNext) {
        this.isNext = false;
        isPropUpdate = true;
      }
    }
  }

  void setPrevious(bool isPrevious) {
    if (isPrevious != null && isPrevious && isMultiFiles) {
      player.seekToPrevious();

      if (this.isPrevious == null || !this.isPrevious) {
        this.isPrevious = true;
        isPropUpdate = true;
      }
    } else {
      if (this.isPrevious == null || this.isPrevious) {
        this.isPrevious = false;
        isPropUpdate = true;
      }
    }
  }

  void seekTo(Duration seekToPosition) {
    if (seekToPosition != null) {
      player.seek(seekToPosition);

      if (seekToMilliseconds == null || seekToPosition.inMilliseconds != seekToMilliseconds) {
        seekToMilliseconds = seekToPosition.inMilliseconds;
        isPropUpdate = true;
      }
    }
  }

  void setSpeed(double speedX) {
    if (speedX != null) {
      player.setSpeed(speedX);

      if (speed == null || speedX != speed) {
        speed = speedX;
        isPropUpdate = true;
      }
    }
  }

  void setVolume(double volumeX) {
    if (volumeX != null) {
      player.setVolume(volumeX);

      if (volume == null || volumeX != volume) {
        volume = volumeX;
        isPropUpdate = true;
      }
    }
  }

  void setLoopAll(bool isLoopAll) {
    //print("isStop> "+isStop.toString());
    if (isLoopAll != null && isLoopAll) {
      player.setLoopMode(LoopMode.all);

      if (this.isLoopAll == null || !this.isLoopAll) {
        this.isLoopAll = true;
        isPropUpdate = true;
      }
    } else {
      if (this.isLoopAll == null || this.isLoopAll) {
        this.isLoopAll = false;
        isPropUpdate = true;
      }
    }
  }

  void setLoopOne(bool isLoopOne) {
    if (isLoopOne != null && isLoopOne) {
      player.setLoopMode(LoopMode.one);

      if (this.isLoopOne == null || !this.isLoopOne) {
        this.isLoopOne = true;
        isPropUpdate = true;
      }
    } else {
      if (this.isLoopOne == null || this.isLoopOne) {
        this.isLoopOne = false;
        isPropUpdate = true;
      }
    }
  }

  void setLoopOff(bool isLoopOff) {
    if (isLoopOff != null && isLoopOff) {
      player.setLoopMode(LoopMode.off);
      if (this.isLoopOff == null || !this.isLoopOff) {
        this.isLoopOff = true;
        isPropUpdate = true;
      }
    } else {
      if (this.isLoopOff == null || this.isLoopOff) {
        this.isLoopOff = false;
        isPropUpdate = true;
      }
    }
  }

  void setShuffle(bool isShuffle) {
    if (isShuffle != null && isShuffle) {
      player.setShuffleModeEnabled(isShuffle);
      if (!this.isShuffle) {
        this.isShuffle = true;
        isPropUpdate = true;
      }
    } else {
      if (this.isShuffle) {
        this.isShuffle = false;
        isPropUpdate = true;
      }
    }
  }

  void getPropUpdate(Function onPropUpdate) {
    if (onPropUpdate != null && isPropUpdate) {
      isPropUpdate = false;
      onPropUpdate(
        this,
        isPlay ?? false,
        isStop ?? false,
        isNext ?? false,
        isPrevious ?? false,
        seekToMilliseconds ?? 0,
        volume ?? 0.0,
        speed ?? 0.0,
        isLoopAll ?? false,
        isLoopOne ?? false,
        isLoopOff ?? false,
        isShuffle ?? false,
      );
    }
  }

  int getDuration() {
    return _duration.inSeconds;
  }

  void setFilePath(List<dynamic> filePath) async {
    //print("setFilePath> "+filePath.toString()+" >> "+filePath.length.toString());
    if (filePath != null) {
      if (filePath.length == 1) {
        //Single file.
        isMultiFiles = false;
        if (filePath.first.contains("https:") || filePath.first.contains("http:")) {
          _duration = await player.setUrl(filePath.first);
        } else {
          _duration = await player.setFilePath(filePath.first);
        }
      } else {
        //Multiple files.
        isMultiFiles = true;
        _duration = await player.setAudioSource(
          ConcatenatingAudioSource(
            useLazyPreparation: true,
            shuffleOrder: DefaultShuffleOrder(),
            children: [for (var i = 0; i < filePath.length; i++) AudioSource.uri(Uri.parse(filePath.elementAt(i)))],
          ),
          initialIndex: 0,
          initialPosition: Duration.zero,
        );
      }
    }
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    //print("width>>> "+trackWidth.toString());
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;

  PositionData(this.position, this.bufferedPosition);
}

class EBOnTapTapForList {
  String listId;
  String scrollTo;

  EBOnTapTapForList(this.listId, this.scrollTo);
}

///xxx---Share---xxx-START-///
class BShare {
  void share(String text,
      {String subject, List<String> filePaths, List<String> mimeTypes, Function onComplete, Function onError}) {
    if (filePaths == null || filePaths.length == 0) {
      Share.share(text, subject: subject).whenComplete(() {
        if (onComplete != null) {
          onComplete();
        }
      }).onError((error, stackTrace) {
        if (onError != null) {
          onError(error.toString());
        }
      });
    } else {
      Share.shareFiles(filePaths, text: text, subject: subject, mimeTypes: mimeTypes).whenComplete(() {
        if (onComplete != null) {
          onComplete();
        }
      }).onError((error, stackTrace) {
        if (onError != null) {
          onError(error.toString());
        }
      });
    }
  }
}

///xxx---Share---xxx-END-///