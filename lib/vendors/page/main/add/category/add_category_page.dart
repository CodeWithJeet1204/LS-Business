import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/add/category/select_products_for_category_page.dart';
import 'package:localy/vendors/provider/products_added_to_category_provider.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/image_pick_dialog.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_button.dart';
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
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final GlobalKey<FormState> categoryKey = GlobalKey<FormState>();
  final TextEditingController categoryController = TextEditingController();
  bool isSaving = false;
  File? _image;
  bool isFit = false;
  String? imageUrl;

  @override
  void dispose() {
    categoryController.dispose();
    super.dispose();
  }

  // ADD CATEGORY
  Future<void> addCategory(
      String categoryName, ProductAddedToCategory categoryProvider) async {
    if (categoryKey.currentState!.validate()) {
      bool categoryDoesntExists = true;
      final previousProducts = await store
          .collection('Business')
          .doc('Data')
          .collection('Category')
          .where('vendorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      for (QueryDocumentSnapshot doc in previousProducts.docs) {
        if (doc['categoryName'] == categoryController.text.toString()) {
          if (mounted) {
            mySnackBar(
              context,
              'Category with same name already exists',
            );
          }
          categoryDoesntExists = false;
        }
      }

      if (categoryDoesntExists) {
        if (_image != null) {
          setState(() {
            isSaving = true;
          });
          try {
            final String categoryId = const Uuid().v4();

            Reference ref = FirebaseStorage.instance
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
              'special': false,
            });

            for (var element in categoryProvider.selectedProducts) {
              store
                  .collection('Business')
                  .doc('Data')
                  .collection('Products')
                  .doc(element)
                  .update({
                'categoryName': categoryName,
                'categoryId': categoryId,
              });
            }
            await _image!.delete();
            categoryProvider.clearProducts();
            if (mounted) {
              mySnackBar(context, 'Category Added');
              Navigator.of(context).pop();
            }
          } catch (e) {
            if (mounted) {
              mySnackBar(context, e.toString());
            }
          }
          setState(() {
            isSaving = false;
          });
        } else {
          if (mounted) {
            mySnackBar(context, 'Select an Image');
          }
        }
      }
    }
  }

  // SELECT CATEGORY IMAGE
  Future<void> selectImage() async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      setState(() {
        _image = (File(im.path));
      });
    } else {
      if (mounted) {
        mySnackBar(context, 'Select an Image');
      }
    }
  }

  // REMOVE CATEGORY IMAGE
  void removeImage() {
    setState(() {
      _image = null;
    });
  }

  // ADD PRODUCT TO CATEGORY
  void addProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => const SelectProductsForCategoryPage(
              fromAddCategoryPage: true,
            )),
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
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'ADD CATEGORY',
        ),
        actions: [
          MyTextButton(
            onPressed: () async {
              await addCategory(
                categoryController.text.toString(),
                productsAddedToCategoryProvider,
              );
            },
            text: 'DONE',
            textColor: primaryDark2,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            isSaving ? 10 : 0,
          ),
          child: isSaving ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // IMAGE
                    _image != null
                        ? Center(
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  height: width * 0.8725,
                                  width: width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: primaryDark,
                                      width: 2,
                                    ),
                                  ),
                                  child: InteractiveViewer(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Image(
                                        image: FileImage(_image!),
                                        fit: isFit ? BoxFit.cover : null,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // CHANGE IMAGE
                                    Padding(
                                      padding: EdgeInsets.all(width * 0.0125),
                                      child: IconButton.filledTonal(
                                        onPressed: () async {
                                          await selectImage();
                                        },
                                        icon: Icon(
                                          FeatherIcons.camera,
                                          size: width * 0.1125,
                                        ),
                                        tooltip: 'Change Image',
                                      ),
                                    ),
                                    // REMOVE IMAGE
                                    Padding(
                                      padding: EdgeInsets.all(width * 0.0125),
                                      child: IconButton.filledTonal(
                                        onPressed: removeImage,
                                        icon: Icon(
                                          FeatherIcons.x,
                                          size: width * 0.1125,
                                        ),
                                        tooltip: 'Remove Image',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : SizedOverflowBox(
                            size: Size(width, width * 0.9),
                            child: InkWell(
                              onTap: () async {
                                await selectImage();
                              },
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                width: width,
                                height: width * 0.9,
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
                                    Icon(
                                      FeatherIcons.upload,
                                      size: width * 0.33,
                                    ),
                                    SizedBox(height: width * 0.1125),
                                    Text(
                                      overflow: TextOverflow.ellipsis,
                                      'Select Image',
                                      style: TextStyle(
                                        fontSize: width * 0.08,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    Form(
                      key: categoryKey,
                      // NAME
                      child: TextFormField(
                        controller: categoryController,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        autofillHints: null,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Category Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            return null;
                          } else {
                            return 'Enter Category Name';
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ADD PRODUCTS
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: MyButton(
                        text:
                            'Add Products - ${productsAddedToCategoryProvider.selectedProducts.length}',
                        onTap: addProduct,
                        isLoading: false,
                        horizontalPadding: 0,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
