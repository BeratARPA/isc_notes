import 'package:isc_notes/database/repositories/note_repository.dart';
import 'package:isc_notes/models/note_model.dart';
import 'package:isc_notes/viewmodels/base_viewmodel.dart';

class NoteEditorViewModel extends BaseViewModel {
  final NoteRepository _noteRepository;
  NoteEditorViewModel(this._noteRepository);

  Future<void> saveNote(int? id, String title, String content) async {
    if (id != null) {
      var existingNote = await _noteRepository.getById(id);
      if (existingNote != null) {
        existingNote.title = title;
        existingNote.content = content;
        existingNote.updatedAt = DateTime.now();
        await _noteRepository.updateNote(existingNote);
      }
    } else {
      if (title.trim().isEmpty && content.trim().isEmpty) return;

      var noteModel = NoteModel(title: title, content: content);

      await _noteRepository.add(noteModel);
    }
  }
}
