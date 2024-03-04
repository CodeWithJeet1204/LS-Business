import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/page/main/add/brand/select_products_for_brand_page.dart';
import 'package:find_easy/provider/products_added_to_brand.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/image_pick_dialog.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddBrandPage extends StatefulWidget {
  const AddBrandPage({super.key});

  @override
  State<AddBrandPage> createState() => _AddBrandPageState();
}

class _AddBrandPageState extends State<AddBrandPage> {
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final brandKey = GlobalKey<FormState>();
  final brandNameController = TextEditingController();
  bool isSaving = false;
  bool isFit = false;
  File? _image;
  String? imageUrl;

  // DISPOSE
  @override
  void dispose() {
    brandNameController.dispose();
    super.dispose();
  }

  // REMOVE CATEGORY IMAGE
  void removeImage() {
    setState(() {
      _image = null;
    });
  }

  // SELECT CATEGORY IMAGE
  void selectImage() async {
    final XFile? im = await showImagePickDialog(context);
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

  void addBrand(ProductAddedToBrandProvider provider) async {
    if (brandKey.currentState!.validate()) {
      try {
        setState(() {
          isSaving = true;
        });
        final String brandId = const Uuid().v4();
        if (_image != null) {
          Reference ref = storage.ref().child('Data/Brand').child(brandId);

          await ref.putFile(_image!).whenComplete(() async {
            await ref.getDownloadURL().then((value) {
              setState(() {
                imageUrl = value;
              });
            });
          });
        }

        await store
            .collection('Business')
            .doc('Data')
            .collection('Brands')
            .doc(brandId)
            .set({
          'brandId': brandId,
          'brandName': brandNameController.text.toString(),
          'imageUrl': imageUrl,
          'vendorId': FirebaseAuth.instance.currentUser!.uid,
        });
        if (context.mounted) {
          mySnackBar(context, "Brand Added");
        }

        for (String id in provider.selectedProducts) {
          await store
              .collection('Business')
              .doc('Data')
              .collection('Products')
              .doc(id)
              .update({
            'productBrandId': brandId,
            'productBrand': brandNameController.text..toString(),
          });
        }

        provider.clearProducts();
        setState(() {
          isSaving = false;
        });
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          isSaving = false;
        });
        if (context.mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAddedToBrandProvider =
        Provider.of<ProductAddedToBrandProvider>(context);

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          "ADD BRAND",
        ),
        actions: [
          MyTextButton(
            onPressed: () {
              addBrand(productsAddedToBrandProvider);
            },
            text: "DONE",
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            final double width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Form(
                key: brandKey,
                child: Column(
                  children: [
                    // IMAGE
                    _image != null
                        ? Center(
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                // NOT NULL
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
                                // ICONS
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Padding(
                                    //   padding: EdgeInsets.all(width * 0.0125),
                                    //   child: IconButton.filledTonal(
                                    //     onPressed: selectImage,
                                    //     icon: Icon(
                                    //       FeatherIcons.camera,
                                    //       size: width * 0.1125,
                                    //     ),
                                    //     tooltip: "Change Image",
                                    //   ),
                                    // ),
                                    // REMOVE IMAGE
                                    Padding(
                                      padding: EdgeInsets.all(width * 0.0125),
                                      child: IconButton.filledTonal(
                                        onPressed: removeImage,
                                        icon: Icon(
                                          FeatherIcons.x,
                                          size: width * 0.1125,
                                        ),
                                        tooltip: "Remove Image",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : SizedOverflowBox(
                            size: Size(width, width * 0.9),
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
                                  IconButton(
                                    onPressed: selectImage,
                                    icon: Icon(
                                      FeatherIcons.upload,
                                      size: width * 0.33,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    overflow: TextOverflow.ellipsis,
                                    "Select Image",
                                    style: TextStyle(
                                      fontSize: width * 0.08,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // NAME
                    MyTextFormField(
                      hintText: "Brand Name",
                      controller: brandNameController,
                      borderRadius: 12,
                      horizontalPadding: 0,
                      autoFillHints: null,
                    ),

                    // ADD PRODUCTS
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: MyButton(
                        text:
                            "Add Products (${productsAddedToBrandProvider.selectedProducts.length})",
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) =>
                                  const AddProductsToBrandPage()),
                            ),
                          );
                        },
                        isLoading: false,
                        horizontalPadding: 0,
                        verticalPadding: width * 0.05,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
