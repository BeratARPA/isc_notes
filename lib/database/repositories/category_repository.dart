import 'package:drift/drift.dart';
import 'package:isc_notes/database/app_database.dart';
import 'package:isc_notes/models/category_model.dart';

class CategoryRepository {
  final AppDatabase db;
  CategoryRepository(this.db);

  CategoryModel _toModel(CategoryTableData e) {
    return CategoryModel(
      id: e.id,
      name: e.name,
      colorHex: e.colorHex,
      iconName: e.iconName,
      sortOrder: e.sortOrder,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );
  }

  Future<List<CategoryModel>> getAll() async {
    final rows =
        await (db.select(db.categoryTable)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.sortOrder,
                  mode: OrderingMode.asc,
                ),
              ]))
            .get();
    return rows.map(_toModel).toList();
  }

  Future<CategoryModel?> getById(int id) async {
    final row = await (db.select(
      db.categoryTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  Future<List<CategoryModel>> getDeletedCategories() async {
    final rows =
        await (db.select(db.categoryTable)
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

  Future<int> add(CategoryModel model) {
    return db
        .into(db.categoryTable)
        .insert(
          CategoryTableCompanion.insert(
            name: model.name,
            colorHex: model.colorHex,
            iconName: Value(model.iconName),
            sortOrder: Value(model.sortOrder),
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
            deletedAt: Value(model.deletedAt),
          ),
        );
  }

  Future<bool> updateCategory(CategoryModel model) {
    return db
        .update(db.categoryTable)
        .replace(
          CategoryTableCompanion(
            id: Value(model.id!),
            name: Value(model.name),
            colorHex: Value(model.colorHex),
            iconName: Value(model.iconName),
            sortOrder: Value(model.sortOrder),
            createdAt: Value(model.createdAt),
            updatedAt: Value(DateTime.now()),
            deletedAt: Value(model.deletedAt),
          ),
        );
  }

  Future<int> delete(int id) {
    return (db.delete(db.categoryTable)..where((t) => t.id.equals(id))).go();
  }

  Future<int> softDelete(int id) {
    return (db.update(db.categoryTable)..where((t) => t.id.equals(id))).write(
      CategoryTableCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> restore(int id) {
    return (db.update(db.categoryTable)..where((t) => t.id.equals(id))).write(
      const CategoryTableCompanion(deletedAt: Value(null)),
    );
  }
}
