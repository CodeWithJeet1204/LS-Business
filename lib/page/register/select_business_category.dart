import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/register/membership.dart';
import 'package:find_easy/utils/colors.dart';
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

  // SHOW ALL CATEGORY
  void showCategoryDialog() async {
    await showDialog(
      context: context,
      builder: ((context) => ImageContainer(
            isShop: isShop,
          )),
    );
    setState(() {});
  }

  @override
  void dispose() {
    otherCategoryController.dispose();
    super.dispose();
  }

  void uploadDetails() async {
    if (selectedCategory != "Select Category") {
      if (selectedCategory == 'Other' && otherCategoryController.text.isEmpty) {
        mySnackBar(context, "Enter Name of Category");
      } else {
        await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid)
            .update({
          'Type': selectedCategory,
        });

        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SelectMembershipPage()),
        );
      }
    } else {
      mySnackBar(context, "Select Category");
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
                    HeadText(text: "SELECT\nCATEGORY"),
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
                                      "Shop",
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
                                      "Household",
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
                      onTap: showCategoryDialog,
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
                            hintText: "Other Category Name",
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
                          text: "NEXT",
                          onTap: uploadDetails,
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
