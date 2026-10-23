import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:isc_notes/l10n/app_localizations.dart';
import 'package:isc_notes/models/note_model.dart';
import 'package:isc_notes/viewmodels/home_viewmodel.dart';
import 'package:isc_notes/viewmodels/note_editor_viewmodel.dart';
import 'package:isc_notes/views/main_layout.dart';
import 'package:isc_notes/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late NoteModel? _note;

  late QuillController _quillController;
  late TextEditingController _titleController;

  @override
  void initState() {
    _quillController = QuillController.basic();
    _titleController = TextEditingController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _note = ModalRoute.of(context)!.settings.arguments as NoteModel?;
      if (_note != null) {
        // JSON'dan Document'e dönüştür
        try {
          final doc = Document.fromJson(jsonDecode(_note!.content));
          _quillController.document = doc;
        } catch (e) {
          // Eski formatta metin varsa, düz metin olarak ekle
          _quillController.document.insert(0, _note!.content);
        }
        _titleController.text = _note!.title;
      }
    });
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NoteEditorViewModel>(context, listen: false);
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) return;

        final jsonContent = jsonEncode(
          _quillController.document.toDelta().toJson(),
        );

        await viewModel.saveNote(_note?.id, _titleController.text, jsonContent);

        await homeViewModel.getNotes();
      },
      child: MainLayoutView(
        showDrawer: false,
        appBar: CustomAppbar(
          title: TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.untitled,
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            QuillSimpleToolbar(
              controller: _quillController,
              config: QuillSimpleToolbarConfig(
                showDividers: true,
                multiRowsDisplay: false,
                showSmallButton: true,
                showLineHeightButton: true,
                showAlignmentButtons: true,
                showDirection: true,
                showClipboardCopy: true,
                showClipboardCut: true,
                showClipboardPaste: true,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: QuillEditor.basic(
                controller: _quillController,
                config: QuillEditorConfig(
                  enableScribble: true,
                  padding: EdgeInsets.all(16),
                  contextMenuBuilder: (context, editableTextState) {
                    final buttonItems =
                        editableTextState.contextMenuButtonItems;
                    return AdaptiveTextSelectionToolbar.buttonItems(
                      anchors: TextSelectionToolbarAnchors(
                        primaryAnchor:
                            editableTextState.contextMenuAnchors.primaryAnchor +
                            const Offset(0, 95),
                      ),
                      buttonItems: buttonItems,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
