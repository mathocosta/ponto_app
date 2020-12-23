import 'package:ponto_app/db/app_db.dart';
import 'package:sqflite/sqflite.dart';

class TimeEntry {
  static const String tableName = 'time_entries';
  static const String _id = 'id';
  static const String _isActive = 'active';
  static const String _createdAt = 'created_at';

  static const String tableSql = 'CREATE TABLE $tableName('
      '$_id INTEGER PRIMARY KEY,'
      '$_isActive INTEGER,'
      '$_createdAt TEXT)';

  int id;
  bool isActive;
  DateTime createdAt;

  TimeEntry();

  TimeEntry.fromMap(Map<String, dynamic> map) {
    id = map[_id];
    isActive = map[_isActive] == 1 ? true : false;
    createdAt = DateTime.parse(map[_createdAt]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      _isActive: isActive == true ? 1 : 0,
      _createdAt: createdAt.toString()
    };

    if (id != null) {
      map[_id] = id;
    }

    return map;
  }
}

class TimeEntries {
  Future<List<TimeEntry>> list() async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
      TimeEntry.tableName,
      orderBy: "datetime(${TimeEntry._createdAt}) DESC",
    );

    return List.generate(
      maps.length,
      (index) => TimeEntry.fromMap(maps[index]),
    );
  }

  Future<Map<DateTime, List<TimeEntry>>> listGroupedByDate() async {
    final List<TimeEntry> allEntries = await list();
    final Map<DateTime, List<TimeEntry>> map = <DateTime, List<TimeEntry>>{};

    for (var timeEntry in allEntries) {
      DateTime actualDate = timeEntry.createdAt;
      DateTime key = DateTime(
        actualDate.year,
        actualDate.month,
        actualDate.day,
      );

      if (map.containsKey(key)) {
        map[key].add(timeEntry);
      } else {
        map[key] = [timeEntry];
      }
    }

    return map;
  }

  Future insert(TimeEntry timeEntry) async {
    final Database db = await getDatabase();

    await db.insert(TimeEntry.tableName, timeEntry.toMap());
  }

  Future clearTable() async {
    final Database db = await getDatabase();

    await db.rawQuery("DELETE FROM ${TimeEntry.tableName}");
  }
}
