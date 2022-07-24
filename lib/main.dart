import 'dart:convert';
// import 'dart:js';

import 'package:countdown_timer/image_controller.dart';
import 'package:countdown_timer/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countdown_timer/training_menu.dart';
import 'package:countdown_timer/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_page.dart';

import 'package:flutter/rendering.dart';

final trainingMenuProvider = StateNotifierProvider.autoDispose<TrainingMenuNotifierProvider, List<TrainingSet>>(
        (ref){
          return TrainingMenuNotifierProvider([]);
        });

void main() async {
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  Set<String> trainings = prefs.getKeys();
  List<TrainingSet> setList = [];

  // for (final t in trainings) {
  //   print(prefs.getStringList(t));
  // }

  for (final String training in trainings) {
    List<String>? jsonList = prefs.getStringList(training);
    var lists = jsonList!.map((f) => TrainingMenu.fromJson(json.decode(f))).toList();
    TrainingSet trainingSet = TrainingSet(title: training, trainingMenu: lists);
    setList.add(trainingSet);
  }

  runApp(
      ProviderScope(
        overrides: [
          trainingMenuProvider.overrideWithProvider(StateNotifierProvider.autoDispose(
                  (ref) => TrainingMenuNotifierProvider(setList)))
        ],
          child: const MyApp()
      )
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Circular Countdown Timer Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFEFEFE),
      ),
      home: const _TrainingSetList(title: 'Circular Countdown Timer'),
    );
  }
}

class _TrainingSetList extends ConsumerWidget {
  const _TrainingSetList({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TrainingSet> trainingSets = ref.watch(trainingMenuProvider);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(title.toString(),),
      // ),
      body: Center(
        child: Column(
          children: [
            const Header(),
            SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: trainingSets.length,
                      itemBuilder: (context, index){
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (trainingSets[index].trainingMenu.isEmpty) {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return EditPage(
                                            trainingSetName: trainingSets[index]
                                                .title);
                                      }));
                                } else {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return Training(
                                          index: 0, trainingSet: trainingSets[index],);
                                      }));
                                }
                               },
                              onLongPress: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return EditPage(trainingSetName: trainingSets[index].title);
                                    }));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: 180,
                                  child: Card(
                                    elevation: 8,
                                    shadowColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(3),
                                                topRight: Radius.circular(3),
                                            ),
                                            color: Colors.black54
                                              // gradient: LinearGradient(
                                              //     begin: Alignment.topRight,
                                              //     end: Alignment.bottomLeft,
                                              //     colors: [
                                              //       Color(0x181515),
                                              //       Color(0xFF1C1A1A)
                                              //     ]
                                              // )
                                          ),
                                          height: 36,
                                          width:  MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 18.0),
                                            child: Text(
                                              trainingSets[index].title,
                                              style: const TextStyle(
                                                        fontSize: 24,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          // leading: const Material(
                                          //   shape: CircleBorder(
                                          //     side: BorderSide(
                                          //       width: 2,
                                          //       color: Colors.orange,
                                          //     ),
                                          //   ),
                                          //   child: Image(
                                          //     image: AssetImage('assets/images/yoga.jpeg'),
                                          //     width: 48,
                                          //     height: 48,
                                          //   ),
                                          // ),
                                          subtitle: Container(
                                            margin: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                trainingSets[index].trainingMenu.asMap().containsKey(0) ?
                                                Text(
                                                    trainingSets[index].trainingMenu[0].trainingName,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                )
                                                    : const Text(''),
                                                trainingSets[index].trainingMenu.asMap().containsKey(1) ?
                                                Text(
                                                    trainingSets[index].trainingMenu[1].trainingName,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                )
                                                    : const Text(''),
                                                trainingSets[index].trainingMenu.asMap().containsKey(2) ?
                                                Text(
                                                    trainingSets[index].trainingMenu[2].trainingName,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                )
                                                    : const Text(''),
                                                trainingSets[index].trainingMenu.asMap().containsKey(3) ?
                                                const Text(
                                                    '....',
                                                    style: TextStyle(
                                                      fontSize: 18
                                                    ),
                                                )
                                                    : const Text(''),
                                              ],
                                            ),
                                          ),
                                          trailing: GestureDetector(
                                              child: const Icon(Icons.edit),
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) {
                                                    return EditPage(trainingSetName: trainingSets[index].title);
                                                  }));
                                            },
                                          ),

                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                  ),
                  _MakeTrainingMenu(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _MakeTrainingMenu extends ConsumerWidget {
  _MakeTrainingMenu({Key? key}) : super(key: key);

  final _textcontroller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      child: ElevatedButton(
        onPressed: (){
          _inputTrainingSetName(context, ref);
        },
        child: const Text('トレーニングセット新規作成'),
      )
    );
  }


  Future _inputTrainingSetName(BuildContext context, WidgetRef ref) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('トレーニングセット新規作成'),
              content: TextFormField(
                decoration: const InputDecoration(hintText: 'トレーニングセット名'),
                controller: _textcontroller,
                // validator: (value) {
                //   print(value);
                //   if (ref.watch(trainingMenuProvider.notifier)
                //       .isExistTrainingSet(value!)) {
                //     return 'III';
                //   }else {
                //     print('UUU');
                //   }
                // }
              ),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('キャンセル')),
                ElevatedButton(
                    onPressed: () async {
                     makeTrainingSet(ref);
                     Navigator.pop(context);
                     Navigator.push(context,
                         MaterialPageRoute(builder: (context) =>
                             EditPage(trainingSetName: _textcontroller.text,)));
                    },
                    child: const Text('作成する'))
              ],
          );
        });
  }

  void makeTrainingSet(WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // ImageFileController.makeDirectory(_textcontroller.text);
    TrainingSet set = TrainingSet(title: _textcontroller.text, trainingMenu: []);
    ref.watch(trainingMenuProvider.notifier).addTrainingSet(set);
    prefs.setStringList(_textcontroller.text, []);
  }
}
