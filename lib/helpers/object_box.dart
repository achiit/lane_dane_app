import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../objectbox.g.dart';
import '../models/users.dart';

class ObjectBox {
  /// The Store of this app.
  late final Store store;
  late final Admin admin;
  late final Box<Users> userBox;

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
    if (kDebugMode && Platform.isAndroid) {
      if (Admin.isAvailable()) {
        admin = Admin(store);
      }
    }

    // (Optional) Close at some later point.
    // admin.close();
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create({ByteData? reference}) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final tablePath = p.join(docsDir.path, "lane-Dane");

    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store;
    if (reference == null) {
      store = await openStore(directory: tablePath);
    } else {
      store = Store.fromReference(getObjectBoxModel(), reference);
    }
    return ObjectBox._create(store);
  }
}
