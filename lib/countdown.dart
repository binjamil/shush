import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

class CountdownTimer extends StatefulWidget {
  CountdownTimer({this.timerDuration});

  int timerDuration;

  @override
  CountdownTimerState createState() => CountdownTimerState();
}

class CountdownTimerState extends State<CountdownTimer>
    with TickerProviderStateMixin {
  AnimationController controller;

  AudioPlayer player;
  AudioCache audioCache;

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    player.stop();
  }

  @override
  void initState() {
    super.initState();
    initPlayer();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timerDuration),
      value: 1.0,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          player.stop();
        }
      });
  }

  void initPlayer() {
    player = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: player);

    player.onAudioPositionChanged.listen((Duration p) {
      if (p.inSeconds == widget.timerDuration) {
          player.stop();
        }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('state dispose');

    //controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timerDuration),
      value: 1.0,
    );

    return Padding(
        padding: EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () {
            if (controller.isAnimating) {
              //controller.stop();
            } else {
              audioCache.play("audio.mp3");
              controller.reverse(
                  from: controller.value == 0.0 ? 1.0 : controller.value);
            }
          },
          child: Align(
            alignment: FractionalOffset.center,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (BuildContext context, Widget child) {
                        return CustomPaint(
                            painter: TimerPainter(
                          animation: controller,
                          backgroundColor: Colors.white,
                          color: themeData.indicatorColor,
                        ));
                      },
                    ),
                  ),
                  Align(
                    alignment: FractionalOffset.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        AnimatedBuilder(
                            animation: controller,
                            builder: (BuildContext context, Widget child) {
                              return Text(
                                timerString,
                                style: themeData.textTheme.display4,
                              );
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class TimerPainter extends CustomPainter {
  TimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
