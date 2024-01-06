import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/image_container.dart';
import 'package:find_easy/widgets/image_text_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final postKey = GlobalKey<FormState>();
  final TextEditingController categoryNameController = TextEditingController();
  bool isPosting = false;

  void showCategoryDialog() async {
    await showDialog(
      context: context,
      builder: ((context) => const ImageContainer()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: Text("Add Post"),
        actions: [
          IconButton(
            onPressed: () {
              if (postKey.currentState!.validate()) {
                setState(() {
                  isPosting = true;
                });
              }
            },
            icon: Icon(
              Icons.ios_share_rounded,
              size: 24,
            ),
            tooltip: "Post",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isPosting ? LinearProgressIndicator() : Container(),
                SizedOverflowBox(
                  size: Size(width, height * 0.4),
                  child: Container(
                    width: width,
                    height: height * 0.4,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryDark,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (postKey.currentState!.validate()) {}
                          },
                          icon: Icon(
                            Icons.arrow_circle_up_rounded,
                            size: 120,
                          ),
                        ),
                        SizedBox(height: height * 0.05),
                        Text(
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
                SizedBox(height: height * 0.05),
                Form(
                  key: postKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Product Name",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: primaryDark2,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != null) {
                            if (value.length < 20 && value.length > 0) {
                              return null;
                            } else {
                              return "20 characters max.";
                            }
                          } else {
                            return "Enter name";
                          }
                        },
                      ),
                      SizedBox(height: height * 0.025),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Price (Optional)",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: primaryDark2,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.0125),
                      Divider(),
                      SizedBox(height: height * 0.0125),
                      GestureDetector(
                        onTap: showCategoryDialog,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: primary2,
                          ),
                          child: Text(
                            selectedCategory,
                            style: const TextStyle(
                              color: primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      selectedCategory == "Other"
                          ? Column(
                              children: [
                                SizedBox(height: height * 0.015),
                                TextFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    hintText: "Category Name",
                                  ),
                                  controller: categoryNameController,
                                  validator: (value) {
                                    if (value != null) {
                                      if (value.isNotEmpty) {
                                        return null;
                                      } else {
                                        return "Enter Category Name";
                                      }
                                    } else {
                                      return "Enter Category Name";
                                    }
                                  },
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
