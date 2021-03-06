import 'dart:io';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:countdown_timer/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'image_controller.dart';

import 'main.dart';


class Training extends ConsumerStatefulWidget {
  const Training({Key? key, required this.index, required this.trainingSet}) : super(key: key);

  final int index;
  final TrainingSet trainingSet;

  @override
  _TrainingState createState() => _TrainingState();
}

class _TrainingState extends ConsumerState<Training> {
  late final int _duration;
  final CountDownController _controller = CountDownController();

  final Future<String> path = ImageFileController.localPath;

  @override
  void initState(){
    super.initState();
    // ref.read(trainingMenuProvider);
    _duration = widget.trainingSet.trainingMenu[widget.index].time.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trainingSet.trainingMenu[widget.index].trainingName),
      ),
      body: Column(
        children:[
          Center(
              child: CircularCountDownTimer(
                // Countdown duration in Seconds.
                duration: _duration,

                // Countdown initial elapsed Duration in Seconds.
                initialDuration: 0,

                // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                controller: _controller,

                // Width of the Countdown Widget.
                width: MediaQuery.of(context).size.width / 2,

                // Height of the Countdown Widget.
                height: MediaQuery.of(context).size.height / 2.5,

                // Ring Color for Countdown Widget.
                ringColor: Colors.grey[300]!,

                // Ring Gradient for Countdown Widget.
                ringGradient: null,

                // Filling Color for Countdown Widget.
                fillColor: Colors.purpleAccent[100]!,

                // Filling Gradient for Countdown Widget.
                fillGradient: null,

                // Background Color for Countdown Widget.
                backgroundColor: Colors.purple[600],

                // Background Gradient for Countdown Widget.
                backgroundGradient: null,

                // Border Thickness of the Countdown Ring.
                strokeWidth: 20.0,

                // Begin and end contours with a flat edge and no extension.
                strokeCap: StrokeCap.round,

                // Text Style for Countdown Text.
                textStyle: const TextStyle(
                  fontSize: 33.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),

                // Format for the Countdown Text.
                textFormat: CountdownTextFormat.S,

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
                onComplete: () {
                  // Here, do whatever you want
                  debugPrint('Countdown Ended');
                  if (widget.trainingSet.trainingMenu.length == widget.index + 1) {
                    EndDialog(context);
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return Training(index: widget.index + 1,
                            trainingSet: widget.trainingSet,);
                        }));
                  }
                },
              )),
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(24),
                topLeft: Radius.circular(24),
              ),
              color: Colors.green
              ),
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2.5,
            child: Column(
              children: [
                FutureBuilder(
                    future: path,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                       if (snapshot.hasData) {
                        return Image.file(
                          File('${snapshot.data}/${widget.trainingSet.trainingMenu[widget.index].imagePath}.jpeg'),
                          width: MediaQuery.of(context).size.width * 0.8 * 0.8,
                          height: MediaQuery.of(context).size.width * 0.6 * 0.8,

                        );
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
                Text(widget.trainingSet.trainingMenu[widget.index].description)
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 30,
          ),
          _button(title: "Start", onPressed: () => _controller.start()),
          const SizedBox(
            width: 10,
          ),
          _button(title: "Pause", onPressed: () => _controller.pause()),
          const SizedBox(
            width: 10,
          ),
          _button(title: "Resume", onPressed: () => _controller.resume()),
          const SizedBox(
            width: 10,
          ),
          _button(
              title: "Restart",
              onPressed: () => _controller.restart(duration: _duration))
        ],
      ),
    );
  }

  Widget _button({required String title, VoidCallback? onPressed}) {
    return Expanded(
        child: ElevatedButton(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.purple),
          ),
          onPressed: onPressed,
        ));
  }
}

Future EndDialog (BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('??????'),
          content: ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            }, child: const Text('TOP'),
          ),
        );
      });
}
