// ignore_for_file: unnecessary_null_comparison
import 'dart:io';
import 'package:Localsearch/vendors/page/main/add/product/add_product_page_2.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/add/product/select_brand_for_product_page.dart';
import 'package:Localsearch/vendors/provider/add_product_provider.dart';
import 'package:Localsearch/vendors/provider/select_brand_for_product_provider.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/image_pick_dialog.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_button.dart';
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
  final storage = FirebaseStorage.instance;
  final productKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final otherInfoController = TextEditingController();
  final otherInfoValueController = TextEditingController();
  bool isSaving = false;
  final List<File> _image = [];
  int currentImageIndex = 0;
  final picker = ImagePicker();
  List<String> otherInfoList = [];
  bool isFit = false;
  int isAvailable = 0;
  bool? isPost;
  int? remainingProducts;
  int? maxImages;

  // INIT STATE
  @override
  void initState() {
    getProductQuota();
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
    super.dispose();
  }

  // GET PRODUCT QUOTA
  Future<void> getProductQuota() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final productGallery = vendorData['productGallery'];
    final myMaxImages = vendorData['maxImages'];

    final productsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    final currentProductsLength = productsSnap.docs.length;

    final difference = productGallery - currentProductsLength;

    setState(() {
      remainingProducts = difference;
      maxImages = myMaxImages;
    });
  }

  // ADD PRODUCT IMAGE
  Future<void> addProductImages() async {
    final images = await showImagePickDialog(context, false);
    final currentImagesLength = _image.length;
    final selectedImagesLength = images.length;
    if ((currentImagesLength + selectedImagesLength) > maxImages!) {
      final remainingSlots = maxImages! - currentImagesLength;
      final validImages = images.take(remainingSlots).toList();

      for (XFile im in validImages) {
        setState(() {
          _image.add(File(im.path));
          currentImageIndex = _image.length - 1;
        });
      }

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Max $maxImages Images Allowed'),
            content: Text(
              'Your current membership only supports $maxImages maximum',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      for (XFile im in images) {
        setState(() {
          _image.add(File(im.path));
          currentImageIndex = _image.length - 1;
        });
      }
    }
    if (images.isEmpty) {
      if (mounted) {
        mySnackBar(context, 'Select an Image');
      }
    }
  }

  // REMOVE PRODUCT IMAGE
  void removeProductImages(int index) {
    setState(() {
      _image.removeAt(index);
      if (currentImageIndex == (_image.length)) {
        currentImageIndex = _image.length - 1;
      }
    });
  }

  // ADD PRODUCT
  Future<void> addProduct(
    AddProductProvider productProvider,
    SelectBrandForProductProvider brandProvider,
  ) async {
    if (productKey.currentState!.validate()) {
      if (_image.length < 2) {
        return mySnackBar(context, 'Select atleast 2 image');
      }
      if (priceController.text.length > 10) {
        return mySnackBar(context, 'Max Price is 100 Cr.');
      }
      if (priceController.text.isNotEmpty) {
        if (double.parse(priceController.text) < 1) {
          return mySnackBar(context, 'Min Price is 1 Rs.');
        }
      }
      try {
        final vendorSnap = await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid)
            .get();

        final vendorData = vendorSnap.data()!;

        final double latitude = vendorData['Latitude'];
        final double longitude = vendorData['Longitude'];
        final String city = vendorData['City'];
        final membershipType = vendorData['MembershipName'];

        isPost = membershipType != 'Basic';

        bool productDoesntExists = true;
        final previousProducts = await store
            .collection('Business')
            .doc('Data')
            .collection('Products')
            .where('vendorId', isEqualTo: auth.currentUser!.uid)
            .where('productName', isEqualTo: nameController.text.toString())
            .get();

        if (previousProducts.docs.isNotEmpty) {
          if (mounted) {
            mySnackBar(
              context,
              'Product with same name already exists',
            );
          }
          productDoesntExists = false;
        }

        if (productDoesntExists) {
          setState(() {
            isSaving = true;
          });

          final String productId = const Uuid().v4();
          productProvider.add(
            {
              'productName': nameController.text,
              'productPrice': double.parse(priceController.text),
              'productDescription': descriptionController.text,
              'productBrand': brandProvider.selectedBrandName,
              'productBrandId': brandProvider.selectedBrandId,
              'productShares': 0,
              'productViewsTimestamp': [],
              'productLikesTimestamp': {},
              'productWishlistTimestamp': {},
              'productId': productId,
              'imageFiles': _image,
              'datetime': Timestamp.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch,
              ),
              'isAvailable': isAvailable,
              'vendorId': auth.currentUser!.uid,
              'ratings': {},
              'shortsThumbnail': '',
              'shortsURL': '',
              'isPost': isPost,
              'City': city,
              'Latitude': latitude,
              'Longitude': longitude,
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
                builder: ((context) => AddProductPage2()),
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
    final width = MediaQuery.of(context).size.width;
    final selectBrandProvider =
        Provider.of<SelectBrandForProductProvider>(context);
    final addProductProvider = Provider.of<AddProductProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          remainingProducts == 0 ? 'Product Gallery Full' : 'Basic Info',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          remainingProducts == 0
              ? Container()
              : MyTextButton(
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
      body: remainingProducts == 0
          ? Center(
              child: Text(
                'Your Product Gallery is full\nDelete older products or renew your membership to increase limit',
                textAlign: TextAlign.center,
              ),
            )
          : Padding(
              padding: EdgeInsets.all(
                width * 0.0225,
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: primaryDark,
                                                width: 3,
                                              ),
                                              image: DecorationImage(
                                                fit:
                                                    isFit ? null : BoxFit.cover,
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
                                            onPressed: () {
                                              removeProductImages(
                                                currentImageIndex,
                                              );
                                            },
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: primaryDark,
                                            width: 3,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        width: _image.length - maxImages! == 0
                                            ? width * 0.975
                                            : width * 0.775,
                                        height: width * 0.225,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: ClampingScrollPhysics(),
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
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: Container(
                                                  height: width * 0.18,
                                                  width: width * 0.18,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 0.3,
                                                      color: primaryDark,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
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
                                      _image.length - maxImages! == 0
                                          ? Container()
                                          : Container(
                                              height: width * 0.19,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: primaryDark,
                                                  width: 3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          FeatherIcons.upload,
                                          size: width * 0.4,
                                        ),
                                        Text(
                                          'Select Image',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.09,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Max. $maxImages images',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.04,
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

                              // PRICE
                              TextFormField(
                                controller: priceController,
                                onTapOutside: (event) =>
                                    FocusScope.of(context).unfocus(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Price',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: primaryDark2,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (int.parse(value) >= 1) {
                                      return null;
                                    } else {
                                      return 'Price should be greater than Rs. 1';
                                    }
                                  } else {
                                    return 'Enter Price';
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.025),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: primary2.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectBrandProvider.selectedBrandName ==
                                                'No Brand'
                                            ? 'Select Brand'
                                            : selectBrandProvider
                                                .selectedBrandName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: primaryDark,
                                          fontSize: width * 0.055,
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
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isAvailable = 0;
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
                                              SizedBox(
                                                width: width * 0.8,
                                                child: AutoSizeText(
                                                  'Available',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: width * 0.05,
                                                  ),
                                                ),
                                              ),
                                              Checkbox(
                                                activeColor: primaryDark,
                                                checkColor: white,
                                                value: isAvailable == 0,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isAvailable = 0;
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
                                          isAvailable = 1;
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.025,
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: width * 0.8,
                                              child: AutoSizeText(
                                                'Will be Available Within a Week',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: primaryDark,
                                                  fontSize: width * 0.05,
                                                ),
                                              ),
                                            ),
                                            Checkbox(
                                              activeColor: primaryDark,
                                              checkColor: white,
                                              value: isAvailable == 1,
                                              onChanged: (value) {
                                                setState(() {
                                                  isAvailable = 1;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isAvailable = 2;
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
                                              SizedBox(
                                                width: width * 0.8,
                                                child: AutoSizeText(
                                                  'Out Of Stock',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: width * 0.05,
                                                  ),
                                                ),
                                              ),
                                              Checkbox(
                                                activeColor: primaryDark,
                                                checkColor: white,
                                                value: isAvailable == 2,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isAvailable = 2;
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
