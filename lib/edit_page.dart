import 'dart:convert';
import 'dart:io';

import 'package:countdown_timer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countdown_timer/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_controller.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';
import 'package:path/path.dart';


class EditPage extends ConsumerStatefulWidget {
  const EditPage({Key? key, required this.trainingSetName,}) : super(key: key);
  final String trainingSetName;

  @override
  EditPageState createState() => EditPageState();
}

class EditPageState extends ConsumerState<EditPage> {
  final _textController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    ref.watch(trainingMenuProvider);
    final trainingSet = ref.watch(trainingMenuProvider.notifier).getTrainingSet(widget.trainingSetName);
    final List<TrainingMenu> trainingMenu = trainingSet.trainingMenu;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trainingSetName),
        actions: [
          IconButton(
              onPressed: () {
                _removeTrainingSet(ref, trainingSet);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete)
              )
        ],

      ),
      body:  Center(
        child: Column(
          children: <Widget>[
            trainingMenu.isEmpty ? ElevatedButton(
                onPressed: () {
                  _makeTrainingMenuDialog(context, ref, widget.trainingSetName, trainingMenu);
                  },
                child: const Text('作成'))
                : Column(
                  children: [
                    _TrainingList(trainingSet: trainingSet,trainingMenu: trainingMenu),
                    ElevatedButton(
                        onPressed: () {
                          _makeTrainingMenuDialog(context, ref, widget.trainingSetName, trainingMenu);
                        },
                        child: const Text('作成'))
                  ],
                ),
          ],
        ),
      ),
      );
  }

  Future _makeTrainingMenuDialog (BuildContext context, WidgetRef ref, String trainingSetName, List trainingMenu) async {
    final imageFilePath = await ImageFileController.makeImageFilePath();

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('トレーニング内容'),
                content: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: 'トレーニング名'),
                      controller: _textController,
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: 'トレーニング時間'),
                      controller: _timeController,
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: 'トレーニング詳細'),
                      controller: _descriptionController,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await _getAndSaveImageFromDevice(ImageSource.camera, imageFilePath);
                          setState((){});
                        }, child: const Text('カメラ')),
                    ElevatedButton(
                        onPressed: () async {
                          await _getAndSaveImageFromDevice(ImageSource.gallery, imageFilePath);
                          setState((){});
                        }, child: const Text('ギャラリー')),
                    (imageFile == null)
                        ? const Icon(Icons.no_sim)
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
                      child: const Text('キャンセル')),
                  ElevatedButton(
                      onPressed: () async {
                        _makeTrainingMenu(
                            ref,
                            _textController.text,
                            _timeController.text,
                            _descriptionController.text,
                            imageFile == null ? ''
                            : imageFilePath,
                            );
                        _textController.clear();
                        _timeController.clear();
                        _descriptionController.clear();
                        Navigator.pop(context);
                      },
                      child: const Text('作成する'))
                ],
              );
            }
          );
    });
  }

  Future<void> _makeTrainingMenu(WidgetRef ref, String text, String time, String description, String imageFilePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var trainingSet = ref.watch(trainingMenuProvider.notifier).getTrainingSet(widget.trainingSetName);
    List<TrainingMenu> trainingMenuList = trainingSet.trainingMenu;
    TrainingMenu trainingMenu = TrainingMenu(
        trainingName: text,
        time: int.parse(time),
        description: description,
        imagePath: imageFilePath,
    );
    trainingMenuList.add(trainingMenu);
    List<String> jsonList = trainingMenuList.map((f) => jsonEncode(f)).toList();
    prefs.setStringList(trainingSet.title, jsonList);
    trainingSet = trainingSet.copyWith(trainingMenu: trainingMenuList);
    ref.watch(trainingMenuProvider.notifier).change();
  }

  Future<void> _removeTrainingSet(WidgetRef ref, TrainingSet trainingSet) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (final menu in trainingSet.trainingMenu) {
      // 画像ファイルの削除
      ImageFileController.deleteImageFile(menu.imagePath);
    }
    ref.watch(trainingMenuProvider.notifier).removeTrainingSet(trainingSet);
    prefs.remove(trainingSet.title);
  }

  Future<void> _getAndSaveImageFromDevice(ImageSource source, String imageFilePath) async {
    PickedFile? imageFile = await ImagePicker.platform.pickImage(source: source);
    if (imageFile == null) {
      return;
    }
    var savedFile = await ImageFileController.savaLocalImage(imageFile, imageFilePath);
    print(basename(savedFile.path));
    if (source == ImageSource.camera) {
      // ギャラリーに保存
      Uint8List _buffer = await imageFile.readAsBytes();
      ImageGallerySaver.saveImage(_buffer);
    }

    setState((){
      this.imageFile = savedFile;
    });
  }
}

class _TrainingList extends ConsumerWidget {
  const _TrainingList({Key? key, required this.trainingSet, required this.trainingMenu}) : super(key: key);
  final TrainingSet trainingSet;
  final List<TrainingMenu> trainingMenu;
  final Future<String> path = ImageFileController.localPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Center(
        child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trainingMenu.length,
            itemBuilder: (BuildContext context, int index){
              return Material(
                key: Key('$index'),
                child: Container(
                  height: 80,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide()
                    )
                  ),
                  child: ListTile(
                    leading: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Center(
                        child: FutureBuilder(
                          future: path,
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                             if (snapshot.hasData) {
                               if (trainingSet.trainingMenu[index].imagePath != '') {
                                 return Image.file(
                                    File('${snapshot.data}/${trainingSet.trainingMenu[index].imagePath}.jpeg'),
                                    );
                               } else {
                                 return const Icon(Icons.no_photography) ;
                               }
                            } else if (snapshot.hasError) {
                               return const Icon(
                                 Icons.check_circle_outline,
                                 color: Colors.green,
                                 size: 30,
                               );
                             } else {
                               return const SizedBox(
                                 width: 30,
                                 height: 30,
                                 child: CircularProgressIndicator(),
                               );
                             }
                          },
                        ),
                      ),
                    ),
                    title: Text(
                        trainingMenu[index].trainingName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          (trainingMenu[index].time >= 60)
                          ? Text((trainingMenu[index].time ~/ 60).toString())
                          : const Text('0'),
                          const Text(':'),
                          (trainingMenu[index].time >= 60)
                          ? Text((trainingMenu[index].time % 60).toString())
                          : Text(trainingMenu[index].time.toString())
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: (){
                        _deleteMenu(trainingMenu, index);
                        ref.watch(trainingMenuProvider.notifier).change();
                      },
                    ),
                  ),
                ),
              );
            },
            onReorder: (int oldIndex, int newIndex) {
              _onReorder(trainingMenu, oldIndex, newIndex);
            },
            proxyDecorator: (widget, _, __) {
              return Opacity(opacity: 0.5, child: widget);
            },
        ),
      ),
    );
  }

  void _onReorder(List<TrainingMenu> trainingMenu, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    trainingMenu.insert(newIndex, trainingMenu.removeAt(oldIndex));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList  = trainingMenu.map((f) => jsonEncode(f)).toList();
    prefs.setStringList(trainingSet.title, jsonList);
  }

  void _deleteMenu(List<TrainingMenu> trainingMenu, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (trainingMenu[index].imagePath != ''){
      ImageFileController.deleteImageFile(trainingMenu[index].imagePath);
    }
    trainingMenu.removeAt(index);
    List<String> jsonList  = trainingMenu.map((f) => jsonEncode(f)).toList();
    prefs.setStringList(trainingSet.title, jsonList);
  }
}



