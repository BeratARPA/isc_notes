import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:isc_notes/database/tables/category_table.dart';
import 'package:isc_notes/database/tables/note_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [NoteTable, CategoryTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Migration (ileride tablo değişirse burası çalışacak)
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async => await m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {}, // ileriye hazırlık
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final folder = await getApplicationDocumentsDirectory();
    final file = File(p.join(folder.path, 'app.db'));
    return NativeDatabase(file);
  });
}
