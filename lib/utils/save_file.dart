import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;

Future<Directory> getImageSaveLocation() async {
  return (await getExternalStorageDirectory())!;
}

Future<void> savePngFileInSupDir({
  required String path,
  required String name,
  required img.Image image,
}) async {
  Directory docDir = await getImageSaveLocation();
  Directory finalDir = Directory(p.join(docDir.path, path));
  if (!finalDir.existsSync()) {
    finalDir.createSync(recursive: true);
  }
  await img.encodePngFile(p.join(finalDir.path, name), image);
}

Future<FilePathAndroidBitmap> loadPngFileInSupDir({
  required String path,
  required String name,
}) async {
  Directory docDir = await getImageSaveLocation();
  String finalPath = p.join(docDir.path, path, name);
  return FilePathAndroidBitmap(finalPath);
}
