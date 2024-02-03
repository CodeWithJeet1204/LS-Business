// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/firebase/storage_methods.dart';
import 'package:find_easy/page/main/add/product/add_product_page_2.dart';
import 'package:find_easy/provider/add_product_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final brandController = TextEditingController();
  final descriptionController = TextEditingController();
  final otherInfoController = TextEditingController();
  final otherInfoValueController = TextEditingController();
  final searchController = TextEditingController();

  bool isAddingProduct = false;
  final List<File> _image = [];
  int currentImageIndex = 0;
  String? selectedCategory = 'No Category Selected';
  String? selectedCategoryId = '0';
  final List<String> _imageDownloadUrl = [];
  final ImagePicker picker = ImagePicker();
  List<String> otherInfoList = [];
  bool isFit = true;
  final Map<String, String> categoryNamesAndIds = {};
  bool isGridView = false;
  String? searchedCategory;

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

  void addProduct(AddProductProvider Provider) async {
    if (productKey.currentState!.validate()) {
      if (_image.isEmpty) {
        return mySnackBar(context, "Select atleast 1 image");
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
        bool productDoesntExists = true;
        final previousProducts = await store
            .collection('Business')
            .doc('Data')
            .collection('Products')
            .where('vendorId',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get();

        for (QueryDocumentSnapshot doc in previousProducts.docs) {
          if (doc['productName'] == nameController.text.toString()) {
            mySnackBar(
              context,
              "Product with same name already exists",
            );
            productDoesntExists = false;
          }
        }

        if (productDoesntExists) {
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
          Provider.add(
            {
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
            },
            false,
          );
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

  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final addProductProvider = Provider.of<AddProductProvider>(context);

    final Stream<QuerySnapshot<Map<String, dynamic>>> categoryStream = store
        .collection('Business')
        .doc("Data")
        .collection("Category")
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .orderBy('categoryName')
        .where('categoryName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('categoryName',
            isLessThan: searchController.text.toString() + '\uf8ff')
        .orderBy('datetime', descending: true)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text("Basic Info"),
        actions: [
          MyTextButton(
            onPressed: () {
              addProduct(addProductProvider);
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
                        // NAME
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

                        // DESCRIPTION
                        TextFormField(
                          controller: descriptionController,
                          minLines: 1,
                          maxLines: 10,
                          maxLength: 500,
                          keyboardType: TextInputType.multiline,
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
                        SizedBox(height: height * 0.0125),

                        // BRAND
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

                        // PRICE
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
                        SizedBox(height: height * 0.00625),

                        Divider(),

                        SizedBox(height: height * 0.00625),

                        Text(
                          "Select Category",
                          style: TextStyle(
                            color: primaryDark,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    labelText: "Case - Sensitive",
                                    hintText: "Search ...",
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isGridView = !isGridView;
                                  });
                                },
                                icon: Icon(
                                  isGridView
                                      ? Icons.list
                                      : Icons.grid_view_rounded,
                                ),
                                tooltip: isGridView ? "List View" : "Grid View",
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: SizedBox(
                            width: width,
                            child: StreamBuilder(
                                stream: categoryStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Something went wrong'),
                                    );
                                  }

                                  if (snapshot.hasData) {
                                    return isGridView
                                        ? GridView.builder(
                                            shrinkWrap: true,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: 0.8,
                                            ),
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: ((context, index) {
                                              final categorySnap =
                                                  snapshot.data!.docs[index];
                                              final categoryData =
                                                  categorySnap.data();

                                              return snapshot
                                                          .data!.docs.length ==
                                                      0
                                                  ? Center(
                                                      child: Text(
                                                          'No Categories Created'),
                                                    )
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                        vertical: 6,
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (selectedCategoryId !=
                                                              categoryData[
                                                                  'categoryId']) {
                                                            setState(() {
                                                              selectedCategory =
                                                                  categoryData[
                                                                      'categoryName'];
                                                              selectedCategoryId =
                                                                  categoryData[
                                                                      'categoryId'];
                                                            });
                                                          } else {
                                                            setState(() {
                                                              selectedCategory =
                                                                  "No Category Selected";
                                                              selectedCategoryId =
                                                                  '0';
                                                            });
                                                          }
                                                        },
                                                        child: Stack(
                                                          alignment: Alignment
                                                              .topRight,
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: primary2
                                                                    .withOpacity(
                                                                        0.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal: 4,
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 4,
                                                                      child:
                                                                          Container(),
                                                                    ),
                                                                    ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              9),
                                                                      child: Image
                                                                          .network(
                                                                        categoryData[
                                                                            'imageUrl'],
                                                                        height: width *
                                                                            0.4,
                                                                        width: width *
                                                                            0.4,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 5,
                                                                      child:
                                                                          Container(),
                                                                    ),
                                                                    Text(
                                                                      categoryData[
                                                                          'categoryName'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          const TextStyle(
                                                                        color:
                                                                            primaryDark,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 4,
                                                                      child:
                                                                          Container(),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            selectedCategoryId ==
                                                                    categoryData[
                                                                        'categoryId']
                                                                ? Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(
                                                                      right: 4,
                                                                      top: 4,
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      width: 40,
                                                                      height:
                                                                          40,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color:
                                                                            primaryDark,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .check,
                                                                        size:
                                                                            32,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container()
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                            }),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: ((context, index) {
                                              final categoryData =
                                                  snapshot.data!.docs[index];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 2,
                                                  vertical: 8,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (selectedCategoryId !=
                                                        categoryData[
                                                            'categoryId']) {
                                                      setState(() {
                                                        selectedCategory =
                                                            categoryData[
                                                                'categoryName'];
                                                        selectedCategoryId =
                                                            categoryData[
                                                                'categoryId'];
                                                      });
                                                    } else {
                                                      setState(() {
                                                        selectedCategory =
                                                            "No Category Selected";
                                                        selectedCategoryId =
                                                            '0';
                                                      });
                                                    }
                                                  },
                                                  child: Stack(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primary2
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: ListTile(
                                                          leading: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            child:
                                                                Image.network(
                                                              categoryData[
                                                                  'imageUrl'],
                                                              width: 45,
                                                              height: 45,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          title: Text(
                                                            categoryData[
                                                                'categoryName'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      selectedCategoryId ==
                                                              categoryData[
                                                                  'categoryId']
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                right: 4,
                                                                top: 4,
                                                              ),
                                                              child: Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      primaryDark,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Icon(
                                                                  Icons.check,
                                                                  size: 32,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            )
                                                          : Container()
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                          );
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
