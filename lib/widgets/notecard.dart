import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:isc_notes/l10n/app_localizations.dart';
import 'package:isc_notes/models/category_model.dart';
import 'package:isc_notes/models/note_model.dart';
import 'package:isc_notes/utils/category_icons.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final CategoryModel? category;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    this.category,
    this.onTap,
    this.onLongPress,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat(
      'dd MMM yyyy, HH:mm',
      Localizations.localeOf(context).toString(),
    );

    // JSON'dan Document oluştur
    Document document;
    try {
      document = Document.fromJson(jsonDecode(note.content));
    } catch (e) {
      // Eski formatta metin varsa, düz metin olarak oluştur
      document = Document()..insert(0, note.content);
    }
    final QuillController _quillController = QuillController(
      readOnly: true,
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: category != null
                ? Color(int.parse(category!.colorHex.replaceFirst('#', '0xff')))
                : note.isPinned
                ? Colors.amber
                : note.isLocked
                ? Colors.red
                : theme.dividerColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ÜST SATIR: Sabit ikonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (category?.iconName != null) ...[
                    Icon(
                      CategoryIcons.icons[category!.iconName] ?? Icons.label,
                      size: 18,
                      color: Color(
                        int.parse(category!.colorHex.replaceFirst('#', '0xff')),
                      ),
                    ),
                  ],
                  if (note.isPinned)
                    const Icon(Icons.push_pin, size: 18, color: Colors.amber),
                  if (note.isLocked)
                    const Icon(Icons.lock_rounded, size: 18, color: Colors.red),
                ],
              ),

              const SizedBox(height: 4),

              // Başlık
              Text(
                note.title.isNotEmpty
                    ? note.title
                    : AppLocalizations.of(context)!.untitled,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              // İçerik (özet)
              Expanded(
                child: note.content.isNotEmpty
                    ? note.isLocked
                          ? ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 3,
                                sigmaY: 3,
                              ),
                              child: AbsorbPointer(
                                child: QuillEditor.basic(
                                  controller: _quillController,
                                  config: const QuillEditorConfig(
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            )
                          : AbsorbPointer(
                              child: QuillEditor.basic(
                                controller: _quillController,
                                config: const QuillEditorConfig(
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            )
                    : Text(
                        AppLocalizations.of(context)!.notFoundNoteYet,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.hintColor.withOpacity(0.8),
                        ),
                      ),
              ),

              const SizedBox(height: 8),

              // ALT SATIR: Tarih + Attachment icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(note.updatedAt),
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: 11,
                      color: theme.hintColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
