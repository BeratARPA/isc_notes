import 'package:isc_notes/database/repositories/category_repository.dart';
import 'package:isc_notes/models/category_model.dart';
import 'package:isc_notes/viewmodels/base_viewmodel.dart';

class CategoryManagerViewModel extends BaseViewModel {
  final CategoryRepository _categoryRepository;

  CategoryManagerViewModel(this._categoryRepository) {
    getCategories();
  }

  final List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  Future<void> getCategories() async {
    try {
      _categories.clear();
      final fetchedCategories = await _categoryRepository.getAll();
      _categories.addAll(fetchedCategories);

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);
    for (int i = 0; i < _categories.length; i++) {
      _categories[i].sortOrder = i;
      await _categoryRepository.updateCategory(_categories[i]);
    }
    notifyListeners();
  }

  Future<void> saveCategory(
    int? id,
    String name,
    String iconKey,
    String colorHex,
  ) async {
    if (id != null) {
      var existingCategory = await _categoryRepository.getById(id);
      if (existingCategory != null) {
        existingCategory.name = name;
        existingCategory.iconName = iconKey;
        existingCategory.colorHex = '#$colorHex';
        existingCategory.updatedAt = DateTime.now();
        await _categoryRepository.updateCategory(existingCategory);
      }
    } else {
      final categoryModel = CategoryModel(
        name: name,
        iconName: iconKey,
        colorHex: '#$colorHex',
        sortOrder: _categories.length,
      );
      await _categoryRepository.add(categoryModel);
    }

    await getCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _categoryRepository.softDelete(id);
    await getCategories();
  }
}
