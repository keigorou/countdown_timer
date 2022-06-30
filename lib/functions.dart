import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';



class ImageFileController {
  // ドキュメントパスを取得
  static Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
  }

  // 画像をファイルに保存する。
  // カメラ撮影時のimageファイルを引数に入れる。
  static Future savaLocalImage(PickedFile image) async {
    final path = await localPath;
    final imagePath = '$path/img.jpeg';
    File imageFile = File(imagePath);
    // カメラで撮影した画像は撮影時用の一時的フォルダパスに保存されるため、
    // その画像をドキュメントへ保存し直す。
    var savedFile = await imageFile.writeAsBytes(await image.readAsBytes());
    return savedFile;
  }

}