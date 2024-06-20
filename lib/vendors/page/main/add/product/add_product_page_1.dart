// ignore_for_file: unnecessary_null_comparison
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/add/product/add_product_page_2.dart';
import 'package:localy/vendors/page/main/add/product/select_brand_for_product_page.dart';
import 'package:localy/vendors/provider/add_product_provider.dart';
import 'package:localy/vendors/provider/select_brand_for_product_provider.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/image_pick_dialog.dart';
import 'package:localy/widgets/shimmer_skeleton_container.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_button.dart';
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
  final ImagePicker picker = ImagePicker();
  List<String> otherInfoList = [];
  bool isFit = false;
  final Map<String, String> categoryNamesAndIds = {};
  bool isGridView = true;
  String? searchedCategory;
  bool isAvailable = true;
  Map<String, dynamic> currentCategories = {};
  Map<String, dynamic> allCategories = {};
  bool getCategoryData = false;

  // INIT STATE
  @override
  void initState() {
    getCategoryInfo();
    super.initState();
  }

  // DISPOSE
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

  // GET CATEGORY DATA
  Future<void> getCategoryInfo() async {
    Map<String, dynamic> myCategories = {};

    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final shopType = vendorData['Type'];

    final categorySnap = await store
        .collection('Business')
        .doc('Special Categories')
        .collection(shopType)
        .get();

    for (var categoryData in categorySnap.docs) {
      final categoryName = categoryData['specialCategoryName'];
      final categoryImageUrl = categoryData['specialCategoryImageUrl'];

      myCategories[categoryName] = categoryImageUrl;
    }

    setState(() {
      allCategories = myCategories;
      currentCategories = myCategories;
      getCategoryData = true;
    });
  }

  // ADD PRODUCT IMAGE
  Future<void> addProductImages() async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      setState(() {
        _image.add(File(im.path));
        currentImageIndex = _image.length - 1;
      });
    } else {
      if (mounted) {
        mySnackBar(context, 'Select an Image');
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
  Future<void> addProduct(AddProductProvider productProvider,
      SelectBrandForProductProvider brandProvider) async {
    if (productKey.currentState!.validate()) {
      if (_image.isEmpty) {
        return mySnackBar(context, 'Select atleast 1 image');
      }
      if (priceController.text.length > 10) {
        return mySnackBar(context, 'Max Price is 100 Cr.');
      }
      if (priceController.text.isNotEmpty) {
        if (double.parse(priceController.text) <= 0.99999999999999999999) {
          return mySnackBar(context, 'Min Price is 1 Rs.');
        }
      }
      try {
        bool productDoesntExists = true;
        final previousProducts = await store
            .collection('Business')
            .doc('Data')
            .collection('Products')
            .where('vendorId', isEqualTo: auth.currentUser!.uid)
            .get();

        for (QueryDocumentSnapshot doc in previousProducts.docs) {
          if (doc['productName'] == nameController.text.toString()) {
            if (mounted) {
              mySnackBar(
                context,
                'Product with same name already exists',
              );
            }
            productDoesntExists = false;
          }
        }

        if (productDoesntExists) {
          setState(() {
            isSaving = true;
          });

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
              'productLikesId': [],
              'productLikesTimestamp': [],
              'productWishlist': 0,
              'productId': productId,
              'imageFiles': _image,
              'datetime': Timestamp.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch,
              ),
              'isAvailable': isAvailable,
              'categoryName': selectedCategory,
              'vendorId': auth.currentUser!.uid,
              'ratings': {},
              'shortsThumbnail': '',
              'shortsURL': '',
            },
            false,
          );
          brandProvider.clear();
          setState(() {
            isSaving = false;
          });
          if (mounted) {
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
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  // CHANGE FIT
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'Basic Info',
        ),
        actions: [
          MyTextButton(
            onPressed: () async {
              await addProduct(addProductProvider, selectBrandProvider);
            },
            text: 'NEXT',
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
                                          fit: isFit ? null : BoxFit.cover,
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
                                                    currentImageIndex,
                                                  );
                                                }
                                              : null,
                                      icon: Icon(
                                        FeatherIcons.x,
                                        size: width * 0.1,
                                      ),
                                      tooltip: 'Remove Image',
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
                                    onPressed: () async {
                                      await addProductImages();
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
                          child: InkWell(
                            onTap: () async {
                              await addProductImages();
                            },
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
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
                                  Icon(
                                    FeatherIcons.upload,
                                    size: width * 0.4,
                                  ),
                                  SizedBox(height: width * 0.09),
                                  Text(
                                    'Select Image',
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
                        ),
                  const SizedBox(height: 28),

                  Form(
                    key: productKey,
                    child: Column(
                      children: [
                        // NAME
                        TextFormField(
                          controller: nameController,
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          maxLength: 60,
                          decoration: const InputDecoration(
                            hintText: 'Product Name',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryDark2,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              return null;
                            } else {
                              return 'Enter Name';
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // DESCRIPTION
                        TextFormField(
                          controller: descriptionController,
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          minLines: 1,
                          maxLines: 10,
                          maxLength: 500,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: 'Description',
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
                                return 'Description should be atleast 1 chars long';
                              }
                            } else {
                              return 'Enter Description';
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // PRICE
                        TextFormField(
                          controller: priceController,
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Price (Optional)',
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
                                          'Available',
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
                                          'Out Of Stock',
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
                          'Select Category',
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
                                  onTapOutside: (event) =>
                                      FocusScope.of(context).unfocus(),
                                  decoration: const InputDecoration(
                                    hintText: 'Search ...',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.isEmpty) {
                                        currentCategories =
                                            Map<String, dynamic>.from(
                                          allCategories,
                                        );
                                      } else {
                                        Map<String, dynamic>
                                            filteredCategories =
                                            Map<String, dynamic>.from(
                                          allCategories,
                                        );
                                        List<String> keysToRemove = [];

                                        filteredCategories
                                            .forEach((key, imageUrl) {
                                          if (!key
                                              .toString()
                                              .toLowerCase()
                                              .contains(value.toLowerCase())) {
                                            keysToRemove.add(key);
                                          }
                                        });

                                        for (var key in keysToRemove) {
                                          filteredCategories.remove(key);
                                        }

                                        currentCategories = filteredCategories;
                                      }
                                    });
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
                                tooltip: isGridView ? 'List View' : 'Grid View',
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
                            child: getCategoryData
                                ? currentCategories.isEmpty
                                    ? const SizedBox(
                                        height: 60,
                                        child: Center(
                                          child: Text('No Categories'),
                                        ),
                                      )
                                    : isGridView
                                        ? GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const ClampingScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: 0.75,
                                            ),
                                            itemCount: currentCategories.length,
                                            itemBuilder: ((context, index) {
                                              final categoryName =
                                                  currentCategories.keys
                                                      .toList()[index];
                                              final categoryImageUrl =
                                                  currentCategories.values
                                                      .toList()[index];

                                              return GestureDetector(
                                                onTap: () {
                                                  if (selectedCategory !=
                                                      categoryName) {
                                                    setState(() {
                                                      selectedCategory =
                                                          categoryName;
                                                      selectedCategory =
                                                          categoryName;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      selectedCategory =
                                                          'No Category Selected';
                                                      selectedCategory = '0';
                                                    });
                                                  }
                                                },
                                                child: Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: primary2
                                                            .withOpacity(0.125),
                                                        border: Border.all(
                                                          width: 0.25,
                                                          color: primaryDark,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(2),
                                                      ),
                                                      margin: EdgeInsets.all(
                                                        width * 0.00625,
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // CachedNetworkImage(
                                                          //   imageUrl:
                                                          //       categoryData[
                                                          //           'imageUrl'],
                                                          //   imageBuilder:
                                                          //       (context,
                                                          //           imageProvider) {
                                                          //     return Center(
                                                          //       child:
                                                          //           ClipRRect(
                                                          //         borderRadius:
                                                          //             BorderRadius
                                                          //                 .circular(
                                                          //           12,
                                                          //         ),
                                                          //         child:
                                                          //             Container(
                                                          //           width: width *
                                                          //               0.4,
                                                          //           height: width *
                                                          //               0.4,
                                                          //           decoration:
                                                          //               BoxDecoration(
                                                          //             image:
                                                          //                 DecorationImage(
                                                          //               image:
                                                          //                   imageProvider,
                                                          //               fit:
                                                          //                   BoxFit.cover,
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       ),
                                                          //     );
                                                          //   },
                                                          // ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                              width * 0.0125,
                                                            ),
                                                            child: Center(
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  2,
                                                                ),
                                                                child: Image
                                                                    .network(
                                                                  categoryImageUrl,
                                                                  width: width *
                                                                      0.5,
                                                                  height:
                                                                      width *
                                                                          0.5,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              left:
                                                                  width * 0.02,
                                                            ),
                                                            child: Text(
                                                              categoryName,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color:
                                                                    primaryDark,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize:
                                                                    width *
                                                                        0.06,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    selectedCategory ==
                                                            categoryName
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
                                              );
                                            }),
                                          )
                                        : SizedBox(
                                            width: width,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const ClampingScrollPhysics(),
                                              itemCount:
                                                  currentCategories.length,
                                              itemBuilder: ((context, index) {
                                                final categoryName =
                                                    currentCategories.keys
                                                        .toList()[index];
                                                final categoryImageUrl =
                                                    currentCategories.values
                                                        .toList()[index];

                                                return GestureDetector(
                                                  onTap: () {
                                                    if (selectedCategory !=
                                                        categoryName) {
                                                      setState(() {
                                                        selectedCategory =
                                                            categoryName;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        selectedCategory =
                                                            'No Category Selected';
                                                        selectedCategory = '0';
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
                                                          color: white,
                                                          border: Border.all(
                                                            width: 0.5,
                                                            color: primaryDark,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            2,
                                                          ),
                                                        ),
                                                        margin: EdgeInsets.all(
                                                          width * 0.0125,
                                                        ),
                                                        child: ListTile(
                                                          visualDensity:
                                                              VisualDensity
                                                                  .standard,
                                                          // leading:
                                                          //     CachedNetworkImage(
                                                          //   imageUrl:
                                                          //       categoryData[
                                                          //           'imageUrl'],
                                                          //   imageBuilder: (context,
                                                          //       imageProvider) {
                                                          //     return Padding(
                                                          //       padding: EdgeInsets
                                                          //           .symmetric(
                                                          //         vertical:
                                                          //             width *
                                                          //                 0.0125,
                                                          //       ),
                                                          //       child:
                                                          //           ClipRRect(
                                                          //         borderRadius:
                                                          //             BorderRadius
                                                          //                 .circular(
                                                          //           4,
                                                          //         ),
                                                          //         child:
                                                          //             Container(
                                                          //           width: width *
                                                          //               0.133,
                                                          //           height:
                                                          //               width *
                                                          //                   0.133,
                                                          //           decoration:
                                                          //               BoxDecoration(
                                                          //             image:
                                                          //                 DecorationImage(
                                                          //               image:
                                                          //                   imageProvider,
                                                          //               fit: BoxFit
                                                          //                   .cover,
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       ),
                                                          //     );
                                                          //   },
                                                          // ),
                                                          leading: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              2,
                                                            ),
                                                            child:
                                                                Image.network(
                                                              categoryImageUrl,
                                                              width:
                                                                  width * 0.15,
                                                              height:
                                                                  width * 0.15,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          title: Text(
                                                            categoryName,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width * 0.05,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      selectedCategory ==
                                                              categoryName
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
                                                );
                                              }),
                                            ),
                                          )
                                : isGridView
                                    ? GridView.builder(
                                        shrinkWrap: true,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
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
                                      ),
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
