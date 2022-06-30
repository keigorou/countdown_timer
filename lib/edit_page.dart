import 'dart:convert';
import 'dart:io';
// import 'dart:js';
// import 'dart:js';

import 'package:countdown_timer/main.dart';
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countdown_timer/training_menu.dart';
import 'package:countdown_timer/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'functions.dart';

class EditPage extends ConsumerStatefulWidget {
  const EditPage({Key? key, required this.trainingSetName, }) : super(key: key);
  final String trainingSetName;

  @override
  EditPageState createState() => EditPageState();
}

class EditPageState extends ConsumerState<EditPage> {
  final _textcontroller = TextEditingController();
  final _timecontroller = TextEditingController();
  final _descriptioncontroller = TextEditingController();
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    ref.watch(trainingMenuProvider);
    final trainingSet = ref.watch(trainingMenuProvider.notifier).getTrainingSet(widget.trainingSetName);
    final List<TrainingMenu> trainingMenu = trainingSet!.trainingMenu;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trainingSetName),

      ),
      body:  Center(
        child: Column(
          children: <Widget>[
            trainingMenu.isEmpty ? ElevatedButton(
                onPressed: () {
                  _MakeTrainingMenuDialog(context, ref, widget.trainingSetName);
                  },
                child: Text('作成'))
                : Column(
                  children: [
                    TrainingList(trainingMenu: trainingMenu,),
                    ElevatedButton(
                        onPressed: () {
                          _MakeTrainingMenuDialog(context, ref, widget.trainingSetName);
                        },
                        child: Text('作成'))
                  ],
                ),
          ],
        ),
      ),
      );
  }

  Future _MakeTrainingMenuDialog (BuildContext context, WidgetRef ref, String trainingName) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('トレーニング内容'),
                content: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(hintText: 'トレーニング名'),
                      controller: _textcontroller,
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: 'トレーニング時間'),
                      controller: _timecontroller,
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: 'トレーニング詳細'),
                      controller: _descriptioncontroller,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await _getAndSaveImageFromDevice(ImageSource.camera);
                          setState((){});
                        }, child: Text('画像を追加')),
                    (imageFile == null)
                        ? Icon(Icons.no_sim)
                        : Image.memory(
                            imageFile!.readAsBytesSync(),
                            height: 100,
                            width: 100,)
                  ],
                ),

                actions: <Widget>[
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('キャンセル')),
                  ElevatedButton(
                      onPressed: () async {
                        _MakeTrainingMenu(ref, _textcontroller.text, _timecontroller.text, _descriptioncontroller.text);
                        _textcontroller.clear();
                        _timecontroller.clear();
                        _descriptioncontroller.clear();
                        Navigator.pop(context);
                      },
                      child: Text('作成する'))
                ],
              );
            }
          );
    });
  }

  Future<void> _MakeTrainingMenu(WidgetRef ref, String text, String time, String description) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var trainingSet = ref.watch(trainingMenuProvider.notifier).getTrainingSet(widget.trainingSetName);
    List<TrainingMenu> trainingMenuList = trainingSet!.trainingMenu;
    TrainingMenu trainingMenu = TrainingMenu(
        time: int.parse(time),
        trainingName: text,
        description: description,
    );
    trainingMenuList.add(trainingMenu);
    List<String> jsonList = trainingMenuList.map((f) => jsonEncode(f)).toList();
    prefs.setStringList(widget.trainingSetName, jsonList);
    trainingSet = trainingSet.copyWith(title: widget.trainingSetName, trainingMenu: trainingMenuList);
    ref.watch(trainingMenuProvider.notifier).change();
  }

  Future<void> _getAndSaveImageFromDevice(ImageSource source) async {
    PickedFile? imageFile = await ImagePicker.platform.pickImage(source: source);
    if (imageFile == null) {
      return;
    }
    var savedFile = await ImageFileController.savaLocalImage(imageFile);
    setState((){
      this.imageFile = savedFile;
    });
  }
}

class TrainingList extends StatelessWidget {
  const TrainingList({Key? key, required this.trainingMenu}) : super(key: key);
  final List<TrainingMenu> trainingMenu;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: trainingMenu.length,
            itemBuilder: (BuildContext context, int index){
              return ListTile(
                title: Text(trainingMenu[index].trainingName),
                subtitle: Text(trainingMenu[index].time.toString()),
              );
            }),
      ),
    );
  }
}



