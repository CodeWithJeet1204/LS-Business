// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/firebase/storage_methods.dart';
import 'package:find_easy/page/main/add/add_product_page_2.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddProductPage1 extends StatefulWidget {
  const AddProductPage1({super.key});

  @override
  State<AddProductPage1> createState() => _AddProductPage1State();
}

class _AddProductPage1State extends State<AddProductPage1> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = StorageMethods();
  final fireStorage = FirebaseStorage.instance;
  final productKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController otherInfoController = TextEditingController();
  final TextEditingController otherInfoValueController =
      TextEditingController();
  bool isAddingProduct = false;
  final List<File> _image = [];
  int currentImageIndex = 0;
  String? selectedCategory;
  String? selectedCategoryId;
  final List<String> _imageDownloadUrl = [];
  final ImagePicker picker = ImagePicker();
  List<String> otherInfoList = [];
  bool isFit = true;
  final Map<String, String> categoryNamesAndIds = {};

  void addProductImages() async {
    final XFile? im = await picker.pickImage(source: ImageSource.gallery);
    if (im != null) {
      setState(() {
        _image.add(File(im.path));
      });
    } else {
      if (context.mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  void removeProductImages(int index) {
    setState(() {
      _image.removeAt(index);
    });
  }

  void addProduct() async {
    if (productKey.currentState!.validate()) {
      if (_image.isEmpty) {
        return mySnackBar(context, "Select atleast 1 image");
      }
      if (selectedCategory == null) {
        return mySnackBar(context, "Select Category");
      }
      if (priceController.text.toString().length > 10) {
        return mySnackBar(context, "Max Price is 100 Cr.");
      }
      if (priceController.text.toString().isNotEmpty &&
          priceController.text.toString() != null) {
        if (double.parse(priceController.text.toString()) <= 0.999) {
          return mySnackBar(context, "Min Price is 1 Rs.");
        }
      }
      try {
        setState(() {
          isAddingProduct = true;
        });
        for (File img in _image) {
          try {
            Reference ref = fireStorage
                .ref()
                .child('Data/Products')
                .child(const Uuid().v4());
            await ref.putFile(img).whenComplete(() async {
              await ref.getDownloadURL().then((value) {
                setState(() {
                  _imageDownloadUrl.add(value);
                });
              });
            });
          } catch (e) {
            if (context.mounted) {
              mySnackBar(context, e.toString());
            }
          }
        }
        final String productId = const Uuid().v4();
        await store
            .collection('Business')
            .doc('Data')
            .collection('Products')
            .doc(productId)
            .set({
          'productName': nameController.text,
          'productPrice': priceController.text,
          'productDescription': descriptionController.text,
          'productBrand': brandController.text,
          'productId': productId,
          'images': _imageDownloadUrl,
          'datetime': Timestamp.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch,
          ),
          'categoryName': selectedCategory,
          'categoryId': selectedCategoryId,
          'vendorId': FirebaseAuth.instance.currentUser!.uid,
        });
        setState(() {
          isAddingProduct = false;
        });
        if (context.mounted) {
          mySnackBar(context, "Basic Info Added");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: ((context) => AddProductPage2(productId: productId)),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        setState(() {
          isAddingProduct = false;
        });
        if (context.mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  void addOtherInfo(String tag) {
    if (tag.length > 1) {
      setState(() {
        otherInfoList.add(tag);
      });
    } else {
      mySnackBar(context, "Tag should be atleast 2 chars long");
    }
  }

  void removeOtherInfo(int index) {
    setState(() {
      otherInfoList.removeAt(index);
    });
  }

  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  Future<void> getAllCategoryNamesAndIds() async {
    final categorySnapshot = await FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Category')
        .get();

    if (categorySnapshot.docs.isNotEmpty) {
      for (final doc in categorySnapshot.docs) {
        final categoryId = doc.get('categoryId');
        final categoryName = doc.get('categoryName');

        if (categoryId != null && categoryName != null) {
          setState(() {
            categoryNamesAndIds[categoryId] = categoryName;
          });
        }
      }
    }
    print(categoryNamesAndIds);
  }

  @override
  void initState() {
    getAllCategoryNamesAndIds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text("Basic Info"),
        actions: [
          MyTextButton(
            onPressed: () {
              addProduct();
            },
            text: "NEXT",
            textColor: primaryDark2,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: isAddingProduct
              ? const Size(double.infinity, 10)
              : const Size(0, 0),
          child:
              isAddingProduct ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _image.isNotEmpty
                      ? Column(
                          children: [
                            Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  GestureDetector(
                                    onTap: changeFit,
                                    child: Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: primaryDark,
                                          width: 3,
                                        ),
                                        image: DecorationImage(
                                          fit: isFit ? BoxFit.cover : null,
                                          image: FileImage(
                                            _image[currentImageIndex],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: IconButton.filledTonal(
                                        onPressed: currentImageIndex !=
                                                _image.length - 1
                                            ? () {
                                                removeProductImages(
                                                    currentImageIndex);
                                              }
                                            : null,
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
                            ),
                            SizedBox(height: height * 0.025),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: primaryDark,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  height: height * 0.125,
                                  width: width * 0.79,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _image.length,
                                    itemBuilder: ((context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            currentImageIndex = index;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: Container(
                                            height: height * 0.125,
                                            width: height * 0.125 / 1.5,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 0.3,
                                                color: primaryDark,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: FileImage(
                                                  _image[index],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                SizedBox(width: width * 0.0275),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: primaryDark,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      addProductImages();
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: addProductImages,
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
                  SizedBox(height: height * 0.05),
                  Form(
                    key: productKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
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
                              if (value.length < 20 && value.isNotEmpty) {
                                return null;
                              } else {
                                return "20 characters max.";
                              }
                            } else {
                              return "Enter name";
                            }
                          },
                        ),
                        SizedBox(height: height * 0.0125),
                        TextFormField(
                          controller: descriptionController,
                          minLines: 1,
                          maxLines: 10,
                          maxLength: 500,
                          decoration: const InputDecoration(
                            hintText: "Description",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryDark2,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.isNotEmpty) {
                                return null;
                              } else {
                                return "Description should be atleast 1 chars long";
                              }
                            } else {
                              return "Enter Description";
                            }
                          },
                        ),
                        TextFormField(
                          controller: brandController,
                          decoration: const InputDecoration(
                            hintText: "Brand Name",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryDark2,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value != null) {
                              if (value.length < 20 && value.isNotEmpty) {
                                return null;
                              } else {
                                return "20 characters max.";
                              }
                            } else {
                              return "Enter Brand Name";
                            }
                          },
                        ),
                        SizedBox(height: height * 0.0125),
                        SizedBox(height: height * 0.005),
                        TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
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
                        SizedBox(height: height * 0.0125),
                        const Divider(),
                        SizedBox(height: height * 0.0125),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: Container(
                            width: width * 0.6,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: primary3,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton(
                              hint: const Text(
                                "Select Category",
                                style: TextStyle(
                                  color: primaryDark2,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 22,
                                color: primaryDark2,
                                fontWeight: FontWeight.w600,
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down_outlined,
                                color: Colors.black,
                              ),
                              value: selectedCategory,
                              dropdownColor: primary2,
                              borderRadius: BorderRadius.circular(12),
                              underline: const SizedBox(),
                              items: categoryNamesAndIds.isEmpty
                                  ? [
                                      DropdownMenuItem(
                                        value: '0',
                                        child: Text('None'),
                                      ),
                                    ]
                                  : categoryNamesAndIds.entries
                                      .map((entry) => DropdownMenuItem(
                                            value: entry.value,
                                            child: Text(entry.value),
                                          ))
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    if (value == '0') {
                                      selectedCategory = 'None';
                                      selectedCategoryId = '0';
                                    } else {
                                      final reveredIdAndNames =
                                          categoryNamesAndIds.map(
                                        (key, value) => MapEntry(value, key),
                                      );
                                      selectedCategoryId =
                                          reveredIdAndNames[value];
                                      selectedCategory = value;
                                    }
                                  });
                                  print(selectedCategory);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
