// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:io';
import 'package:Localsearch/widgets/show_loading_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/analytics/analytics_page.dart';
import 'package:Localsearch/vendors/page/main/discount/products/product_discount_page.dart';
import 'package:Localsearch/vendors/page/main/profile/data/all_product_page.dart';
import 'package:Localsearch/vendors/page/main/profile/view%20page/category/category_page.dart';
import 'package:Localsearch/vendors/page/main/profile/view%20page/product/change_product_category_page.dart';
import 'package:Localsearch/vendors/page/main/profile/view%20page/product/image_view.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/my_button.dart';
import 'package:Localsearch/widgets/image_pick_dialog.dart';
import 'package:Localsearch/widgets/info_box.dart';
import 'package:Localsearch/widgets/info_color_box.dart';
import 'package:Localsearch/widgets/info_edit_box.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    super.key,
    required this.productId,
    required this.productName,
    this.fromPost = false,
    this.categoryName,
    this.brandId,
  });

  final String productId;
  final String productName;
  final String? categoryName;
  final String? brandId;
  final bool fromPost;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final GlobalKey<FormState> editKey = GlobalKey<FormState>();
  final editController = TextEditingController();
  bool isDiscount = false;
  int _currentIndex = 0;
  bool isEditing = false;
  bool isImageChanging = false;
  Map<String, dynamic> category = {};
  int? maxImages;

  // INIT STATE
  @override
  void initState() {
    getMaxImages();
    ifDiscount();
    getCategoryInfo();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  // GET MAX IMAGES
  Future<void> getMaxImages() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final myMaxImages = vendorData['maxImages'];

    setState(() {
      maxImages = myMaxImages;
    });
  }

  // EDIT INFO
  Future<void> edit(
    String propertyValue,
    int noOfAnswers,
    bool isProperty,
    bool inputType,
  ) async {
    await showDialog(
        context: context,
        builder: (context) {
          final propertyStream = store
              .collection('Business')
              .doc('Data')
              .collection('Products')
              .doc(widget.productId)
              .snapshots();

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              height: noOfAnswers == 1 ? 180 : 200,
              child: StreamBuilder(
                  stream: propertyStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Something went wrong',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      final propertyData = snapshot.data!;
                      final property = isProperty
                          ? propertyData['Properties'][propertyValue]
                          : propertyData[propertyValue];

                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Form(
                          key: editKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 80,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: editController,
                                        onTapOutside: (event) =>
                                            FocusScope.of(context).unfocus(),
                                        keyboardType: inputType
                                            ? TextInputType.text
                                            : TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Enter $propertyValue',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (propertyValue != 'productPrice') {
                                            if (value != null &&
                                                value.length >= 2) {
                                              return null;
                                            } else {
                                              return 'Min 2 chars required';
                                            }
                                          } else {
                                            if (double.parse(value!) > 0) {
                                              return null;
                                            } else {
                                              return 'Min price is Rs. 1';
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    noOfAnswers != 1
                                        ? MyTextButton(
                                            onPressed: () async {
                                              if (editKey.currentState!
                                                  .validate()) {
                                                // MULTI WORD PROPERTY
                                                if (isProperty) {
                                                  (property as List).add(
                                                      editController.text
                                                          .toString()
                                                          .toUpperCase());
                                                  Map<String, dynamic>
                                                      newPropertyMap =
                                                      propertyData[
                                                          'Properties'];
                                                  newPropertyMap[
                                                      propertyValue] = property;

                                                  newPropertyMap[
                                                      propertyValue] = property;

                                                  await store
                                                      .collection('Business')
                                                      .doc('Data')
                                                      .collection('Products')
                                                      .doc(widget.productId)
                                                      .update({
                                                    'Properties':
                                                        newPropertyMap,
                                                  });
                                                  editController.clear();
                                                } else {
                                                  // MULTI WORD NOT PROPERTY
                                                  (property as List).add(
                                                      editController.text
                                                          .toString()
                                                          .toUpperCase());

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Business')
                                                      .doc('Data')
                                                      .collection('Products')
                                                      .doc(widget.productId)
                                                      .update({
                                                    propertyValue: property,
                                                  });
                                                  editController.clear();
                                                }
                                              }
                                            },
                                            text: 'ADD',
                                            textColor: primaryDark2,
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              noOfAnswers != 1 &&
                                      (property as List).isNotEmpty &&
                                      property[0] != ''
                                  ? SizedBox(
                                      height: 50,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(),
                                        itemCount: property.length,
                                        itemBuilder: ((context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: primaryDark2
                                                    .withOpacity(0.75),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 12,
                                                    ),
                                                    child: Text(
                                                      property[index],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 2,
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () async {
                                                        // MULTI WORD PORPERTY
                                                        if (isProperty) {
                                                          property
                                                              .removeAt(index);
                                                          Map<String, dynamic>
                                                              newPropertyMap =
                                                              propertyData[
                                                                  'Properties'];
                                                          newPropertyMap[
                                                                  propertyValue] =
                                                              property;
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Business')
                                                              .doc('Data')
                                                              .collection(
                                                                  'Products')
                                                              .doc(widget
                                                                  .productId)
                                                              .update({
                                                            'Properties':
                                                                newPropertyMap,
                                                          });
                                                          editController
                                                              .clear();
                                                          // TAGS
                                                        } else {
                                                          property
                                                              .removeAt(index);

                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Business')
                                                              .doc('Data')
                                                              .collection(
                                                                  'Products')
                                                              .doc(widget
                                                                  .productId)
                                                              .update({
                                                            propertyValue:
                                                                property,
                                                          });
                                                          editController
                                                              .clear();
                                                        }
                                                      },
                                                      icon: const Icon(
                                                        FeatherIcons.x,
                                                        color: white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    )
                                  : Container(),
                              noOfAnswers == 1
                                  ? MyButton(
                                      text: 'SAVE',
                                      onTap: () async {
                                        if (editKey.currentState!.validate()) {
                                          await showLoadingDialog(
                                            context,
                                            () async {
                                              setState(() {
                                                isEditing = true;
                                              });
                                              try {
                                                // 1 WORD PROPERTY
                                                if (isProperty) {
                                                  Map<String, dynamic>
                                                      newPropertyMap =
                                                      propertyData[
                                                          'Properties'];

                                                  newPropertyMap[
                                                      propertyValue] = [
                                                    editController.text
                                                        .toString()
                                                        .toUpperCase()
                                                  ];
                                                  await store
                                                      .collection('Business')
                                                      .doc('Data')
                                                      .collection('Products')
                                                      .doc(widget.productId)
                                                      .update({
                                                    'Properties':
                                                        newPropertyMap,
                                                  });
                                                  editController.clear();

                                                  // 1 WORD NOT PROPERTY
                                                } else {
                                                  await store
                                                      .collection('Business')
                                                      .doc('Data')
                                                      .collection('Products')
                                                      .doc(widget.productId)
                                                      .update({
                                                    propertyValue:
                                                        propertyValue !=
                                                                'productPrice'
                                                            ? editController
                                                                .text
                                                                .toString()
                                                            : double.parse(
                                                                editController
                                                                    .text),
                                                  });
                                                  editController.clear();
                                                }
                                                editController.clear();
                                                if (context.mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  mySnackBar(
                                                      context, e.toString());
                                                }
                                              }
                                              setState(() {
                                                isEditing = false;
                                              });
                                            },
                                          );
                                        }
                                      },
                                      horizontalPadding: 0,
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ),
          );
        });
  }

  // ADD IMAGES
  Future<void> addProductImages(List images) async {
    final List<XFile> imageList = await showImagePickDialog(context, false);
    final currentImagesLength = images.length;
    final selectedImagesLength = imageList.length;
    if ((currentImagesLength + selectedImagesLength) > maxImages!) {
      setState(() {
        isImageChanging = true;
      });
      final remainingSlots = maxImages! - currentImagesLength;
      final validImages = imageList.take(remainingSlots).toList();

      for (var im in validImages) {
        final productImageId = Uuid().v4();

        Reference ref =
            storage.ref().child('Vendor/Products').child(productImageId);
        await ref.putFile(File(im.path)).whenComplete(() async {
          await ref.getDownloadURL().then((value) async {
            setState(() {
              images.add(value);
            });
          });
        });
      }

      await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(widget.productId)
          .update({
        'images': images,
      });

      setState(() {
        isImageChanging = false;
      });

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

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => ProductPage(
                  productId: widget.productId,
                  productName: widget.productName,
                )),
          ),
        );
      }
    } else if (imageList.isNotEmpty) {
      try {
        setState(() {
          isImageChanging = true;
        });
        for (var im in imageList) {
          final productImageId = Uuid().v4();

          Reference ref =
              storage.ref().child('Vendor/Products').child(productImageId);
          await ref.putFile(File(im.path)).whenComplete(() async {
            await ref.getDownloadURL().then((value) async {
              images.add(value);
            });
          });
        }

        await store
            .collection('Business')
            .doc('Data')
            .collection('Products')
            .doc(widget.productId)
            .update({
          'images': images,
        });

        setState(() {
          isImageChanging = false;
        });

        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: ((context) => ProductPage(
                    productId: widget.productId,
                    productName: widget.productName,
                  )),
            ),
          );
        }
      } catch (e) {
        setState(() {
          isImageChanging = true;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  // CHANGE IMAGE
  // Future<void> changeProductImage(String e, int index, List images) async {
  //   final XFile im = await showImagePickDialog(context);
  //   if (im != null) {
  //     try {
  //       setState(() {
  //         isImageChanging = true;
  //       });
  //       Reference ref = FirebaseStorage.instance.refFromURL(images[index]);
  //       await images.removeAt(index);
  //       await ref.putFile(File(im.path));
  //       setState(() {
  //         isImageChanging = false;
  //       });
  //     } catch (e) {
  //       setState(() {
  //         isImageChanging = false;
  //       });
  //       if (mounted) {
  //         mySnackBar(context, e.toString());
  //       }
  //     }
  //   }
  // }

  // REMOVE IMAGES
  Future<void> removeProductImages(int index, List images) async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            'Confirm REMOVE',
          ),
          content: const Text(
            'Are you sure you want to remove this image?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await storage.refFromURL(images[index]).delete();
                setState(() {
                  images.removeAt(index);
                });
                await store
                    .collection('Business')
                    .doc('Data')
                    .collection('Products')
                    .doc(widget.productId)
                    .update({
                  'images': images,
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'YES',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // CONFIRM DELETE
  Future<void> confirmDelete() async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            'Confirm DELETE',
          ),
          content: const Text(
            'Are you sure you want to delete this product & all its posts',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await delete();
              },
              child: const Text(
                'YES',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // GET CATEGORY
  Future<void> getCategoryInfo() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final List shopTypes = vendorData['Type'];

    final productSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .doc(widget.productId)
        .get();

    final productData = productSnap.data()!;

    final categoryName = productData['categoryName'];

    if (categoryName == '0') {
      setState(() {
        category.addAll({
          'name': 'No Category',
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
          'shopTypes': shopTypes,
        });
      });
      return;
    } else {
      final justCategoriesSnap = await store
          .collection('Shop Types And Category Data')
          .doc('Just Category Data')
          .get();

      final justCategoriesData = justCategoriesSnap.data()!;

      final householdCategories = justCategoriesData['householdCategories'];

      final imageUrl = householdCategories[categoryName];

      setState(() {
        category.addAll({
          'name': categoryName,
          'imageUrl': imageUrl,
          'shopTypes': shopTypes,
        });
      });
    }
  }

  // DELETE PRODUCT
  Future<void> delete() async {
    setState(() {
      isEditing = true;
    });
    try {
      if (mounted) {
        Navigator.of(context).pop();
      }
      final productSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(widget.productId)
          .get();

      final productData = productSnap.data()!;

      final List images = productData['images'];

      images.forEach((image) async {
        await storage.refFromURL(image).delete();
      });

      await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(widget.productId)
          .delete();

      final shortsSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Shorts')
          .where('productId', isEqualTo: widget.productId)
          .get();

      for (QueryDocumentSnapshot doc in shortsSnap.docs) {
        await doc.reference.delete();
      }

      await storage
          .ref()
          .child('Vendor/Shorts')
          .child(widget.productId)
          .delete();

      if (mounted) {
        mySnackBar(context, 'Product Deleted');
      }
      setState(() {
        isEditing = false;
      });
    } catch (e) {
      setState(() {
        isEditing = false;
      });
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // IF DISCOUNT
  Future<void> ifDiscount() async {
    final discountSnapshot = await store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc
        in discountSnapshot.docs) {
      final data = doc.data();

      // products
      if (data['isProducts'] &&
          (data['products'] as List).contains(widget.productId)) {
        // Check if the discount is active
        if ((data['discountEndDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now()) &&
            !(data['discountStartDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now())) {
          setState(() {
            isDiscount = true;
          });
          return;
        }
      }

      // brands
      if (data['isBrands'] &&
          (data['brands'] as List).contains(widget.brandId)) {
        // Check if the discount is active
        if ((data['discountEndDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now()) &&
            !(data['discountStartDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now())) {
          setState(() {
            isDiscount = true;
          });
          return;
        }
      }

      // categories
      if (data['isCategories'] &&
          (data['categories'] as List).contains(widget.categoryName)) {
        if ((data['discountEndDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now()) &&
            !(data['discountStartDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now())) {
          setState(() {
            isDiscount = true;
          });
          return;
        }
      }
    }
  }

  // BLUR HASH IMAGE
  // Future<String> blurHashImage(String imageUrl) async {
  //   var response = await http.get(Uri.parse(imageUrl));
  //   Uint8List imageData = response.bodyBytes;
  // Generate Blurhash string
  //   String blurhash = await BlurHash.encode(imageData, 10, 10);
  //   return blurhash;
  // }

  // CONFIRM DELETE SHORT
  Future<void> confirmDeleteShort() async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text('Delete Short'),
          content: const Text('Are you sure you want to delete this short?'),
          actions: [
            MyTextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'NO',
              textColor: Colors.green,
            ),
            MyTextButton(
              onPressed: () async {
                await deleteShort();
                Navigator.of(context).pop();
              },
              text: 'YES',
              textColor: Colors.red,
            ),
          ],
        );
      }),
    );
  }

  // DELETE SHORT
  Future<void> deleteShort() async {
    await store
        .collection('Business')
        .doc('Data')
        .collection('Shorts')
        .doc(widget.productId)
        .delete();

    await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .doc(widget.productId)
        .update({
      'shortsThumbnail': '',
      'shortsURL': '',
    });

    await storage.ref('Vendor/Shorts/${widget.productId}').delete();
    await storage.ref('Vendor/Thumbnails/${widget.productId}').delete();
  }

  @override
  Widget build(BuildContext context) {
    final productStream = store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .doc(widget.productId)
        .snapshots();

    final discountPriceStream = store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await confirmDelete();
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AllProductsPage()),
                );
              }
            },
            icon: const Icon(
              FeatherIcons.trash,
              color: Colors.red,
            ),
            tooltip: 'DELETE',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;

            return SingleChildScrollView(
              child: StreamBuilder(
                  stream: productStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Something went wrong',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      final productData = snapshot.data!;
                      final String name = productData['productName'];
                      final price = productData['productPrice'];
                      final String? description =
                          productData['productDescription'];
                      final String brand = productData['productBrand'];
                      final List images = productData['images'];
                      final List tags = productData['Tags'];

                      final int likes =
                          (productData['productLikesTimestamp'] as Map).length;
                      final int shares = productData['productShares'];
                      final List views = productData['productViewsTimestamp'];
                      final Map wishList =
                          productData['productWishlistTimestamp'];

                      final String? shortsThumbnail =
                          productData['shortsThumbnail'];

                      final String? shortsURL = productData['shortsURL'];

                      if (shortsThumbnail != null && shortsThumbnail != '') {
                        images.insert(0, shortsThumbnail);
                      }

                      int isAvailable = productData['isAvailable'];

                      final Map<String, dynamic> properties =
                          productData['Properties'];
                      final String propertyName0 = properties['propertyName0'];
                      final String propertyName1 = properties['propertyName1'];
                      final String propertyName2 = properties['propertyName2'];
                      final String propertyName3 = properties['propertyName3'];
                      final String propertyName4 = properties['propertyName4'];
                      final String propertyName5 = properties['propertyName5'];

                      final List propertyValue0 = properties['propertyValue0'];
                      final List propertyValue1 = properties['propertyValue1'];
                      final List propertyValue2 = properties['propertyValue2'];
                      final List propertyValue3 = properties['propertyValue3'];
                      final List propertyValue4 = properties['propertyValue4'];
                      final List propertyValue5 = properties['propertyValue5'];

                      final int propertyNoOfAnswers0 =
                          properties['propertyNoOfAnswers0'];
                      final int propertyNoOfAnswers1 =
                          properties['propertyNoOfAnswers1'];
                      final int propertyNoOfAnswers2 =
                          properties['propertyNoOfAnswers2'];
                      final int propertyNoOfAnswers3 =
                          properties['propertyNoOfAnswers3'];
                      final int propertyNoOfAnswers4 =
                          properties['propertyNoOfAnswers4'];
                      final int propertyNoOfAnswers5 =
                          properties['propertyNoOfAnswers5'];

                      final bool propertyInputType0 =
                          properties['propertyInputType0'];
                      final bool propertyInputType1 =
                          properties['propertyInputType1'];
                      final bool propertyInputType2 =
                          properties['propertyInputType2'];
                      final bool propertyInputType3 =
                          properties['propertyInputType3'];
                      final bool propertyInputType4 =
                          properties['propertyInputType4'];
                      final bool propertyInputType5 =
                          properties['propertyInputType5'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGES
                          CarouselSlider(
                            items: images
                                .map(
                                  (e) => Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: primaryDark2,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: isImageChanging
                                                ? const CircularProgressIndicator()
                                                : GestureDetector(
                                                    onTap: () {
                                                      if (shortsThumbnail !=
                                                              null &&
                                                          shortsThumbnail !=
                                                              '') {
                                                        images.remove(
                                                          shortsThumbnail,
                                                        );
                                                      }
                                                      if (shortsURL != null &&
                                                          shortsURL != '') {
                                                        images.insert(
                                                          0,
                                                          shortsURL,
                                                        );
                                                      }

                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: ((context) =>
                                                              ImageView(
                                                                imagesUrl:
                                                                    images,
                                                                shortsThumbnail:
                                                                    shortsThumbnail,
                                                                shortsURL:
                                                                    shortsURL,
                                                              )),
                                                        ),
                                                      )
                                                          .then((value) {
                                                        if (shortsURL != null &&
                                                            shortsURL != '') {
                                                          images.remove(
                                                            shortsURL,
                                                          );
                                                        }
                                                        if (shortsThumbnail !=
                                                                null &&
                                                            shortsThumbnail !=
                                                                '') {
                                                          images.insert(
                                                            0,
                                                            shortsThumbnail,
                                                          );
                                                        }
                                                      });
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        12,
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                NetworkImage(e),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          isImageChanging
                                              ? Container()
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    // e == shortsThumbnail
                                                    //     ? SizedBox(
                                                    //         width: 1,
                                                    //         height: 1,
                                                    //       )
                                                    //     : Padding(
                                                    //         padding:
                                                    //             EdgeInsets.only(
                                                    //           left: width *
                                                    //               0.0125,
                                                    //           top: width *
                                                    //               0.0125,
                                                    //         ),
                                                    //         child: IconButton
                                                    //             .filledTonal(
                                                    //           onPressed:
                                                    //               () async {
                                                    //             await changeProductImage(
                                                    //               e,
                                                    //               images
                                                    //                   .indexOf(
                                                    //                       e),
                                                    //               images,
                                                    //             );
                                                    //           },
                                                    //           icon: Icon(
                                                    //             FeatherIcons
                                                    //                 .camera,
                                                    //             size:
                                                    //                 width * 0.1,
                                                    //           ),
                                                    //           tooltip:
                                                    //               'Change Image',
                                                    //         ),
                                                    //       ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        right: width * 0.0125,
                                                        top: width * 0.0125,
                                                      ),
                                                      child: IconButton
                                                          .filledTonal(
                                                        onPressed: e ==
                                                                shortsThumbnail
                                                            ? () async {
                                                                await confirmDeleteShort();
                                                              }
                                                            : images.length <= 2
                                                                ? () {
                                                                    mySnackBar(
                                                                      context,
                                                                      'Minimum 2 images are required',
                                                                    );
                                                                  }
                                                                : () async {
                                                                    await removeProductImages(
                                                                      images
                                                                          .indexOf(
                                                                        e,
                                                                      ),
                                                                      images,
                                                                    );
                                                                  },
                                                        icon: Icon(
                                                          FeatherIcons.x,
                                                          size: width * 0.1,
                                                        ),
                                                        tooltip: e ==
                                                                shortsThumbnail
                                                            ? 'Remove Short'
                                                            : 'Remove Image',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                      e != shortsThumbnail
                                          ? const SizedBox(
                                              width: 1,
                                              height: 1,
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                images.remove(
                                                  shortsThumbnail,
                                                );
                                                images.insert(
                                                  0,
                                                  shortsURL,
                                                );

                                                Navigator.of(context)
                                                    .push(
                                                  MaterialPageRoute(
                                                    builder: ((context) =>
                                                        ImageView(
                                                          imagesUrl: images,
                                                          shortsThumbnail:
                                                              shortsThumbnail,
                                                          shortsURL: shortsURL,
                                                        )),
                                                  ),
                                                )
                                                    .then((value) {
                                                  images.remove(
                                                    shortsURL,
                                                  );
                                                  images.insert(
                                                    0,
                                                    shortsThumbnail,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                width: width * 0.2,
                                                height: width * 0.2,
                                                decoration: BoxDecoration(
                                                  color: white.withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.play_arrow_rounded,
                                                  color: white,
                                                  size: width * 0.2,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                )
                                .toList(),
                            options: CarouselOptions(
                              enableInfiniteScroll:
                                  images.length > 1 ? true : false,
                              aspectRatio: 1.2,
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                            ),
                          ),

                          // DOTS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(),
                              images.length > 1
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: width * 0.033,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: (images).map((e) {
                                          int index = images.indexOf(e);

                                          return Container(
                                            width:
                                                _currentIndex == index ? 12 : 8,
                                            height:
                                                _currentIndex == index ? 12 : 8,
                                            margin: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _currentIndex == index
                                                  ? primaryDark
                                                  : primary2,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  : const SizedBox(height: 40),
                              images.length - (maxImages ?? 0) == 0
                                  ? Text(
                                      'Max. $maxImages images',
                                      style: TextStyle(
                                        fontSize: width * 0.025,
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        await addProductImages(images);
                                      },
                                      child: Container(
                                        height: width * 0.1,
                                        decoration: BoxDecoration(
                                          color: primary,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Add Image',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Icon(FeatherIcons.plus),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),

                          const Divider(),

                          // NAME
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.0225,
                                ),
                                child: SizedBox(
                                  width: width * 0.785,
                                  child: Text(
                                    name,
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: primaryDark,
                                      fontSize: width * 0.06,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await edit(
                                    'productName',
                                    1,
                                    false,
                                    true,
                                  );
                                },
                                icon: Icon(
                                  FeatherIcons.edit,
                                  size: width * 0.066,
                                ),
                                tooltip: 'Edit Name',
                              ),
                            ],
                          ),

                          const Divider(),

                          // PRICE
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // PRICE
                              isDiscount
                                  ? StreamBuilder(
                                      stream: discountPriceStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Text(
                                              'Something went wrong',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }

                                        if (snapshot.hasData) {
                                          final priceSnap = snapshot.data!;
                                          Map<String, dynamic> data = {};
                                          for (QueryDocumentSnapshot<
                                                  Map<String, dynamic>> doc
                                              in priceSnap.docs) {
                                            data = doc.data();
                                          }

                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.0225,
                                                ),
                                                child: price == '' ||
                                                        price == 'N/A'
                                                    ? const Text(
                                                        'N/A',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )
                                                    : RichText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        text: TextSpan(
                                                          text: 'Rs. ',
                                                          style:
                                                              const TextStyle(
                                                            color: primaryDark,
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: data[
                                                                      'isPercent']
                                                                  ? '${price * (100 - (data['discountAmount'])) / 100}  '
                                                                  : '${price - (data['discountAmount'])}  ',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: price
                                                                  .toStringAsFixed(
                                                                2,
                                                              ),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                                color: Color
                                                                    .fromRGBO(
                                                                  255,
                                                                  134,
                                                                  125,
                                                                  1,
                                                                ),
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.0266,
                                                ),
                                                child: data['isPercent']
                                                    ? Text(
                                                        '${data['discountAmount']}% off',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      )
                                                    : Text(
                                                        'Save Rs. ${data['discountAmount']}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.0275,
                                                  vertical: width * 0.0055,
                                                ),
                                                child: Text(
                                                  (data['discountEndDateTime']
                                                                  as Timestamp)
                                                              .toDate()
                                                              .difference(
                                                                  DateTime
                                                                      .now())
                                                              .inHours <
                                                          24
                                                      ? '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours Left'''
                                                      : '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days Left''',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      })
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.02775,
                                          ),
                                          child: Text(
                                            'Rs. ${productData['productPrice']}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.06125,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        MyTextButton(
                                          onPressed: () async {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: ((context) =>
                                                    ProductDiscountPage(
                                                      changeSelectedProductDiscount:
                                                          true,
                                                      changeSelectedProductDiscountId:
                                                          productData[
                                                              'productId'],
                                                      changeSelectedProductDiscountName:
                                                          productData[
                                                              'productName'],
                                                    )),
                                              ),
                                            );
                                          },
                                          text: 'Add Discount',
                                          textColor: primaryDark2,
                                        ),
                                      ],
                                    ),

                              // EDIT PRICE
                              IconButton(
                                onPressed: () async {
                                  await edit(
                                    'productPrice',
                                    1,
                                    false,
                                    false,
                                  );
                                },
                                icon: const Icon(
                                  FeatherIcons.edit,
                                  color: primaryDark,
                                ),
                                tooltip: 'Edit Price',
                              ),
                            ],
                          ),

                          const Divider(),

                          // AVAILABLE / OUT OF STOCK
                          Container(
                            width: width,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: width * 0.0225,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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

                          const Divider(),

                          // DESCRIPTION
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.0166,
                              horizontal: width * 0.0166,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: width * 0.0225,
                                horizontal: width * 0.0225,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: width * 0.75,
                                    child: Text(
                                      description != null && description != ''
                                          ? description
                                          : 'No Description',
                                      maxLines: 20,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontSize: width * 0.0575,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  // CHANGE DESCRIPTION
                                  IconButton(
                                    onPressed: () async {
                                      await edit(
                                        'productDescription',
                                        1,
                                        false,
                                        true,
                                      );
                                    },
                                    icon: const Icon(FeatherIcons.edit),
                                    tooltip: 'Change Description',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(),

                          // CATEGORY
                          category.isEmpty
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: width * 0.0166,
                                    horizontal: width * 0.0166,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: width * 0.0225,
                                      horizontal: width * 0.0225,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: ((context) =>
                                                    CategoryPage(
                                                      categoryName: productData[
                                                          'categoryName'],
                                                    )),
                                              ),
                                            );
                                          },
                                          customBorder: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          splashColor: primary2,
                                          child: Row(
                                            children: [
                                              // CATEGORY IMAGE
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  4,
                                                ),
                                                child: Image.network(
                                                  productData['categoryName'] !=
                                                          '0'
                                                      ? category['imageUrl']
                                                      : 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                                  fit: BoxFit.cover,
                                                  width: productData[
                                                              'categoryName'] !=
                                                          '0'
                                                      ? width * 0.14
                                                      : width * 0.1,
                                                  height: productData[
                                                              'categoryName'] !=
                                                          '0'
                                                      ? width * 0.14
                                                      : width * 0.1,
                                                ),
                                              ),
                                              SizedBox(width: width * 0.05),
                                              // CATEGORY NAME
                                              SizedBox(
                                                width: width * 0.4,
                                                child: AutoSizeText(
                                                  productData['categoryName'] ==
                                                          '0'
                                                      ? 'No Category'
                                                      : productData[
                                                          'categoryName'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: width * 0.0575,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // CHANGE CATEGORY
                                        IconButton(
                                          onPressed: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: ((context) =>
                                                    ChangeProductCategoryPage(
                                                      productId: productData[
                                                          'productId'],
                                                      shopTypes:
                                                          category['shopTypes'],
                                                      productName: productData[
                                                          'productName'],
                                                    )),
                                              ),
                                            );
                                            await getCategoryInfo();
                                            setState(() {});
                                          },
                                          icon: const Icon(FeatherIcons.edit),
                                          tooltip: 'Change Category',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                          const Divider(),

                          // BRAND
                          InfoBox(
                            text: 'Brand',
                            value: brand,
                          ),

                          const Divider(),

                          // PROPERTY 0
                          propertyName0 != '0' &&
                                  propertyName0 != '1' &&
                                  propertyName0 != '2'
                              ? InfoEditBox(
                                  head: propertyName0,
                                  content: propertyValue0.isNotEmpty
                                      ? propertyValue0[0]
                                      : 'N/A',
                                  noOfAnswers: propertyNoOfAnswers0,
                                  propertyValue: propertyValue0,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue0',
                                      propertyNoOfAnswers0,
                                      true,
                                      propertyInputType0,
                                    );
                                  },
                                )
                              : Container(),

                          // PROPERTY 1
                          propertyName1 != '0' &&
                                  propertyName1 != '1' &&
                                  propertyName1 != '2'
                              ? InfoEditBox(
                                  head: propertyName1,
                                  content: propertyValue1.isNotEmpty
                                      ? propertyValue1[0]
                                      : 'N/A',
                                  noOfAnswers: propertyNoOfAnswers1,
                                  propertyValue: propertyValue1,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue1',
                                      propertyNoOfAnswers1,
                                      true,
                                      propertyInputType1,
                                    );
                                  },
                                )
                              : Container(),

                          // PROPERTY 2
                          propertyName2 != '0' &&
                                  propertyName2 != '1' &&
                                  propertyName2 != '2'
                              ? InfoEditBox(
                                  head: propertyName2,
                                  content: propertyValue2.isNotEmpty
                                      ? propertyValue2[0]
                                      : 'N/A',
                                  noOfAnswers: propertyNoOfAnswers2,
                                  propertyValue: propertyValue2,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue2',
                                      propertyNoOfAnswers2,
                                      true,
                                      propertyInputType2,
                                    );
                                  },
                                )
                              : Container(),

                          // PROPERTY 3
                          propertyName3 != '0' &&
                                  propertyName3 != '1' &&
                                  propertyName3 != '2'
                              ? InfoEditBox(
                                  head: propertyName3,
                                  content: propertyValue3.isNotEmpty
                                      ? propertyValue3[0]
                                      : 'N/A',
                                  propertyValue: propertyValue3,
                                  noOfAnswers: propertyNoOfAnswers3,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue3',
                                      propertyNoOfAnswers3,
                                      true,
                                      propertyInputType3,
                                    );
                                  },
                                )
                              : Container(),

                          // PROPERTY 4
                          propertyName4 != '0' &&
                                  propertyName4 != '1' &&
                                  propertyName4 != '2'
                              ? InfoEditBox(
                                  head: propertyName4,
                                  content: propertyValue4.isNotEmpty
                                      ? propertyValue4[0]
                                      : 'N/A',
                                  propertyValue: propertyValue4,
                                  noOfAnswers: propertyNoOfAnswers4,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue4',
                                      propertyNoOfAnswers4,
                                      true,
                                      propertyInputType4,
                                    );
                                  },
                                )
                              : Container(),

                          // PROPERTY 5
                          propertyName5 != '0' &&
                                  propertyName5 != '1' &&
                                  propertyName5 != '2'
                              ? InfoEditBox(
                                  head: propertyName5,
                                  content: propertyValue5.isNotEmpty
                                      ? propertyValue5[0]
                                      : 'N/A',
                                  propertyValue: propertyValue5,
                                  noOfAnswers: propertyNoOfAnswers5,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue5',
                                      propertyNoOfAnswers5,
                                      true,
                                      propertyInputType5,
                                    );
                                  },
                                )
                              : Container(),

                          propertyName0 != '' ||
                                  propertyName1 != '' ||
                                  propertyName2 != '' ||
                                  propertyName3 != '' ||
                                  propertyName4 != '' ||
                                  propertyName5 != ''
                              ? const Divider()
                              : Container(),

                          // TAGS
                          InfoEditBox(
                            head: 'Tags',
                            content: tags,
                            propertyValue: tags,
                            noOfAnswers: 3,
                            width: width,
                            onPressed: () async {
                              await edit(
                                'Tags',
                                3,
                                false,
                                true,
                              );
                            },
                          ),

                          const Divider(),

                          // LIKES & VIEWS
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // LIKES
                                InfoColorBox(
                                  text: 'LIKES',
                                  width: width,
                                  property: likes,
                                  color: const Color.fromRGBO(189, 225, 255, 1),
                                ), // VIEWS
                                InfoColorBox(
                                  text: 'VIEWS',
                                  width: width,
                                  property: views.length,
                                  color: const Color.fromRGBO(255, 248, 184, 1),
                                ),
                              ],
                            ),
                          ),

                          // SHARES & SHARES
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // SHARES
                                InfoColorBox(
                                  text: 'SHARES',
                                  width: width,
                                  property: shares,
                                  color: const Color.fromRGBO(193, 255, 195, 1),
                                ), // WISHLIST
                                InfoColorBox(
                                  text: 'WISHLIST',
                                  width: width,
                                  property: wishList.length,
                                  color: const Color.fromRGBO(255, 176, 170, 1),
                                ),
                              ],
                            ),
                          ),

                          // VIEW ALL INSIGHTS
                          Padding(
                            padding: EdgeInsets.only(
                              top: width * 0.0125,
                              bottom: width * 0.0125,
                              left: width * 0.025,
                            ),
                            child: InkWell(
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              radius: width * 0.2,
                              splashColor: primary2,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: ((context) =>
                                        const AnalyticsPage()),
                                  ),
                                );
                              },
                              child: Container(
                                width: width * 0.95,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: width * 0.033,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width * 0.5,
                                        child: Text(
                                          'View All Products Insights',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: primaryDark2,
                                            fontSize: width * 0.04,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        FeatherIcons.chevronRight,
                                        size: width * 0.095,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(
                        color: primaryDark,
                      ),
                    );
                  }),
            );
          }),
        ),
      ),
    );
  }
}
