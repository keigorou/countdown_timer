import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';


class ImageFileController {
  // ドキュメントパスを取得
  static Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
  }

  static Future<String> makeImageFileName() async {
    final path = await localPath;
    final List<FileSystemEntity> entities = await Directory(path).list().toList();
    String? imageFileNumber;
    List<int> imageFileNumbers = [];

    for (final entity in entities) {
      if (entity.path.endsWith('jpeg')) {
        // 'image-number.jpeg'のnumberを取得
        imageFileNumber = (entity.path.split('/').last.split('.').first.split('-').last);
        imageFileNumbers.add(int.parse(imageFileNumber));
      }
    }

    if (imageFileNumbers.isEmpty) {
      return 'image-1';
    } else {
      return 'image-${imageFileNumbers.reduce(max) + 1}';
    }
  }

  static void deleteImageFile(String imageFileName) async {
    final path = await localPath;
    final imagePath = '$path/$imageFileName.jpeg';
    try {
      final imageFile = File(imagePath);
      await imageFile.delete();
    } catch (e) {
      return;
    }
  }

  // 画像をファイルに保存する。
  // カメラ撮影時のimageファイルを引数に入れる。
  static Future savaLocalImage(PickedFile image, String imageFileName) async {
    final path = await localPath;
    final imagePath = '$path/$imageFileName.jpeg';
    File imageFile = File(imagePath);
    // カメラで撮影した画像は撮影時用の一時的フォルダパスに保存されるため、
    // その画像をドキュメントへ保存し直す。
    var savedFile = await imageFile.writeAsBytes(await image.readAsBytes());
    return savedFile;
  }

}