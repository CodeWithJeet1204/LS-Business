// ignore_for_file: unnecessary_null_comparison
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/page/main/add/product/add_product_page_2.dart';
import 'package:find_easy/page/main/add/product/select_brand_for_product_page.dart';
import 'package:find_easy/provider/add_product_provider.dart';
import 'package:find_easy/provider/select_brand_for_product_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/image_pick_dialog.dart';
import 'package:find_easy/widgets/shimmer_skeleton_container.dart';
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
  final fireStorage = FirebaseStorage.instance;
  final productKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final otherInfoController = TextEditingController();
  final otherInfoValueController = TextEditingController();
  final searchController = TextEditingController();

  bool isSaving = false;
  final List<File> _image = [];
  int currentImageIndex = 0;
  String? selectedCategory = 'No Category Selected';
  String? selectedCategoryId = '0';
  final List<String> _imageDownloadUrl = [];
  final ImagePicker picker = ImagePicker();
  List<String> otherInfoList = [];
  bool isFit = false;
  final Map<String, String> categoryNamesAndIds = {};
  bool isGridView = true;
  String? searchedCategory;
  bool isAvailable = true;

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    otherInfoController.dispose();
    otherInfoValueController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // ADD PRODUCT IMAGE
  void addProductImages() async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      setState(() {
        _image.add(File(im.path));
        currentImageIndex = _image.length - 1;
      });
    } else {
      if (context.mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  // REMOVE PRODUCT IMAGE
  void removeProductImages(int index) {
    setState(() {
      _image.removeAt(index);
    });
  }

  // ADD PRODUCT
  void addProduct(AddProductProvider productProvider,
      SelectBrandForProductProvider brandProvider) async {
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
            if (context.mounted) {
              mySnackBar(
                context,
                "Product with same name already exists",
              );
            }
            productDoesntExists = false;
          }
        }

        if (productDoesntExists) {
          setState(() {
            isSaving = true;
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
          productProvider.add(
            {
              'productName': nameController.text,
              'productPrice': priceController.text,
              'productDescription': descriptionController.text,
              'productBrand': brandProvider.selectedBrandName,
              'productBrandId': brandProvider.selectedBrandId,
              'productLikes': 0,
              'productDislikes': 0,
              'productShares': 0,
              'productViews': 0,
              'productViewsTimestamp': [],
              'productLikesTimestamp': [],
              'productWishlist': 0,
              'productId': productId,
              'images': _imageDownloadUrl,
              'datetime': Timestamp.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch,
              ),
              'isAvailable': isAvailable,
              'categoryName': selectedCategory,
              'categoryId': selectedCategoryId,
              'vendorId': FirebaseAuth.instance.currentUser!.uid,
            },
            false,
          );
          setState(() {
            isSaving = false;
          });
          if (context.mounted) {
            mySnackBar(context, "Basic Info Added");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => AddProductPage2(productId: productId)),
              ),
            );
          }
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

  // CHANGE IMAGE FIT
  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectBrandProvider =
        Provider.of<SelectBrandForProductProvider>(context);
    final addProductProvider = Provider.of<AddProductProvider>(context);

    final Stream<QuerySnapshot<Map<String, dynamic>>> categoryStream = store
        .collection('Business')
        .doc("Data")
        .collection("Category")
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .orderBy('categoryName')
        .where('categoryName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('categoryName', isLessThan: '${searchController.text}\uf8ff')
        .orderBy('datetime', descending: true)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          "Basic Info",
        ),
        actions: [
          MyTextButton(
            onPressed: () {
              addProduct(addProductProvider, selectBrandProvider);
            },
            text: "NEXT",
            textColor: primaryDark2,
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              isSaving ? const Size(double.infinity, 10) : const Size(0, 0),
          child: isSaving ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.0225,
        ),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGE
                  _image.isNotEmpty
                      ? Column(
                          children: [
                            Center(
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  GestureDetector(
                                    onTap: changeFit,
                                    child: Container(
                                      height: width,
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
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: width * 0.015,
                                      right: width * 0.015,
                                    ),
                                    child: IconButton.filledTonal(
                                      onPressed:
                                          currentImageIndex != _image.length - 1
                                              ? () {
                                                  removeProductImages(
                                                      currentImageIndex);
                                                }
                                              : null,
                                      icon: Icon(
                                        FeatherIcons.x,
                                        size: width * 0.1,
                                      ),
                                      tooltip: "Remove Image",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                  height: width * 0.225,
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
                                            height: width * 0.18,
                                            width: width * 0.18,
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
                                  height: width * 0.19,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: primaryDark,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    splashRadius: width * 0.095,
                                    onPressed: () {
                                      addProductImages();
                                    },
                                    icon: Icon(
                                      FeatherIcons.plus,
                                      size: width * 0.115,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : SizedOverflowBox(
                          size: Size(width, width),
                          child: Container(
                            width: width,
                            height: width,
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
                                  icon: Icon(
                                    FeatherIcons.upload,
                                    size: width * 0.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Select Image",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.09,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 28),

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
                            if (value != null && value.isNotEmpty) {
                              if (value.length < 20) {
                                return null;
                              } else {
                                return "20 characters max.";
                              }
                            } else {
                              return "Enter Name";
                            }
                          },
                        ),
                        const SizedBox(height: 12),

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
                        const SizedBox(height: 12),

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
                        const SizedBox(height: 12),

                        // BRAND
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) =>
                                    const SelectBrandForProductPage()),
                              ),
                            );
                          },
                          splashColor: primary2,
                          radius: width * 0.5,
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            height: width * 0.16,
                            width: width,
                            padding:
                                EdgeInsets.symmetric(horizontal: width * 0.025),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectBrandProvider.selectedBrandName ==
                                          'No Brand'
                                      ? 'Select Brand'
                                      : selectBrandProvider.selectedBrandName!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: primaryDark,
                                    fontSize: width * 0.06,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  FeatherIcons.chevronRight,
                                  color: primaryDark,
                                  size: width * 0.09,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // AVAILABLE / OUT OF STOCK
                        Container(
                          width: width,
                          height: 130,
                          decoration: BoxDecoration(
                            color: primary2.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isAvailable = !isAvailable;
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
                                          "Available",
                                          style: TextStyle(
                                            color: primaryDark,
                                            fontSize: width * 0.06,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Checkbox(
                                          activeColor: primaryDark,
                                          checkColor: white,
                                          value: isAvailable,
                                          onChanged: (value) {
                                            setState(() {
                                              isAvailable = value!;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isAvailable = !isAvailable;
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
                                          "Out Of Stock",
                                          style: TextStyle(
                                            color: primaryDark,
                                            fontSize: width * 0.06,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Checkbox(
                                          activeColor: primaryDark,
                                          checkColor: white,
                                          value: !isAvailable,
                                          onChanged: (value) {
                                            setState(() {
                                              isAvailable = !value!;
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

                        const SizedBox(height: 12),

                        const Divider(),

                        const SizedBox(height: 12),

                        // SELECT CATEGORY TEXT
                        Text(
                          overflow: TextOverflow.ellipsis,
                          "Select Category",
                          style: TextStyle(
                            color: primaryDark,
                            fontSize: width * 0.066,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // SELECT CATEGORY
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  autocorrect: false,
                                  decoration: const InputDecoration(
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
                                      ? FeatherIcons.list
                                      : FeatherIcons.grid,
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
                                    return const Center(
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        'Something went wrong',
                                      ),
                                    );
                                  }

                                  if (snapshot.hasData) {
                                    return isGridView
                                        ? GridView.builder(
                                            shrinkWrap: true,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
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

                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.0125,
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
                                                    alignment:
                                                        Alignment.topRight,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primary2
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal:
                                                                width * 0.0125,
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child:
                                                                    Container(),
                                                              ),
                                                              CachedNetworkImage(
                                                                imageUrl:
                                                                    categoryData[
                                                                        'imageUrl'],
                                                                imageBuilder:
                                                                    (context,
                                                                        imageProvider) {
                                                                  return Center(
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                        12,
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        width: width *
                                                                            0.4,
                                                                        height: width *
                                                                            0.4,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                imageProvider,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              Expanded(
                                                                flex: 5,
                                                                child:
                                                                    Container(),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  left: width *
                                                                      0.025,
                                                                ),
                                                                child: Text(
                                                                  categoryData[
                                                                      'categoryName'],
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        primaryDark,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        width *
                                                                            0.06,
                                                                  ),
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
                                                              child: Container(
                                                                width: width *
                                                                    0.1125,
                                                                height: width *
                                                                    0.1125,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color:
                                                                      primaryDark,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Icon(
                                                                  FeatherIcons
                                                                      .check,
                                                                  size: width *
                                                                      0.08,
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
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.01,
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
                                                          leading:
                                                              CachedNetworkImage(
                                                            imageUrl:
                                                                categoryData[
                                                                    'imageUrl'],
                                                            imageBuilder: (context,
                                                                imageProvider) {
                                                              return Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  vertical:
                                                                      width *
                                                                          0.0125,
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    4,
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    width: width *
                                                                        0.133,
                                                                    height:
                                                                        width *
                                                                            0.133,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          title: Text(
                                                            categoryData[
                                                                'categoryName'],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width * 0.055,
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
                                                                  EdgeInsets
                                                                      .only(
                                                                right: width *
                                                                    0.033,
                                                              ),
                                                              child: Container(
                                                                width: width *
                                                                    0.125,
                                                                height: width *
                                                                    0.125,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color:
                                                                      primaryDark,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Icon(
                                                                  Icons.check,
                                                                  size: width *
                                                                      0.1,
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

                                  return isGridView
                                      ? GridView.builder(
                                          shrinkWrap: true,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 0,
                                            mainAxisSpacing: 0,
                                            childAspectRatio:
                                                width * 0.5 / width * 1.6,
                                          ),
                                          itemCount: 4,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.all(
                                                width * 0.02,
                                              ),
                                              child: GridViewSkeleton(
                                                width: width,
                                                isPrice: false,
                                                height: 30,
                                              ),
                                            );
                                          },
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: 4,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.all(
                                                width * 0.02,
                                              ),
                                              child: ListViewSkeleton(
                                                width: width,
                                                isPrice: false,
                                                height: 30,
                                              ),
                                            );
                                          },
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
