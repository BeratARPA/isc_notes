import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:isc_notes/l10n/app_localizations.dart';
import 'package:isc_notes/utils/app_navigator.dart';
import 'package:isc_notes/utils/category_icons.dart';
import 'package:isc_notes/utils/theme_extension.dart';
import 'package:isc_notes/viewmodels/category_manager_viewmodel.dart';
import 'package:isc_notes/viewmodels/home_viewmodel.dart';
import 'package:isc_notes/viewmodels/recycle_bin_viewmodel.dart';
import 'package:isc_notes/views/main_layout.dart';
import 'package:isc_notes/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  bool _showNoteOrCategoryOnly = true;

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<RecycleBinViewModel>(context);

    return MainLayoutView(
      appBar: CustomAppbar(
        title: Text(AppLocalizations.of(context)!.recycleBin),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: Column(
        children: [
          _buildNoteAndCategoryChips(viewModel),
          Expanded(child: _buildList(viewModel)),
        ],
      ),
    );
  }

  Widget _buildNoteAndCategoryChips(RecycleBinViewModel viewModel) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(
            label: AppLocalizations.of(context)!.notes,
            isSelected: _showNoteOrCategoryOnly,
            onSelected: () {
              setState(() {
                _showNoteOrCategoryOnly = true;
              });
            },
            color: Colors.blue,
            iconName: "note",
          ),
          _buildChip(
            label: AppLocalizations.of(context)!.categories,
            isSelected: !_showNoteOrCategoryOnly,
            onSelected: () {
              setState(() {
                _showNoteOrCategoryOnly = false;
              });
            },
            color: Colors.amber,
            iconName: "category",
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? color,
    String? iconName,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: iconName != null
            ? Icon(
                CategoryIcons.icons[iconName],
                size: 18,
                color: isSelected
                    ? color
                    : context.themeValue(
                        light: Colors.grey.shade700,
                        dark: Colors.grey.shade400,
                      ),
              )
            : null,
        label: Text(label),
        onSelected: (_) => onSelected(),
        selectedColor: color?.withOpacity(0.3) ?? Colors.blue.shade200,
        backgroundColor: context.themeValue(
          light: Colors.grey.shade200,
          dark: Colors.grey.shade900,
        ),
        labelStyle: TextStyle(
          color: isSelected
              ? color
              : context.themeValue(
                  light: Colors.grey.shade700,
                  dark: Colors.grey.shade400,
                ),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: isSelected
            ? BorderSide(color: color ?? Colors.black, width: 2)
            : BorderSide.none,
      ),
    );
  }

  Widget _buildList(RecycleBinViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.emptyRecycleBin();
      },
      child: _showNoteOrCategoryOnly
          ? viewModel.notes.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.notFoundNotesInRecycleBin,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: viewModel.notes.length,
                      itemBuilder: (context, index) {
                        final note = viewModel.notes[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              note.title.isEmpty
                                  ? AppLocalizations.of(context)!.untitled
                                  : note.title,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.restore),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.restoreNote,
                                        ),
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.restoreNoteMessage,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => AppNavigator.pop(),
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.cancel,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              AppNavigator.pop(); // Close confirmation dialog
                                              await viewModel.restoreNote(note);

                                              final homeViewModel =
                                                  Provider.of<HomeViewModel>(
                                                    context,
                                                    listen: false,
                                                  );
                                              await homeViewModel.getNotes();
                                            },
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.restore,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_forever),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.deletePermanently,
                                        ),
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.deleteNotePermanentlyMessage,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => AppNavigator.pop(),
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.cancel,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              AppNavigator.pop(); // Close confirmation dialog
                                              await viewModel
                                                  .deleteNotePermanently(note);
                                            },
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.deletePermanently,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              // JSON'dan Document oluştur
                              Document document;
                              try {
                                document = Document.fromJson(
                                  jsonDecode(note.content),
                                );
                              } catch (e) {
                                // Eski formatta metin varsa, düz metin olarak oluştur
                                document = Document()..insert(0, note.content);
                              }
                              final QuillController _quillController =
                                  QuillController(
                                    readOnly: true,
                                    document: document,
                                    selection: const TextSelection.collapsed(
                                      offset: 0,
                                    ),
                                  );

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      note.title.isEmpty
                                          ? AppLocalizations.of(
                                              context,
                                            )!.untitled
                                          : note.title,
                                    ),
                                    content: note.content.isNotEmpty
                                        ? note.isLocked
                                              ? ImageFiltered(
                                                  imageFilter: ImageFilter.blur(
                                                    sigmaX: 3,
                                                    sigmaY: 3,
                                                  ),
                                                  child: AbsorbPointer(
                                                    child: QuillEditor.basic(
                                                      controller:
                                                          _quillController,
                                                      config:
                                                          const QuillEditorConfig(
                                                            padding:
                                                                EdgeInsets.zero,
                                                          ),
                                                    ),
                                                  ),
                                                )
                                              : AbsorbPointer(
                                                  child: QuillEditor.basic(
                                                    controller:
                                                        _quillController,
                                                    config:
                                                        const QuillEditorConfig(
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                  ),
                                                )
                                        : Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.notFoundNoteYet,
                                          ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!.close,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  )
          : viewModel.categories.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.notFoundCategoriesInRecycleBin,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: viewModel.categories.length,
                itemBuilder: (context, index) {
                  final category = viewModel.categories[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    child: ListTile(
                      title: Text(category.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.restoreCategory,
                                  ),
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.restoreCategoryMessage,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => AppNavigator.pop(),
                                      child: Text(
                                        AppLocalizations.of(context)!.cancel,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        AppNavigator.pop(); // Close confirmation dialog
                                        await viewModel.restoreCategory(
                                          category,
                                        );
                                        final homeViewModel =
                                            Provider.of<HomeViewModel>(
                                              context,
                                              listen: false,
                                            );
                                        await homeViewModel.getCategories();
                                        final categoryManagerViewModel =
                                            Provider.of<
                                              CategoryManagerViewModel
                                            >(context, listen: false);
                                        await categoryManagerViewModel
                                            .getCategories();
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.restore,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.deletePermanently,
                                  ),
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.deleteCategoryPermanentlyMessage,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => AppNavigator.pop(),
                                      child: Text(
                                        AppLocalizations.of(context)!.cancel,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        AppNavigator.pop(); // Close confirmation dialog
                                        await viewModel
                                            .deleteCategoryPermanently(
                                              category,
                                            );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.delete,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
