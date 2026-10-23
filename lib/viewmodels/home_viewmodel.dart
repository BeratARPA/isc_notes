import 'package:isc_notes/database/repositories/category_repository.dart';
import 'package:isc_notes/database/repositories/note_repository.dart';
import 'package:isc_notes/models/category_model.dart';
import 'package:isc_notes/models/note_model.dart';
import 'package:isc_notes/utils/app_navigator.dart';
import 'package:isc_notes/viewmodels/base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  final NoteRepository _noteRepository;
  final CategoryRepository _categoryRepository;

  HomeViewModel(this._noteRepository, this._categoryRepository) {
    _initialize();
  }

  final List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  final List<NoteModel> _notes = [];
  List<NoteModel> get notes => _notes;

  Future<void> _initialize() async {
    await Future.wait([getNotes(), getCategories()]);
  }

  Future<void> getNotes() async {
    try {
      _notes.clear();
      final fetchedNotes = await _noteRepository.getAll();
      _notes.addAll(fetchedNotes);

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

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

  CategoryModel? getCategoryById(int? categoryId) {
    if (categoryId == null) return null;
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  Future<void> togglePin(NoteModel note) async {
    note.isPinned = !note.isPinned;
    note.updatedAt = DateTime.now();
    await _noteRepository.updateNote(note);
    await getNotes();
  }

  Future<void> deleteNote(NoteModel note) async {
    await _noteRepository.softDelete(note.id!);
    await getNotes();
  }

  Future<bool> toggleLock(NoteModel note, String password) async {
    if (note.password != null) {
      if (password.isEmpty) {
        AppNavigator.showSnack('Parola boş olamaz.');
        return false;
      }
      // Unlocking
      if (note.password == password) {
        note.isLocked = false;
        note.password = null;
        note.updatedAt = DateTime.now();
      } else {
        AppNavigator.showSnack('Yanlış parola girildi.');
        return false;
      }
    } else {
      // Locking
      note.isLocked = true;
      note.updatedAt = DateTime.now();
      note.password = password;
    }

    await _noteRepository.updateNote(note);
    await getNotes();
    return true;
  }

  Future<void> assignCategory(NoteModel note, CategoryModel category) async {
    note.categoryId = category.id;
    note.updatedAt = DateTime.now();
    await _noteRepository.updateNote(note);
    await getNotes();
  }
}
