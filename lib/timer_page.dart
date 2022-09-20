import 'dart:io';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:countdown_timer/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'image_controller.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'main.dart';


class Training extends ConsumerStatefulWidget {
  const Training({Key? key, required this.index, required this.trainingSet}) : super(key: key);

  final int index;
  final TrainingSet trainingSet;

  @override
  _TrainingState createState() => _TrainingState();
}

class _TrainingState extends ConsumerState<Training> {
  late  int _duration;
  final CountDownController _controller = CountDownController();

  final Future<String> path = ImageFileController.localPath;
  bool started = true;
  bool stopped = true;

  @override
  void initState(){
    super.initState();
    _duration = widget.trainingSet.trainingMenu[widget.index].time.toInt();
  }

  void start(){
    setState((){
      started = false;
      stopped = false;
    });
    _controller.start();
  }

  void stop(){
    setState((){
      started = false;
      stopped = true;
    });
    _controller.pause();
  }

  void resume(){
    setState((){
      started = false;
      stopped = false;
    });
    _controller.resume();
  }

  void restart(){
    setState((){
      started = false;
      stopped = false;
    });
    _controller.restart();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trainingSet.trainingMenu[widget.index].trainingName),
        backgroundColor: Colors.black54,
      ),
      body: Container(
        width: width,
        height: height,
        color: Colors.black54,
        // padding: const EdgeInsets.all(6),
        child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 0,),
                  _timer(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _button(
                          onPressed: restart,
                          icon: const Icon(Icons.replay, size: 40,),
                          width: width / 4,
                          height: 50
                      ),
                      started && stopped ?
                      _button(
                          onPressed: start,
                          icon: const Icon(Icons.play_arrow, size: 40),
                          width: width / 4,
                          height: 50
                      )
                          : !started && !stopped
                          ? _button(
                          onPressed: stop,
                          icon: const Icon(Icons.pause, size: 40,),
                          width: width / 4,
                          height: 50
                      )
                          : _button(
                          onPressed: resume,
                          icon: const Icon(Icons.play_arrow, size: 40,),
                          width: width / 4,
                          height: 50
                      ),
                      _button(
                          onPressed: () {
                            if (widget.trainingSet.trainingMenu.length == widget
                                .index + 1) {
                              null;
                            } else {
                              // タイマー作動中に次のページに遷移するときは、タイマーを止める
                              if (started == false) {
                                stop();
                              }
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return Training(index: widget.index + 1,
                                      trainingSet: widget.trainingSet,);
                                  }));
                            }
                          },
                          icon: const Icon(Icons.skip_next, size: 40,),
                          width: width / 4,
                          height: 50
                      ),
                    ],
                  ),
                  SizedBox(
                    width: width * 0.8,
                    child: _showImage(),
                  ),
                  _bottomSheet(context, widget, width)
                ],
              )
        ),
      );
  }

  Widget _timer(BuildContext context) {
    return CircularCountDownTimer(
      // Countdown duration in Seconds.
      duration: _duration,

      // Countdown initial elapsed Duration in Seconds.
      initialDuration: 0,

      // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
      controller: _controller,

      // Width of the Countdown Widget.
      width: MediaQuery.of(context).size.width * 2.2 / 3,

      // Height of the Countdown Widget.
      height: MediaQuery.of(context).size.height * 1 / 3,

      // Ring Color for Countdown Widget.
      ringColor: Colors.grey[300]!,

      // Ring Gradient for Countdown Widget.
      ringGradient: null,

      // Filling Color for Countdown Widget.
      fillColor: Colors.greenAccent,

      // Filling Gradient for Countdown Widget.
      fillGradient: null,

      // Background Color for Countdown Widget.
      // backgroundColor: Colors.purple[600],

      // Background Gradient for Countdown Widget.
      backgroundGradient: null,

      // Border Thickness of the Countdown Ring.
      strokeWidth: 6.0,

      // Begin and end contours with a flat edge and no extension.
      strokeCap: StrokeCap.round,

      // Text Style for Countdown Text.
      textStyle: TextStyle(
        fontSize: MediaQuery.of(context).size.width / 6,
        color: Colors.greenAccent,
        fontWeight: FontWeight.bold,
      ),

      // Format for the Countdown Text.
      textFormat: CountdownTextFormat.MM_SS,

      // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
      isReverse: true,

      // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
      isReverseAnimation: false,

      // Handles visibility of the Countdown Text.
      isTimerTextShown: true,

      // Handles the timer start.
      autoStart: false,

      // This Callback will execute when the Countdown Starts.
      onStart: () {
        // Here, do whatever you want
        debugPrint('Countdown Started');
      },

      // This Callback will execute when the Countdown Ends.
      onComplete: () async {
        // Here, do whatever you want
        debugPrint('Countdown Ended');
        FlutterRingtonePlayer.play(
          fromAsset: 'assets/sounds/alarm_1.mp3',
          // android: AndroidSounds.notification,
          ios: IosSounds.glass,
          looping: true, // Android only - API >= 28
          volume: 1, // Android only - API >= 28
          asAlarm: false,
        );
        await Future.delayed(Duration(seconds: 3));
        FlutterRingtonePlayer.stop();
        if (widget.trainingSet.trainingMenu.length == widget.index + 1) {
          endDialog(context);
        } else {
          setState((){
            started = true;
            stopped = true;
          });
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return Training(index: widget.index + 1,
                  trainingSet: widget.trainingSet,);
              }));
        }
      },
    );
  }

  Widget _button({
    required VoidCallback? onPressed,
    required Icon icon,
    required double width,
    required double height
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            primary: Colors.transparent
        ),
        child: icon,
      ),
    );
  }

  Widget _showImage(){
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: FutureBuilder(
          future: path,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (widget.trainingSet.trainingMenu[widget.index].imagePath == '') {
                return  const SizedBox();
              } else {
                return AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(
                    fit: BoxFit.fill,
                    File('${snapshot.data}/${widget.trainingSet.trainingMenu[widget.index].imagePath}.jpeg'),
                    width: MediaQuery.of(context).size.width,
                  ),
                );
              }
            } else if (snapshot.hasError) {
              return const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              );
            } else {
              return const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              );
            }
          }
      ),
    );
  }
}

Widget _bottomSheet(BuildContext context, widget, double width){
  return GestureDetector(
        onTap: () {
            showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) {
               return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)
                      )
                    ),
                  child: Text(
                      widget.trainingSet.trainingMenu[widget.index].description,
                      style: const TextStyle(
                      // color: Colors.white,
                      fontSize: 24,
                    )
                  ),
                 );
               });
        },
        child: Container(
                alignment: Alignment.center,
                width: width * 0.98,
                height: 16,
                decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)
                      )
                     ),
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.4),
                    child: const Divider(color: Colors.black, height: 4,)
                ),
              ),
    );
}

Future endDialog (BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('お疲れ様でした！'),
          content: ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            }, child: const Text('TOPへ'),
          ),
        );
      });
}
