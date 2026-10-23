import 'package:isc_notes/database/repositories/category_repository.dart';
import 'package:isc_notes/database/repositories/note_repository.dart';
import 'package:isc_notes/models/category_model.dart';
import 'package:isc_notes/models/note_model.dart';
import 'package:isc_notes/viewmodels/base_viewmodel.dart';

class RecycleBinViewModel extends BaseViewModel {
  final NoteRepository _noteRepository;
  final CategoryRepository _categoryRepository;

  RecycleBinViewModel(this._noteRepository, this._categoryRepository) {
    Future.wait([emptyRecycleBin()]);
  }

  final List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  final List<NoteModel> _notes = [];
  List<NoteModel> get notes => _notes;

  Future<void> emptyRecycleBin() async {
    try {
      _notes.clear();
      _notes.addAll(await _noteRepository.getDeletedNotes());
      _categories.clear();
      _categories.addAll(await _categoryRepository.getDeletedCategories());

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> restoreCategory(CategoryModel category) async {
    category.deletedAt = null;
    category.updatedAt = DateTime.now();
    await _categoryRepository.updateCategory(category);
    await emptyRecycleBin();
  }

  Future<void> deleteCategoryPermanently(CategoryModel category) async {
    await _categoryRepository.delete(category.id!);
    await emptyRecycleBin();
  }

  Future<void> restoreNote(NoteModel note) async {
    note.deletedAt = null;
    note.updatedAt = DateTime.now();
    await _noteRepository.updateNote(note);
    await emptyRecycleBin();
  }

  Future<void> deleteNotePermanently(NoteModel note) async {
    await _noteRepository.delete(note.id!);
    await emptyRecycleBin();
  }
}
