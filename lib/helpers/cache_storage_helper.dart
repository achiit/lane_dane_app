import 'package:get_storage/get_storage.dart';

// A simple cache class
class CacheStorageHelper {
  final storage = GetStorage();
  Future<void> saveFile(String key, dynamic value) async {
    await storage.write(key, value);
  }

  Future<dynamic> readFile(String key) async {
    return await storage.read(key);
  }

  Future<dynamic> deleteFile(String key) async {
    return await storage.remove(key);
  }
}

//   // Write data to cache
//   await CacheStorageHelper.writeData('myData', {'name': 'John', 'age': 30});

//   // Read data from cache
//   final cachedData = await CacheStorageHelper.readData('myData');
