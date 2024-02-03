import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/add/category/category_products_add_page.dart';
import 'package:find_easy/provider/products_added_to_category_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({
    super.key,
  });

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController categoryController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final GlobalKey<FormState> categoryKey = GlobalKey<FormState>();
  bool isSaving = false;
  File? _image;
  bool isFit = true;
  String? imageUrl;

  void addCategory(
      String categoryName, ProductAddedToCategory categoryProvider) async {
    if (categoryKey.currentState!.validate()) {
      if (_image != null) {
        setState(() {
          isSaving = true;
        });
        try {
          final String categoryId = Uuid().v4();

          Reference ref = await FirebaseStorage.instance
              .ref()
              .child('Data/Categories')
              .child(categoryId);
          await ref.putFile(_image!).whenComplete(() async {
            await ref.getDownloadURL().then((value) {
              setState(() {
                imageUrl = value;
              });
            });
          });

          await store
              .collection('Business')
              .doc('Data')
              .collection('Category')
              .doc(categoryId)
              .set({
            'categoryName': categoryName,
            'categoryId': categoryId,
            'imageUrl': imageUrl,
            'datetime': Timestamp.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch,
            ),
            'vendorId': auth.currentUser!.uid,
          });

          categoryProvider.selectedProducts.forEach((element) {
            store
                .collection('Business')
                .doc('Data')
                .collection('Products')
                .doc(element)
                .update({
              'categoryName': categoryName,
              'categoryId': categoryId,
            });
          });
          categoryProvider.clearProducts();
          if (context.mounted) {
            mySnackBar(context, "Added");
            Navigator.of(context).pop();
          }
        } catch (e) {
          if (context.mounted) {
            mySnackBar(context, e.toString());
          }
        }
        setState(() {
          isSaving = false;
        });
      } else {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  void selectImage() async {
    final XFile? im =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (im != null) {
      setState(() {
        _image = (File(im.path));
      });
    } else {
      if (context.mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  void removeImage() {
    setState(() {
      _image = null;
    });
  }

  void addProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => AddProductsToCategoryPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAddedToCategoryProvider =
        Provider.of<ProductAddedToCategory>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("ADD CATEGORY"),
        actions: [
          IconButton(
            onPressed: () {
              addCategory(
                categoryController.text.toString(),
                productsAddedToCategoryProvider,
              );
            },
            icon: Icon(Icons.ios_share),
            tooltip: "Add Category",
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            isSaving ? 10 : 0,
          ),
          child: isSaving ? LinearProgressIndicator() : Container(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;
              double height = constraints.maxHeight;
              return Column(
                children: [
                  _image != null
                      ? Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                height: 300,
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: primaryDark,
                                    width: 3,
                                  ),
                                ),
                                child: InteractiveViewer(
                                  child: Image(
                                    image: FileImage(_image!),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: IconButton.filledTonal(
                                    onPressed: removeImage,
                                    icon: const Icon(
                                      Icons.highlight_remove_rounded,
                                      size: 40,
                                    ),
                                    tooltip: "Remove Image",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedOverflowBox(
                          size: Size(width, height * 0.4),
                          child: Container(
                            width: width,
                            height: height * 0.4,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: primaryDark,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: selectImage,
                                  icon: const Icon(
                                    Icons.arrow_circle_up_rounded,
                                    size: 120,
                                  ),
                                ),
                                SizedBox(height: height * 0.05),
                                const Text(
                                  "Select Image",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Form(
                    key: categoryKey,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: TextFormField(
                        controller: categoryController,
                        autofillHints: null,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: "Category Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            return null;
                          } else {
                            return "Enter Category Name";
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: MyButton(
                      text:
                          "Add Products (${productsAddedToCategoryProvider.selectedProducts.length})",
                      onTap: addProduct,
                      isLoading: false,
                      horizontalPadding: 0,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
