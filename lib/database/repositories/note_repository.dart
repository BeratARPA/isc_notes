import 'package:drift/drift.dart';
import 'package:isc_notes/database/app_database.dart';
import 'package:isc_notes/models/note_model.dart';

class NoteRepository {
  final AppDatabase db;
  NoteRepository(this.db);

  NoteModel _toModel(NoteTableData e) {
    return NoteModel(
      id: e.id,
      categoryId: e.categoryId,
      title: e.title,
      content: e.content,
      isPinned: e.isPinned,
      isLocked: e.isLocked,
      password: e.password,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );
  }

  Future<List<NoteModel>> getAll() async {
    final rows =
        await (db.select(db.noteTable)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();

    return rows.map(_toModel).toList();
  }

  Future<NoteModel?> getById(int id) async {
    final row = await (db.select(
      db.noteTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  Future<List<NoteModel>> getDeletedNotes() async {
    final rows =
        await (db.select(db.noteTable)
              ..where((t) => t.deletedAt.isNotNull())
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.deletedAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();

    return rows.map(_toModel).toList();
  }

  Future<int> add(NoteModel model) {
    return db
        .into(db.noteTable)
        .insert(
          NoteTableCompanion.insert(
            categoryId: Value(model.categoryId),
            title: model.title,
            content: model.content,
            isPinned: Value(model.isPinned),
            isLocked: Value(model.isLocked),
            password: Value(model.password),
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
            deletedAt: Value(model.deletedAt),
          ),
        );
  }

  Future<bool> updateNote(NoteModel model) {
    return db
        .update(db.noteTable)
        .replace(
          NoteTableCompanion(
            id: Value(model.id!),
            categoryId: Value(model.categoryId),
            title: Value(model.title),
            content: Value(model.content),
            isPinned: Value(model.isPinned),
            isLocked: Value(model.isLocked),
            password: Value(model.password),
            createdAt: Value(model.createdAt),
            updatedAt: Value(DateTime.now()),
            deletedAt: Value(model.deletedAt),
          ),
        );
  }

  Future<int> delete(int id) {
    return (db.delete(db.noteTable)..where((t) => t.id.equals(id))).go();
  }

  Future<int> softDelete(int id) {
    return (db.update(db.noteTable)..where((t) => t.id.equals(id))).write(
      NoteTableCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> restore(int id) {
    return (db.update(db.noteTable)..where((t) => t.id.equals(id))).write(
      const NoteTableCompanion(deletedAt: Value(null)),
    );
  }
}
