import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

part 'database_service.g.dart';

class DatabaseService {
  DatabaseService(this.db);
  final Database db;

  static Future<Database> createDatabase(String fileName) async {
    if (!kIsWeb) {
      final appDocDir = await getApplicationDocumentsDirectory();
      return databaseFactoryIo.openDatabase('${appDocDir.path}/$fileName');
    } else {
      return databaseFactoryWeb.openDatabase(fileName);
    }
  }

  static Future<DatabaseService> makeDefault() async {
    return DatabaseService(await createDatabase('default.db'));
  }

  static Future<void> deleteDatabase() async {
    if (!kIsWeb) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = '${appDocDir.path}/default.db';
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('DB has been deleted');
      }
    }
  }
}

@Riverpod(keepAlive: true)
Future<DatabaseService> databaseService(Ref ref) async {
  final service = await DatabaseService.makeDefault();
  debugPrint(service.db.path);

  ref.onDispose(() {
    service.db.close();
  });
  return service;
}
