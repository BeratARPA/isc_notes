import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:isc_notes/l10n/app_localizations.dart';
import 'package:isc_notes/models/category_model.dart';
import 'package:isc_notes/utils/app_navigator.dart';
import 'package:isc_notes/utils/category_icons.dart';
import 'package:isc_notes/viewmodels/category_manager_viewmodel.dart';
import 'package:isc_notes/viewmodels/home_viewmodel.dart';
import 'package:isc_notes/viewmodels/recycle_bin_viewmodel.dart';
import 'package:isc_notes/views/main_layout.dart';
import 'package:isc_notes/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class CategoryManagerScreen extends StatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends State<CategoryManagerScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CategoryManagerViewModel>(context);

    return MainLayoutView(
      appBar: CustomAppbar(
        title: Text(AppLocalizations.of(context)!.categories),
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
      body: viewModel.categories.isEmpty
          ? Center(
              child: Text(AppLocalizations.of(context)!.notFoundCategories),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await viewModel.getCategories();
              },
              child: ReorderableListView.builder(
                onReorder: (oldIndex, newIndex) async {
                  await viewModel.reorderCategories(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final category = viewModel.categories[index];
                  return Card(
                    key: ValueKey(category.id),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Color(
                          int.parse(
                            category.colorHex.replaceFirst('#', '0xff'),
                          ),
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(
                          int.parse(
                            category.colorHex.replaceFirst('#', '0xff'),
                          ),
                        ),
                        child: Icon(
                          CategoryIcons.icons[category.iconName] ??
                              Icons.category,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(category.name),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                      onTap: () =>
                          _showAddCategoryDialog(editCategory: category),
                      onLongPress: () =>
                          _showCategoryOptions(context, category),
                    ),
                  );
                },
                itemCount: viewModel.categories.length,
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.of(context)!.newCategory),
      ),
    );
  }

  void _showCategoryOptions(BuildContext context, CategoryModel category) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(title: Text(category.name)),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(AppLocalizations.of(context)!.delete),
              onTap: () async {
                final viewModel = Provider.of<CategoryManagerViewModel>(
                  context,
                  listen: false,
                );
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.deleteCategory),
                    content: Text(
                      AppLocalizations.of(context)!.deleteCategoryMessage,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => AppNavigator.pop(),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          AppNavigator.pop();
                          AppNavigator.pop();
                          await viewModel.deleteCategory(category.id!);

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

  void _showAddCategoryDialog({CategoryModel? editCategory}) {
    final isEdit = editCategory != null;

    final nameController = TextEditingController(
      text: editCategory?.name ?? "",
    );
    String? selectedIconKey = editCategory?.iconName;
    Color selectedColor = editCategory != null
        ? Color(
            int.parse(editCategory.colorHex.replaceFirst('#', ''), radix: 16),
          )
        : Colors.deepOrange;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEdit
                    ? AppLocalizations.of(context)!.editCategory
                    : AppLocalizations.of(context)!.newCategory,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.categoryName,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: CategoryIcons.icons.entries.map((entry) {
                        final isSelected = selectedIconKey == entry.key;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedIconKey = entry.key),
                          child: CircleAvatar(
                            radius: isSelected ? 26 : 22,
                            backgroundColor: isSelected
                                ? Colors.blue
                                : Colors.grey.shade300,
                            child: Icon(
                              entry.value,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(
                              AppLocalizations.of(context)!.selectColor,
                            ),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: selectedColor,
                                onColorChanged: (c) =>
                                    setState(() => selectedColor = c),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => AppNavigator.pop(),
                                child: Text(AppLocalizations.of(context)!.okey),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        height: 42,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => AppNavigator.pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        selectedIconKey == null) {
                      return;
                    }

                    final viewModel = Provider.of<CategoryManagerViewModel>(
                      context,
                      listen: false,
                    );
                    await viewModel.saveCategory(
                      editCategory?.id,
                      nameController.text,
                      selectedIconKey!,
                      selectedColor.value.toRadixString(16).padLeft(8, '0'),
                    );

                    final recycleBinViewModel = Provider.of<HomeViewModel>(
                      context,
                      listen: false,
                    );
                    await recycleBinViewModel.getCategories();

                    AppNavigator.pop();
                  },
                  child: Text(
                    isEdit
                        ? AppLocalizations.of(context)!.save
                        : AppLocalizations.of(context)!.add,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
