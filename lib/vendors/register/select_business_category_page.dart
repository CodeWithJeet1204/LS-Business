import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/vendors/models/special_categories.dart';
import 'package:find_easy/vendors/register/membership_page.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/image_container.dart';
import 'package:find_easy/widgets/image_text_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SelectBusinessCategoryPage extends StatefulWidget {
  const SelectBusinessCategoryPage({super.key});

  @override
  State<SelectBusinessCategoryPage> createState() =>
      _SelectBusinessCategoryPageState();
}

class _SelectBusinessCategoryPageState
    extends State<SelectBusinessCategoryPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final otherCategoryController = TextEditingController();
  bool isShop = true;
  bool isSaving = false;

  // DISPOSE
  @override
  void dispose() {
    otherCategoryController.dispose();
    super.dispose();
  }

  // SHOW ALL CATEGORY
  Future<void> showCategoryDialog() async {
    await showDialog(
      context: context,
      builder: ((context) => ImageContainer(
            isShop: isShop,
          )),
    );
    setState(() {});
  }

  // UPLOAD DETAILS
  Future<void> uploadDetails() async {
    if (selectedCategory != 'Select Category') {
      if (selectedCategory == 'Other' && otherCategoryController.text.isEmpty) {
        return mySnackBar(context, 'Enter Name of Category');
      } else {
        try {
          await store
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(auth.currentUser!.uid)
              .update({
            'Type': selectedCategory,
          });

          Map<String, String> subCategories =
              specialCategories[selectedCategory]!;

          final CollectionReference specialCategoriesCollection = store
              .collection('Business')
              .doc('Special Categories')
              .collection(selectedCategory);

          subCategories.forEach((subcategoryName, imageUrl) async {
            await specialCategoriesCollection.doc(subcategoryName).set({
              'specialCategoryName': subcategoryName,
              'specialCategoryImageUrl': imageUrl,
              'vendorId': [auth.currentUser!.uid],
            });
          });

          // final subCategoryId = Uuid().v4();
          // final List<List<String>>? subCategories =
          //     commonCategories[selectedCategory];
          // if (subCategories != null) {
          //   for (final subCategory in subCategories) {
          //     await store
          //         .collection('Business')
          //         .doc('Data')
          //         .collection('Category')
          //         .doc(selectedCategory)
          //         .collection(subCategory[0])
          //         .doc(auth.currentUser!.uid)
          //         .set({
          //       'vendorId': auth.currentUser!.uid,
          //       'subCategoryName': subCategory[0],
          //       'categoryId': subCategoryId,
          //       'imageUrl': subCategory[1],
          //       'special': true,
          //     });
          //   }
          // } else {
          //   print('No subcategories found for selected category');
          // }

          if (mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const SelectMembershipPage()),
            );
          }
        } catch (e) {
          if (mounted) {
            return mySnackBar(context, e.toString());
          }
        }
      }
    } else {
      if (mounted) {
        return mySnackBar(context, 'Select Category');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.025,
                  vertical: width * 0.0125,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // HEAD TEXT
                    SizedBox(height: width * 0.1125),
                    const HeadText(
                      text: 'SELECT\nCATEGORY',
                    ),
                    SizedBox(height: width * 0.1125),

                    // SHOP VS HOUSEHOLD
                    Container(
                      width: width,
                      height: 130,
                      decoration: BoxDecoration(
                        color: primary2.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // SHOP
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isShop = true;
                                selectedCategory = 'Select Category';
                              });
                            },
                            child: SizedBox(
                              width: width,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.025,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      overflow: TextOverflow.ellipsis,
                                      'Shop',
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontSize: width * 0.06,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Checkbox(
                                      activeColor: primaryDark,
                                      checkColor: white,
                                      value: isShop,
                                      onChanged: (value) {
                                        setState(() {
                                          isShop = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Divider(),

                          // HOUSEHOLD
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isShop = false;
                                selectedCategory = 'Select Category';
                              });
                            },
                            child: SizedBox(
                              width: width,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.025,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      overflow: TextOverflow.ellipsis,
                                      'Household',
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontSize: width * 0.06,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Checkbox(
                                      activeColor: primaryDark,
                                      checkColor: white,
                                      value: !isShop,
                                      onChanged: (value) {
                                        setState(() {
                                          isShop = !value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: width * 0.025),

                    // SELECT CATEGORY BUTTON
                    GestureDetector(
                      onTap: () async {
                        await showCategoryDialog();
                      },
                      child: Container(
                        width: width,
                        height: width * 0.15,
                        margin: EdgeInsets.symmetric(
                          vertical: width * 0.05,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: width * 0.025,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          selectedCategory,
                          style: TextStyle(
                            color: primaryDark,
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: width * 0.025),

                    // OTHER CATEGORY TEXTFORMFIELD
                    selectedCategory == 'Other'
                        ? MyTextFormField(
                            hintText: 'Other Category Name',
                            controller: otherCategoryController,
                            borderRadius: 12,
                            horizontalPadding: 0,
                            autoFillHints: null,
                          )
                        : Container(),
                    SizedBox(height: width * 0.025),

                    // NEXT BUTTON
                    Padding(
                      padding: EdgeInsets.only(
                        top: width * 0.0225,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: SizedBox(
                        width: width,
                        height: width * 0.15,
                        child: MyButton(
                          text: 'NEXT',
                          onTap: () async {
                            await uploadDetails();
                          },
                          isLoading: isSaving,
                          horizontalPadding: 0,
                        ),
                      ),
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
