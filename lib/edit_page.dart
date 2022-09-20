import 'dart:convert';
import 'dart:io';

import 'package:countdown_timer/functions.dart';
import 'package:countdown_timer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    ref.watch(trainingMenuProvider);
    final trainingSet = ref.watch(trainingMenuProvider.notifier).getTrainingSet(widget.trainingSetName);
    final List<TrainingMenu> trainingMenuList = trainingSet.trainingMenu;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trainingSetName),
        actions: [
          IconButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('このトレーニングセットを全て削除しますか？'),
                        content: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _removeTrainingSet(ref, trainingSet);
                          },
                            child: const Text('削除する'),
                        ),
                      );
                    });
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete)
              )
        ],

      ),
      body:  Center(
        child: Column(
          children: <Widget>[
            trainingMenuList.isEmpty ? ElevatedButton(
                onPressed: () {
                  _makeTrainingMenuDialog(context, ref, widget.trainingSetName);
                  },
                child: const Text('作成'))
                : Column(
                  children: [
                    _trainingList(trainingSet, trainingMenuList),
                  ],
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          _makeTrainingMenuDialog(context, ref, widget.trainingSetName);
        },
      ),
      );
  }

  Future _makeTrainingMenuDialog (BuildContext context, WidgetRef ref, String trainingSetName, [TrainingMenu? trainingMenu, int? index]) async {
    final imageFileName = await ImageFileController.makeImageFileName();
    final textController = TextEditingController(text: trainingMenu == null ? '' : trainingMenu.trainingName);
    final timeController = TextEditingController(text: trainingMenu == null ? '' : trainingMenu.time.toString());
    final descriptionController = TextEditingController(text: trainingMenu == null ? '' : trainingMenu.description);
    final path = ImageFileController.localPath;

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('トレーニング内容'),
                insetPadding: EdgeInsets.all(10),
                content: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'トレーニング名',
                          ),
                          controller: textController,
                        ),
                        const SizedBox(height: 8,),
                        Container(
                            alignment: Alignment.centerLeft,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'トレーニング時間',
                              suffixText: '秒'
                          ),
                          controller: timeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'トレーニング詳細'
                          ),
                          controller: descriptionController,
                        ),
                        const SizedBox(height: 16,),
                        GestureDetector(
                            child: Column(
                              children: [
                                const Text('参考画像'),
                                const SizedBox(height: 16,),
                                trainingMenu == null
                                    ? imageFile == null
                                    ? Container(
                                    width: 200,
                                    height: 150,
                                    decoration: BoxDecoration(
                                        border: Border.all()
                                    ),
                                    child: const Icon(Icons.no_photography, size: 60,)
                                )
                                    : Image.memory(
                                  imageFile!.readAsBytesSync(),
                                  height: 200,
                                  width: 150,)
                                    : trainingMenu.imagePath == '' && imageFile == null
                                    ? Container(
                                    width: 200,
                                    height: 150,
                                    decoration: BoxDecoration(
                                        border: Border.all()
                                    ),
                                    child: const Icon(Icons.add_a_photo_rounded, size: 60,)
                                )
                                    : imageFile != null
                                    ? Image.memory(
                                  imageFile!.readAsBytesSync(),
                                  height: 200,
                                  width: 150,
                                )
                                    : FutureBuilder(
                                  future: path,
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      if (trainingMenu.imagePath != '') {
                                        return Image.file(
                                          File('${snapshot.data}/${trainingMenu.imagePath}.jpeg'),
                                        );
                                      } else {
                                        return const Icon(Icons.add_a_photo) ;
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
                              ],
                            ),
                            onTap: (){
                              showDialog<void>(
                            context: context,
                            // false = user must tap button, true = tap outside dialog
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('画像を追加する'),
                                content: Container(
                                  height: 120,
                                  child: Column(
                                    children: <Widget>[
                                      const SizedBox(height: 12,),
                                      TextButton(
                                        // style: ElevatedButton.styleFrom(primary: Colors.orangeAccent),
                                          onPressed: () async {
                                            await _getAndSaveImageFromDevice(ImageSource.camera, imageFileName);
                                            setState((){});
                                            Navigator.pop(context);
                                          }, child: const Text('カメラから', style: TextStyle(fontSize: 18),)
                                      ),
                                      TextButton(
                                        // style: ElevatedButton.styleFrom(primary: Colors.orangeAccent),
                                          onPressed: () async {
                                            await _getAndSaveImageFromDevice(ImageSource.gallery, imageFileName);
                                            setState((){});
                                            Navigator.pop(context);
                                          }, child: const Text('アルバムから', style: TextStyle(fontSize: 18),)
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        ),
                        const SizedBox(height: 12,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                                style: OutlinedButton.styleFrom(fixedSize: Size(80, 30)),
                                onPressed: () {
                                  textController.clear();
                                  timeController.clear();
                                  descriptionController.clear();
                                  imageFile = null;
                                  ImageFileController.deleteImageFile(imageFileName);
                                  Navigator.pop(context);
                                },
                                child: const Text('閉じる')),
                            ElevatedButton(
                                style: OutlinedButton.styleFrom(fixedSize: Size(80, 30)),
                                onPressed: () async {
                                  _makeAndEditTrainingMenu(
                                    ref,
                                    textController.text,
                                    timeController.text,
                                    descriptionController.text,
                                    imageFile == null ? '' : imageFileName,
                                    index,
                                  );
                                  textController.clear();
                                  timeController.clear();
                                  descriptionController.clear();
                                  Navigator.pop(context);
                                },
                                child: const Text('作成'))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          );
    });
  }

 Future<void> _makeAndEditTrainingMenu(WidgetRef ref, String text, String time, String description, String imageFileName, int? index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var trainingSet = ref.watch(trainingMenuProvider.notifier).getTrainingSet(widget.trainingSetName);
    List<TrainingMenu> trainingMenuList = trainingSet.trainingMenu;

    // indexがnullの時は新規で作る。nullではない時は編集する処理。
    if (index == null){
      TrainingMenu trainingMenu = TrainingMenu(
        trainingName: text,
        time: time == '' ? 30 : int.parse(time),
        description: description,
        imagePath: imageFileName,
      );
      trainingMenuList.add(trainingMenu);
    } else if (imageFileName == '') {
      trainingMenuList[index] = trainingMenuList[index].copyWith(
                                                          trainingName: text,
                                                          time: int.parse(time),
                                                          description: description
                                                      );
    } else {
      // 画像が変更された時、前の画像を消してから新しいimagePathを登録。
      ImageFileController.deleteImageFile(trainingMenuList[index].imagePath);
      trainingMenuList[index] = trainingMenuList[index].copyWith(
                                                          trainingName: text,
                                                          time: int.parse(time),
                                                          description: description,
                                                          imagePath: imageFileName
                                                      );
    }

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

  Future<void> _getAndSaveImageFromDevice(ImageSource source, String imageFileName) async {
    PickedFile? imageFile = await ImagePicker.platform.pickImage(source: source);
    if (imageFile == null) {
      return;
    }
    var savedFile = await ImageFileController.savaLocalImage(imageFile, imageFileName);

    if (source == ImageSource.camera) {
      // ギャラリーに保存
      Uint8List _buffer = await imageFile.readAsBytes();
      ImageGallerySaver.saveImage(_buffer);
    }

    setState((){
      this.imageFile = savedFile;
    });
  }

  Widget _trainingList(TrainingSet trainingSet, List<TrainingMenu> trainingMenuList) {
    final Future<String> path = ImageFileController.localPath;

    return SingleChildScrollView(
      child: Center(
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trainingMenuList.length,
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
                  onTap: (){
                    _makeTrainingMenuDialog(context, ref, widget.trainingSetName, trainingMenuList[index], index);
                  },
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
                    trainingMenuList[index].trainingName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(changeToMMSS(trainingMenuList[index].time))
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: (){
                      _deleteMenu(trainingSet, trainingMenuList, index);
                      ref.watch(trainingMenuProvider.notifier).change();
                    },
                  ),
                ),
              ),
            );
          },
          onReorder: (int oldIndex, int newIndex) {
            _onReorder(trainingSet, trainingMenuList, oldIndex, newIndex);
            ref.watch(trainingMenuProvider.notifier).change();
          },
          proxyDecorator: (widget, _, __) {
            return Opacity(opacity: 0.5, child: widget);
          },
        ),
      ),
    );
  }

  void _onReorder(TrainingSet trainingSet, List<TrainingMenu> trainingMenuList, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    trainingMenuList.insert(newIndex, trainingMenuList.removeAt(oldIndex));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList  = trainingMenuList.map((f) => jsonEncode(f)).toList();
    prefs.setStringList(trainingSet.title, jsonList);
  }

  void _deleteMenu(TrainingSet trainingSet, List<TrainingMenu> trainingMenuList, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (trainingMenuList[index].imagePath != ''){
      ImageFileController.deleteImageFile(trainingMenuList[index].imagePath);
    }
    trainingMenuList.removeAt(index);
    List<String> jsonList  = trainingMenuList.map((f) => jsonEncode(f)).toList();
    prefs.setStringList(trainingSet.title, jsonList);
  }
}




