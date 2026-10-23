import 'package:flutter/material.dart';
import 'package:isc_notes/l10n/app_localizations.dart';
import 'package:isc_notes/models/note_model.dart';
import 'package:isc_notes/utils/app_navigator.dart';
import 'package:isc_notes/utils/category_icons.dart';
import 'package:isc_notes/utils/theme_extension.dart';
import 'package:isc_notes/viewmodels/home_viewmodel.dart';
import 'package:isc_notes/viewmodels/recycle_bin_viewmodel.dart';
import 'package:isc_notes/views/main_layout.dart';
import 'package:isc_notes/widgets/custom_appbar.dart';
import 'package:isc_notes/widgets/notecard.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  int? _selectedCategoryId;
  bool _showPinnedOnly = false;
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return MainLayoutView(
      appBar: CustomAppbar(
        title: Text(AppLocalizations.of(context)!.notes),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
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
          _buildCategoryChips(viewModel),
          Expanded(child: _buildNotesList(viewModel)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppNavigator.pushNamed('/noteEditor');
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.of(context)!.newNote),
      ),
    );
  }

  Widget _buildCategoryChips(HomeViewModel viewModel) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(
            label: AppLocalizations.of(context)!.all,
            isSelected: _selectedCategoryId == null && !_showPinnedOnly,
            onSelected: () {
              setState(() {
                _selectedCategoryId = null;
                _showPinnedOnly = false;
              });
            },
            color: Colors.blue,
            iconName: "done",
          ),
          _buildChip(
            label: AppLocalizations.of(context)!.pinned,
            isSelected: _showPinnedOnly,
            onSelected: () {
              setState(() {
                _showPinnedOnly = !_showPinnedOnly;
                if (_showPinnedOnly) {
                  _selectedCategoryId = null;
                }
              });
            },
            color: Colors.amber,
            iconName: "pin",
          ),
          ...viewModel.categories.map(
            (category) => _buildChip(
              label: category.name,
              color: Color(
                int.parse(category.colorHex.replaceFirst('#', '0xff')),
              ),
              iconName: category.iconName,
              isSelected:
                  _selectedCategoryId == category.id && !_showPinnedOnly,
              onSelected: () {
                setState(() {
                  _selectedCategoryId = category.id;
                  _showPinnedOnly = false;
                });
              },
            ),
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

  Widget _buildNotesList(HomeViewModel viewModel) {
    // Önce sabitleme filtresini uygula
    var allNotes = viewModel.notes;
    if (_showPinnedOnly) {
      allNotes = allNotes.where((note) => note.isPinned).toList();
    } else if (_selectedCategoryId != null) {
      // Kategori filtresini uygula (sadece sabitleme aktif değilse)
      allNotes = allNotes
          .where((note) => note.categoryId == _selectedCategoryId)
          .toList();
    } // Arama filtresi uygula
    final notes = allNotes
        .where(
          (n) =>
              n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              n.content.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
    String emptyMessage;
    if (_showPinnedOnly) {
      emptyMessage = AppLocalizations.of(context)!.notFoundPinnedNotes;
    } else if (_selectedCategoryId != null) {
      emptyMessage = AppLocalizations.of(context)!.notFoundSelectedCategory;
    } else {
      emptyMessage = AppLocalizations.of(context)!.notFoundNoteYet;
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: notes.isEmpty
          ? Center(child: Text(emptyMessage, style: TextStyle(fontSize: 16)))
          : RefreshIndicator(
              onRefresh: () async {
                await viewModel.getNotes();
                await viewModel.getCategories();
              },
              child: _isGridView
                  ? GridView.builder(
                      itemCount: notes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 0.8,
                          ),
                      itemBuilder: (context, index) {
                        return _buildNoteItem(
                          notes[index],
                          viewModel,
                          isGrid: true,
                        );
                      },
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        return _buildNoteItem(
                          notes[index],
                          viewModel,
                          isGrid: false,
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildNoteItem(
    NoteModel note,
    HomeViewModel viewModel, {
    required bool isGrid,
  }) {
    final category = viewModel.getCategoryById(note.categoryId);
    final noteCard = NoteCard(
      note: note,
      category: category,
      onTap: () async {
        if (note.isLocked) {
          _showLockDialog(context, note, viewModel, isLogin: true);
          return;
        }
        await AppNavigator.pushNamed('/noteEditor', arguments: note);
      },
      onLongPress: () => _showNoteOptions(context, note, viewModel),
    );
    if (isGrid) {
      return noteCard;
    } else {
      return SizedBox(height: 130, child: noteCard);
    }
  }

  void _showLockDialog(
    BuildContext context,
    NoteModel note,
    HomeViewModel viewModel, {
    bool isLogin = false,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            note.isLocked
                ? AppLocalizations.of(context)!.unlockNote
                : AppLocalizations.of(context)!.lockNote,
          ),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enterPassword,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => AppNavigator.pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (isLogin) {
                  if (note.password == controller.text) {
                    AppNavigator.pop(); // Close the dialog
                    await AppNavigator.pushNamed(
                      '/noteEditor',
                      arguments: note,
                    );
                    return;
                  } else {
                    // Show error
                    AppNavigator.showSnack(
                      AppLocalizations.of(context)!.incorrectPassword,
                    );
                    AppNavigator.pop();
                    return;
                  }
                }
                if (await viewModel.toggleLock(note, controller.text)) {
                  AppNavigator.pop();
                }
              },
              child: Text(
                note.isLocked
                    ? AppLocalizations.of(context)!.unlock
                    : AppLocalizations.of(context)!.lock,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    final controller = TextEditingController(text: _searchQuery);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.searchNotes),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.titleOrContent,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              AppNavigator.pop();
            },
            child: Text(AppLocalizations.of(context)!.clear),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _searchQuery = controller.text);
              AppNavigator.pop();
            },
            child: Text(AppLocalizations.of(context)!.search),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    NoteModel note,
    HomeViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.assignCategory),
          content: viewModel.categories.isEmpty
              ? Text(AppLocalizations.of(context)!.notFoundCategories)
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: viewModel.categories.length,
                    itemBuilder: (context, index) {
                      final category = viewModel.categories[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(
                            int.parse(
                              category.colorHex.replaceFirst('#', ''),
                              radix: 16,
                            ),
                          ),
                          child: Icon(CategoryIcons.icons[category.iconName]),
                        ),
                        title: Text(category.name),
                        onTap: () {
                          AppNavigator.pop();
                          AppNavigator.pop();
                          viewModel.assignCategory(note, category);
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => AppNavigator.pop(),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        );
      },
    );
  }

  // 🔧 Uzun basıldığında seçenek menüsü
  void _showNoteOptions(
    BuildContext context,
    NoteModel note,
    HomeViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              title: Text(
                note.title.isNotEmpty
                    ? note.title
                    : AppLocalizations.of(context)!.untitled,
              ),
            ),
            ListTile(
              leading: Icon(
                note.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
              ),
              title: Text(
                note.isPinned
                    ? AppLocalizations.of(context)!.unpinNote
                    : AppLocalizations.of(context)!.pinNote,
              ),
              onTap: () async {
                AppNavigator.pop();
                await viewModel.togglePin(note);
              },
            ),
            ListTile(
              leading: Icon(
                note.isLocked
                    ? Icons.lock_open_rounded
                    : Icons.lock_outline_rounded,
              ),
              title: Text(
                note.isLocked
                    ? AppLocalizations.of(context)!.unlockNote
                    : AppLocalizations.of(context)!.lockNote,
              ),
              onTap: () async {
                AppNavigator.pop();
                _showLockDialog(context, note, viewModel);
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text(AppLocalizations.of(context)!.assignCategory),
              onTap: () async {
                _showCategoryDialog(context, note, viewModel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(AppLocalizations.of(context)!.delete),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.deleteNote),
                    content: Text(
                      AppLocalizations.of(context)!.deleteNoteMessage,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => AppNavigator.pop(),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          AppNavigator.pop(); // Close confirmation dialog
                          AppNavigator.pop(); // Close bottom sheet
                          await viewModel.deleteNote(note);

                          final recycleBinViewModel =
                              Provider.of<RecycleBinViewModel>(
                                context,
                                listen: false,
                              );
                          await recycleBinViewModel.emptyRecycleBin();
                        },
                        child: Text(AppLocalizations.of(context)!.delete),
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
  }
}
