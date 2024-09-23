import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/add/brand/select_products_for_brand_page.dart';
import 'package:Localsearch/vendors/page/main/profile/data/all_brand_page.dart';
import 'package:Localsearch/vendors/page/main/profile/view%20page/product/product_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/button.dart';
import 'package:Localsearch/widgets/image_pick_dialog.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class BrandPage extends StatefulWidget {
  const BrandPage({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.imageUrl,
  });

  final String brandId;
  final String brandName;
  final String? imageUrl;

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  final brandNameKey = GlobalKey<FormState>();
  bool isImageChanging = false;
  bool isChangingName = false;
  bool isGridView = true;
  bool isDiscount = false;

  // INIT STATE
  @override
  void initState() {
    ifDiscount();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // CHANGE BRAND IMAGE
  Future<void> changeBrandImage({String? imageUrl}) async {
    final images = await showImagePickDialog(context, true);
    if (images.isNotEmpty) {
      final im = images[0];
      String? imageDownloadUrl;
      try {
        setState(() {
          isImageChanging = true;
        });
        if (imageUrl != null) {
          Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
          await ref.putFile(File(im.path));
        } else {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('Vendor/Brand')
              .child(widget.brandId);
          await ref.putFile(File(im.path)).whenComplete(() async {
            await ref.getDownloadURL().then((value) {
              setState(() {
                imageDownloadUrl = value;
              });
            });
          });

          await store
              .collection('Business')
              .doc('Data')
              .collection('Brands')
              .doc(widget.brandId)
              .update({
            'imageUrl': imageDownloadUrl,
          });
        }
        setState(() {
          isImageChanging = false;
        });
        // Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          isImageChanging = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  // REMOVE BRAND IMAGE
  Future<void> removeBrandImage(String imageUrl) async {
    await FirebaseStorage.instance.refFromURL(imageUrl).delete();

    await store
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .doc(widget.brandId)
        .update({
      'imageUrl': null,
    });
  }

  // BRAND NAME CHANGE BACKEND
  Future<void> changeBrandName(String newName) async {
    if (brandNameKey.currentState!.validate()) {
      try {
        setState(() {
          isChangingName = true;
        });
        await store
            .collection('Business')
            .doc('Data')
            .collection('Brands')
            .doc(widget.brandId)
            .update({
          'brandName': newName,
        });
        setState(() {
          isChangingName = false;
        });
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  // BRAND NAME CHANGE
  Future<void> changeName() async {
    await showDialog(
      context: context,
      builder: (context) {
        final propertyStream = store
            .collection('Business')
            .doc('Data')
            .collection('Brands')
            .doc(widget.brandId)
            .snapshots();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: SizedBox(
            height: 180,
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
                  final brandData = snapshot.data!;
                  String brandName = brandData['brandName'];

                  return Form(
                    key: brandNameKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextFormField(
                            initialValue: brandName,
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            decoration: const InputDecoration(
                              hintText: 'Brand Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              brandName = value;
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              } else {
                                return 'Enter Brand Name';
                              }
                            },
                          ),
                          MyButton(
                            text: 'SAVE',
                            onTap: () async {
                              await changeBrandName(brandName);
                            },
                            isLoading: isChangingName,
                            horizontalPadding: 0,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // REMOVE PRODUCT
  Future<void> remove(
      String productId, String productName, String brandName) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Remove $productName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          content: Text(
            'Are you sure you want to remove $productName from $brandName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
                try {
                  await store
                      .collection('Business')
                      .doc('Data')
                      .collection('Products')
                      .doc(productId)
                      .update({
                    'productBrandId': '0',
                    'productBrand': 'No Brand',
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    mySnackBar(context, e.toString());
                  }
                }
              },
              text: 'YES',
              textColor: Colors.red,
            ),
          ],
        );
      },
    );
  }

  // IF DISCOUNT
  Future<void> ifDiscount() async {
    final discount = await store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in discount.docs) {
      final data = doc.data();
      if ((data['brands'] as List).contains(widget.brandId)) {
        if ((data['discountEndDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now()) &&
            !(data['discountStartDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now())) {
          setState(() {
            isDiscount = true;
          });
        }
      }
    }
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
            'Are you sure you want to delete this Brand\nProducts in this brand will be set as \'No Brand\'',
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
                await delete();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
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

  // DELETE BRAND
  Future<void> delete() async {
    try {
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (widget.imageUrl != null) {
        await FirebaseStorage.instance.refFromURL(widget.imageUrl!).delete();
      }
      final productSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .where('vendorId', isEqualTo: auth.currentUser!.uid)
          .where('productBrandId', isEqualTo: widget.brandId)
          .get();

      for (final doc in productSnap.docs) {
        await doc.reference.update(
          {
            'productBrand': 'No Brand',
            'productBrandId': '0',
          },
        );
      }

      await store
          .collection('Business')
          .doc('Data')
          .collection('Brands')
          .doc(widget.brandId)
          .delete();

      if (mounted) {
        Navigator.of(context).pop();
        mySnackBar(context, 'Brand Deleted');
      }
    } catch (e) {
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // BRAND STREAM
    final Stream<DocumentSnapshot<Map<String, dynamic>>> brandStream = store
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .doc(widget.brandId)
        .snapshots();

    // PRODUCT STREAM
    final allProductStream = store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where('productBrand', isEqualTo: widget.brandName)
        .orderBy('productName')
        .where('productName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('productName', isLessThan: '${searchController.text}\uf8ff')
        .orderBy('datetime', descending: true)
        .snapshots();

    // DISCOUNT STREAM
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
                  MaterialPageRoute(builder: (context) => const AllBrandPage()),
                );
              }
            },
            icon: const Icon(
              FeatherIcons.trash,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(builder: ((context, constraints) {
        double width = constraints.maxWidth;

        return SingleChildScrollView(
          child: StreamBuilder(
            stream: brandStream,
            builder: ((context, snapshot) {
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
                final brandData = snapshot.data!;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IMAGE
                      brandData['imageUrl'] != null
                          ? Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  width: width,
                                  height: width,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: primaryDark2,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: isImageChanging
                                      ? const CircularProgressIndicator()
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: brandData['imageUrl'],
                                            imageBuilder:
                                                (context, imageProvider) {
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                ),
                                // IMAGE CHANGING INDICATOR
                                isImageChanging
                                    ? Container()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // CHANGE IMAGE
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: width * 0.0125,
                                              top: width * 0.0125,
                                            ),
                                            child: IconButton.filledTonal(
                                              onPressed: () async {
                                                await changeBrandImage();
                                              },
                                              icon: Icon(
                                                FeatherIcons.camera,
                                                size: width * 0.1,
                                              ),
                                              tooltip: 'Change Image',
                                            ),
                                          ),
                                          // REMOVE IMAGE
                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: width * 0.0125,
                                              top: width * 0.0125,
                                            ),
                                            child: IconButton.filledTonal(
                                              onPressed: () async {
                                                await removeBrandImage(
                                                  brandData['imageUrl'],
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
                              ],
                            )
                          : Center(
                              child: MyTextButton(
                                onPressed: () async {
                                  await changeBrandImage();
                                },
                                text: 'Add Image',
                                textColor: primaryDark2,
                              ),
                            ),
                      const SizedBox(height: 40),

                      // NAME
                      Container(
                        width: width,
                        padding: EdgeInsets.symmetric(
                          vertical: width * 0.025,
                          horizontal: width * 0.0,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              brandData['brandName'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryDark,
                                fontSize: width * 0.0725,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await changeName();
                              },
                              icon: Icon(
                                FeatherIcons.edit,
                                size: width * 0.0725,
                                color: primaryDark,
                              ),
                              tooltip: 'Change Name',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // DISCOUNT
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: width * 0.01),
                                        child: data['isPercent']
                                            ? Text(
                                                '${data['discountAmount']}% off',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            : Text(
                                                'Save Rs. ${data['discountAmount']}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.01,
                                          vertical: width * 0.00625,
                                        ),
                                        child: Text(
                                          (data['discountEndDateTime']
                                                          as Timestamp)
                                                      .toDate()
                                                      .difference(
                                                          DateTime.now())
                                                      .inHours <
                                                  24
                                              ? '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours Left'''
                                              : '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days Left''',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: width * 0.01,
                                          top: width * 0.025,
                                        ),
                                        child: const Text(
                                          'This discount is available to all the products within this brand',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: primaryDark,
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
                          : Container(),
                      const SizedBox(height: 28),

                      // ADD PRODUCTS
                      MyButton(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) => AddProductsToBrandPage(
                                    isFromBrandPage: true,
                                    brandId: brandData['brandId'],
                                    brandName: brandData['brandName'],
                                  )),
                            ),
                          );
                        },
                        text: 'ADD PRODUCT',
                        isLoading: false,
                        horizontalPadding: 0,
                      ),
                      const SizedBox(height: 28),

                      // PRODUCTS IN BRAND
                      ExpansionTile(
                        initiallyExpanded: true,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                        backgroundColor: primary2.withOpacity(0.25),
                        collapsedBackgroundColor: primary2.withOpacity(0.33),
                        textColor: primaryDark.withOpacity(0.9),
                        collapsedTextColor: primaryDark,
                        iconColor: primaryDark2.withOpacity(0.9),
                        collapsedIconColor: primaryDark2,
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primaryDark.withOpacity(0.1),
                          ),
                        ),
                        collapsedShape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primaryDark.withOpacity(0.33),
                          ),
                        ),
                        title: Text(
                          'Products',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              isGridView = !isGridView;
                            });
                          },
                          icon: Icon(
                            isGridView ? FeatherIcons.list : FeatherIcons.grid,
                          ),
                          tooltip: isGridView ? 'List View' : 'Grid View',
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.0125,
                              vertical: width * 0.0125,
                            ),
                            child: StreamBuilder(
                              stream: allProductStream,
                              builder: ((context, snapshot) {
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
                                  return SafeArea(
                                    child: isGridView
                                        // PRODUCTS IN GRIDVIEW
                                        ? GridView.builder(
                                            shrinkWrap: true,
                                            physics: ClampingScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio:
                                                  width * 0.425 / width * 1.5,
                                            ),
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: (context, index) {
                                              final productData =
                                                  snapshot.data!.docs[index];

                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: ((context) =>
                                                          ProductPage(
                                                            productId:
                                                                productData[
                                                                    'productId'],
                                                            productName:
                                                                productData[
                                                                    'productName'],
                                                          )),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: white,
                                                    border: Border.all(
                                                      width: 0.25,
                                                      color: primaryDark,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      2,
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.all(
                                                    width * 0.00625,
                                                  ),
                                                  margin: EdgeInsets.all(
                                                    width * 0.00625,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Center(
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            2,
                                                          ),
                                                          child: Image.network(
                                                            productData[
                                                                'images'][0],
                                                            width: width * 0.5,
                                                            height: width * 0.5,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                  width *
                                                                      0.0125,
                                                                  width *
                                                                      0.0125,
                                                                  width *
                                                                      0.0125,
                                                                  0,
                                                                ),
                                                                child: SizedBox(
                                                                  width: width *
                                                                      0.275,
                                                                  child: Text(
                                                                    productData[
                                                                        'productName'],
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          width *
                                                                              0.05,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                  width *
                                                                      0.0125,
                                                                  0,
                                                                  width *
                                                                      0.0125,
                                                                  0,
                                                                ),
                                                                child: SizedBox(
                                                                  width: width *
                                                                      0.275,
                                                                  child: Text(
                                                                    'Rs. ${productData['productPrice']}',
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          width *
                                                                              0.04,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          IconButton(
                                                            onPressed:
                                                                () async {
                                                              await remove(
                                                                productData[
                                                                    'productId'],
                                                                productData[
                                                                    'productName'],
                                                                widget
                                                                    .brandName,
                                                              );
                                                            },
                                                            icon: Icon(
                                                              FeatherIcons
                                                                  .trash,
                                                              color: const Color
                                                                  .fromARGB(
                                                                255,
                                                                215,
                                                                14,
                                                                0,
                                                              ),
                                                              size:
                                                                  width * 0.075,
                                                            ),
                                                            tooltip:
                                                                'Remove Product',
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            })
                                        // PRODUCTS IN LISTVIEW
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics: ClampingScrollPhysics(),
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: ((context, index) {
                                              final productData =
                                                  snapshot.data!.docs[index];
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.000625,
                                                  vertical: width * 0.02,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: ((context) =>
                                                            ProductPage(
                                                              productId:
                                                                  productData[
                                                                      'productId'],
                                                              productName:
                                                                  productData[
                                                                      'productName'],
                                                            )),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: white,
                                                      border: Border.all(
                                                        width: 0.5,
                                                        color: primaryDark,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        2,
                                                      ),
                                                    ),
                                                    child: ListTile(
                                                      leading: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          4,
                                                        ),
                                                        child: Image.network(
                                                          productData['images']
                                                              [0],
                                                          width: width * 0.15,
                                                          height: width * 0.15,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        productData[
                                                            'productName'],
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.0525,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        'Rs. ${productData['productPrice']}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.035,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      trailing: IconButton(
                                                        onPressed: () async {
                                                          await remove(
                                                            productData[
                                                                'productId'],
                                                            productData[
                                                                'productName'],
                                                            widget.brandName,
                                                          );
                                                        },
                                                        icon: Icon(
                                                          FeatherIcons.trash,
                                                          color: const Color
                                                              .fromRGBO(
                                                            215,
                                                            14,
                                                            0,
                                                            1,
                                                          ),
                                                          size: width * 0.08,
                                                        ),
                                                        tooltip:
                                                            'Remove Product',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                  );
                                }

                                return SafeArea(
                                  child: isGridView
                                      ? GridView.builder(
                                          shrinkWrap: true,
                                          physics: ClampingScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 0,
                                            mainAxisSpacing: 0,
                                            childAspectRatio:
                                                width * 0.5 / width * 1.45,
                                          ),
                                          itemCount: 4,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: width * 0.02,
                                                horizontal: width * 0.006,
                                              ),
                                              child: GridViewSkeleton(
                                                width: width,
                                                isPrice: true,
                                                isDelete: true,
                                              ),
                                            );
                                          },
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: ClampingScrollPhysics(),
                                          itemCount: 4,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.all(
                                                width * 0.02,
                                              ),
                                              child: ListViewSkeleton(
                                                width: width,
                                                isPrice: true,
                                                height: 30,
                                                isDelete: true,
                                              ),
                                            );
                                          },
                                        ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
          ),
        );
      })),
    );
  }
}
