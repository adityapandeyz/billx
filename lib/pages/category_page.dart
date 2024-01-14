import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../helpers/database_helper.dart';
import '../models/category.dart';
import '../providers/current_firm_provider.dart';
import '../utils/utils.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/green_add_button.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Category>? _itemCategory;
  Exception? _connectionException;
  TextEditingController categoryNameController = TextEditingController();
  TextEditingController categoryCodeController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    categoryNameController.dispose();
    categoryCodeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _connectionFailed(dynamic exception) {
    setState(() {
      _itemCategory = null;
      _connectionException = exception;
    });
  }

  List<Category>? _filteredItemCategory;
  void _loadItemCategories() async {
    try {
      final itemCategories = await DatabaseHelper.instance.getCategories(
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId);
      setState(() {
        _itemCategory = itemCategories;
        _filteredItemCategory = _itemCategory; // Initialize filtered list
      });
    } catch (e) {
      _connectionFailed(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItemCategories();
  }

  Future<void> _createItemCategory(Category itemCategory) async {
    try {
      await DatabaseHelper.instance.createCategory(itemCategory);
      _loadItemCategories();
    } catch (e) {
      _connectionFailed(e);
    }
  }

  Future<void> _deleteItemCategory(id) async {
    try {
      await DatabaseHelper.instance.deleteCategory(id);
      _loadItemCategories();
    } catch (e) {
      _connectionFailed(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firmId =
        Provider.of<CurrentFirmProvider>(context, listen: false).currentFirmId;

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
                // Update the filtered list based on the search input
                setState(() {
                  _filteredItemCategory = _itemCategory!
                      .where((category) =>
                          category.name
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          category.categoryId
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
            const SizedBox(
              width: 10,
            ),
            GreenAddButton(
              function: () {
                addCategory(firmId);
              },
            )
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        _itemCategory == null
            ? noDataIcon()
            : SizedBox(
                height: 650,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredItemCategory!.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: actionColor,
                      margin: const EdgeInsets.all(20),
                      child: ListTile(
                        // onTap: () {
                        //   Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //       builder: (_) => AddItemPage(
                        //         categoryName:
                        //             _itemCategory![index].name.toString(),
                        //         categoryCode: _itemCategory![index].id.toString(),
                        //         // firmId: firmInfo!.toString()
                        //       ),
                        //     ),
                        //   );
                        // },
                        leading: const SizedBox(
                          width: 60,
                          child: Icon(
                            FontAwesomeIcons.box,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          _filteredItemCategory![index].name.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          _filteredItemCategory![index].categoryId.toString(),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            var itemCatogoryIndex =
                                _filteredItemCategory![index];

                            setState(() {
                              _filteredItemCategory!.remove(itemCatogoryIndex);
                            });

                            _deleteItemCategory(itemCatogoryIndex);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
        const Spacer(),
      ],
    );
  }

  addCategory(firmId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextfield(
                label: 'Category Name',
                controller: categoryNameController,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextfield(
                label: 'Category Code (Alphanumeric)',
                controller: categoryCodeController,
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

                categoryCodeController.clear();
                categoryNameController.clear();
              },
            ),
            ElevatedButton(
              child: const Text(
                "OK",
              ),
              onPressed: () async {
                Navigator.pop(context);

                if (categoryNameController.text.isEmpty ||
                    categoryCodeController.text.isEmpty) {
                  return;
                }

                try {
                  var itemCategory = Category(
                    name: categoryNameController.text.trim(),
                    categoryId:
                        categoryCodeController.text.trim().toLowerCase(),
                    firmId: firmId.toString(),
                  );
                  _itemCategory!.add(itemCategory);
                  _createItemCategory(itemCategory);
                  categoryCodeController.clear();
                  categoryNameController.clear();
                } catch (e) {
                  showAlert(
                    context,
                    e.toString(),
                  );

                  return;
                }
                showAlert(
                  context,
                  'Category Added to Database!',
                );
              },
            ),
          ],
        );
      },
    );
  }
}
