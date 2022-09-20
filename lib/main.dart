import 'dart:convert';
import 'package:countdown_timer/functions.dart';
import 'package:countdown_timer/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countdown_timer/timer_page.dart';
import 'package:countdown_timer/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_page.dart';
import 'package:expandable/expandable.dart';

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
      home: _TrainingSetList(title: 'Circular Countdown Timer'),
    );
  }
}

class _TrainingSetList extends ConsumerWidget {
  _TrainingSetList({Key? key, this.title}) : super(key: key);
  final String? title;
  final _textcontroller = TextEditingController();


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TrainingSet> trainingSets = ref.watch(trainingMenuProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Header(),
            // ListItems(trainingSets: trainingSets),
            ExpandList(trainingSets: trainingSets),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){
          _inputTrainingSetName(context, ref);
        },
      ),
    );
  }

  Future _inputTrainingSetName(BuildContext context, WidgetRef ref) {
    final _formKey = GlobalKey<FormState>();

    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: _formKey,
            child: AlertDialog(
              title: const Text('トレーニングセット新規作成'),
              content: SizedBox(
                height: 150,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'トレーニングセット名'),
                      controller: _textcontroller,
                      validator: (value) {
                        if (ref.watch(trainingMenuProvider.notifier)
                            .isExistTrainingSet(value!)) {
                          return '同名のトレーニングセットがあります。';
                        } else if (value == '') {
                          return 'トレーニングセット名を入力して下さい。';
                        }
                      }
                    ),
                    // SizedBox(height: 24,),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('キャンセル')),
                        ElevatedButton(
                            onPressed: () async {
                              if(_formKey.currentState!.validate()){
                                makeTrainingSet(ref);
                                Navigator.pop(context);
                                await Navigator.push(context,
                                    MaterialPageRoute(builder: (context) =>
                                        EditPage(trainingSetName: _textcontroller.text,)));
                                _textcontroller.clear();
                              }
                            },
                            child: const Text('作成する'))
                      ],
                    )
                  ],

                ),
              ),
            ),
          );
        });
  }

  void makeTrainingSet(WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    TrainingSet set = TrainingSet(title: _textcontroller.text, trainingMenu: []);
    ref.watch(trainingMenuProvider.notifier).addTrainingSet(set);
    prefs.setStringList(_textcontroller.text, []);
  }
}


class ExpandList extends StatelessWidget {
  const ExpandList({Key? key, required this.trainingSets}) : super(key: key);

  final List<TrainingSet> trainingSets;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: trainingSets.length,
        itemBuilder: (context, index){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 12, bottom: 6, top: 3),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: size.width * 0.8,
                  child: ExpandablePanel(
                      header: Container(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                            trainingSets[index].title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                        ),
                      ),
                      collapsed: Text('total time ' + changeToMMSS(trainingSets[index].getTotalTime())),
                      expanded: Column(
                        children: [
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: trainingSets[index].trainingMenu.length,
                              itemBuilder: (context, _index){
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 12, bottom: 2),
                                      width: size.width * 0.6,
                                      child: Text(
                                        (_index + 1).toString() + '. ' + trainingSets[index].trainingMenu[_index].trainingName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 16
                                        ),
                                      ),
                                    ),
                                    Container(
                                        margin: const EdgeInsets.only(right: 12),
                                        child: Text(changeToMMSS(trainingSets[index].trainingMenu[_index].time)
                                        )
                                    ),
                                  ],
                                );
                              }),
                          const SizedBox(height: 8,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'total time  ' + changeToMMSS(trainingSets[index].getTotalTime()),
                                style: TextStyle(fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return EditPage(trainingSetName: trainingSets[index].title);
                                      }));
                                },
                                child: Container(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: const Icon(Icons.edit)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3,)
                        ],
                      )
                  ),
                ),
                GestureDetector(
                  onTap: () => trainingSets[index].trainingMenu.isEmpty
                                  ? Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                    return EditPage(
                                    trainingSetName: trainingSets[index]
                                        .title);
                                    }))
                                  : Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                    return Training(
                                    index: 0, trainingSet: trainingSets[index],);
                                    })),

                  child: SizedBox(
                    // color: Colors.black54,
                    width: size.width * 0.15,
                    height: 50,
                    child: const Icon(
                      Icons.play_circle,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                  ),
                )
              ],
            ),
          );
        }
        );
  }
}
