import 'dart:convert';
// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countdown_timer/training_menu.dart';
import 'package:countdown_timer/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_page.dart';

// const TrainingMenu menu1 = TrainingMenu(time: 10, title: 'first');
// const TrainingMenu menu2 = TrainingMenu(time: 20, title: 'second');
// final List<TrainingMenu> menuList = [menu1, menu2];
//
// TrainingSet set = TrainingSet(title: 'ストレッチ', trainingMenu: menuList);
// List<TrainingSet> setList = [set];
final trainingMenuProvider = StateNotifierProvider.autoDispose<TrainingMenuNotifierProvider, List<TrainingSet>>(
        (ref){
          return TrainingMenuNotifierProvider([]);
        });


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // List<TrainingMenuModel> trainingMenuModels = [
  //     TrainingMenuModel(time: 10, trainingName: '腕立て'),
  //     TrainingMenuModel(time: 10, trainingName: '腹筋'),
  //     TrainingMenuModel(time: 10, trainingName: 'スクワット')
  // ];
  // List<String> jsonList = trainingMenuModels.map((f) => jsonEncode(f.toJson())).toList();
  // prefs.setStringList('筋トレ', jsonList);
  // prefs.setStringList('ヨガ', jsonList);


  Set<String> trainings = prefs.getKeys();
  List<TrainingSet> setList = [];
  prefs.remove('a');
  // print(trainings);
  for (final t in trainings) {
    print(prefs.getStringList(t));
  }
  // print(prefs.getStringList('ヨガ'));
  // print(prefs.getStringList('筋トレ'));



  for (final String training in trainings) {
    List<String>? jsonList = prefs.getStringList(training);
    var lists = jsonList!.map((f) => TrainingMenu.fromJson(json.decode(f))).toList();
    TrainingSet set = TrainingSet(title: training, trainingMenu: lists);
    setList.add(set);
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
        primarySwatch: Colors.purple,
      ),
      home: const TrainingList(title: 'Circular Countdown Timer'),
    );
  }
}

class TrainingList extends ConsumerWidget {
  const TrainingList({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainings = ref.watch(trainingMenuProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title.toString(),),
      ),
      body: Center(
        child: Column(
          children: [
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trainings.length,
                itemBuilder: (context, index){
                  return Column(
                    children: [
                      ElevatedButton(
                          onPressed: (){
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return Training(index: 0, trainingSet: trainings[index],);
                                }));
                          },
                          child:  Text(trainings[index].title)
                      )
                    ],
                  );
                }
            ),
            _MakeTrainingMenu(),
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
          _InputTrainingSetName(context, ref);
        },
        child: const Text('トレーニングセット新規作成'),
      )
    );
  }

  Future _InputTrainingSetName(BuildContext context, WidgetRef ref) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('トレーニングセット新規作成'),
              content: TextField(
                decoration: const InputDecoration(hintText: 'トレーニングセット名'),
                controller: _textcontroller,
              ),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('キャンセル')),
                ElevatedButton(
                    onPressed: () async {
                     MakeTrainingSetName(ref);
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

  void MakeTrainingSetName(WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    TrainingSet set = TrainingSet(title: _textcontroller.text, trainingMenu: []);
    ref.watch(trainingMenuProvider.notifier).addTrainingList(set);
    prefs.setStringList(_textcontroller.text, []);
  }
}
