import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/current_firm_provider.dart';
import '../providers/category_provider.dart'; // Import CategoryProvider
import '../providers/items_provider.dart';
import '../utils/utils.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/delete_icon_button.dart';
import '../widgets/green_add_button.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  TextEditingController categoryNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    categoryNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firmId =
        Provider.of<CurrentFirmProvider>(context, listen: false).currentFirmId;

    Provider.of<CategoryProvider>(context, listen: false)
        .loadItemCategories(context);

    return CustomPage(
      onClose: () {
        Navigator.of(context).pop();
      },
      title: 'Categories',
      widget: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextfield(
              label: 'Search Category',
              controller: _searchController,
              onChanged: (value) {
                Provider.of<CategoryProvider>(context, listen: false)
                    .filterCategories(context, value);
              },
            ),
            const SizedBox(
              width: 10,
            ),
            GreenAddButton(
              function: () {
                addCategory(firmId,
                    Provider.of<CategoryProvider>(context, listen: false));
              },
            )
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Consumer<CategoryProvider>(builder: (context, categoryProvider, _) {
          final filteredItems = categoryProvider.filteredItemCategory;

          filteredItems?.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

          return (filteredItems == null || filteredItems.isEmpty)
              ? noDataIcon()
              : SizedBox(
                  height: 650,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredItems.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        color: actionColor,
                        margin: const EdgeInsets.all(20),
                        child: ListTile(
                          leading: const SizedBox(
                            width: 60,
                            child: Icon(
                              FontAwesomeIcons.box,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            filteredItems[index].name.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            filteredItems[index].categoryId.toString(),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: EditCategory(
                                      categoryName: filteredItems[index].name,
                                      categoryId:
                                          filteredItems[index].categoryId,
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              FontAwesomeIcons.edit,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
        }),
        const Spacer(),
      ],
    );
  }

  addCategory(firmId, CategoryProvider categoryProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextfield(
                label: 'Category Name (Alphanumeric)',
                controller: categoryNameController,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
              ),
              onPressed: () {
                Navigator.pop(context);
                categoryNameController.clear();
              },
            ),
            ElevatedButton(
              child: const Text(
                "Add",
              ),
              onPressed: () async {
                Navigator.pop(context);

                if (categoryNameController.text.isEmpty) {
                  return;
                }

                try {
                  var categoryCode =
                      '${categoryNameController.text.trim().replaceAll(RegExp(r'\s+'), '')}c${categoryProvider.itemCategories!.length + 1} ';
                  var name = categoryNameController.text
                      .trim()
                      .replaceAll(RegExp(r'\s+'), '')
                      .toLowerCase();

                  for (var cat in categoryProvider.itemCategoryList!) {
                    if (cat.name
                            .trim()
                            .replaceAll(RegExp(r'\s+'), '')
                            .toLowerCase() ==
                        name) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Category already exist!'),
                        ),
                      );
                      categoryNameController.clear();
                      return;
                    }
                  }

                  var itemCategory = Category(
                    name: categoryNameController.text.trim(),
                    categoryId: categoryCode.toString().toLowerCase().trim(),
                    firmId: firmId.toString(),
                  );

                  categoryProvider.createItemCategory(itemCategory, context);
                  categoryNameController.clear();
                } catch (e) {
                  showAlert(
                    context,
                    e.toString(),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category added to database.'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class EditCategory extends StatefulWidget {
  String categoryName;
  String categoryId;
  EditCategory({
    Key? key,
    required this.categoryName,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  TextEditingController categoryNameController = TextEditingController();

  TextEditingController categoryIdController = TextEditingController();

  String _selectedCategory = '';
  String firmdId = '';

  @override
  void dispose() {
    categoryNameController.dispose();
    categoryIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    firmdId = Provider.of<CurrentFirmProvider>(context).currentFirmId;
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return SizedBox(
      width: 600,
      height: 380,
      child: AlertDialog(
        title: const Text('Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextfield(
              label: 'Name: ${widget.categoryName}',
              controller: categoryNameController,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextfield(
              label: 'Id: ${widget.categoryId}',
              controller: categoryIdController,
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Category? existingCategory = await categoryProvider
                    .getCategoryWithId(widget.categoryId, context);

                if (existingCategory != null) {
                  existingCategory.name = categoryNameController.text.isEmpty
                      ? existingCategory.name
                      : categoryNameController.text;

                  existingCategory.categoryId =
                      categoryIdController.text.isEmpty
                          ? existingCategory.categoryId
                          : categoryIdController.text;
                  categoryProvider.updateCategory(existingCategory, context);
                } else {
                  showDownAlert(context,
                      'Category with ID ${widget.categoryId} not found.');
                }
                Navigator.of(context).pop();
                showDownAlert(context, 'Category updated.');
              } catch (e) {
                print(e);
                return;
              }
            },
            child: const Text('Update'),
          )
        ],
      ),
    );
  }
}
