import 'package:path/path.dart';
import 'package:ponto_app/db/time_entry.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), "ponto_app.db"),
    version: 1,
    onCreate: (db, version) {
      db.execute(TimeEntry.tableSql);
    },
  );
}
