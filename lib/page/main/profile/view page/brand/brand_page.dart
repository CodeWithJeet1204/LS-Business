import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/add/brand/add_products_to_brand_page.dart';
import 'package:find_easy/page/main/profile/view%20page/product/product_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/image_pick_dialog.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BrandPage extends StatefulWidget {
  const BrandPage({
    super.key,
    required this.brandId,
    required this.brandName,
  });

  final String brandId;
  final String brandName;

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  final brandNameKey = GlobalKey<FormState>();
  bool isImageChanging = false;
  bool isFit = false;
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
  void changeBrandImage({String? imageUrl}) async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
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
              .child('Data/Brand')
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
        if (context.mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      if (context.mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  // REMOVE BRAND IMAGE
  void removeBrandImage(String imageUrl) async {
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
  void changeBrandName(String newName) async {
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
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  // BRAND NAME CHANGE
  void changeName() {
    showDialog(
      context: context,
      builder: (context) {
        final propertyStream = FirebaseFirestore.instance
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
                        overflow: TextOverflow.ellipsis,
                        'Something went wrong'),
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
                            decoration: const InputDecoration(
                              hintText: "Brand Name",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              brandName = value;
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              } else {
                                return "Enter Brand Name";
                              }
                            },
                          ),
                          MyButton(
                            text: "SAVE",
                            onTap: () {
                              changeBrandName(brandName);
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

  // IMAGE FIT CHANGE
  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  // REMOVE PRODUCT
  void remove(String productId, String productName, String brandName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(overflow: TextOverflow.ellipsis, "Remove $productName"),
          content: Text(
              overflow: TextOverflow.ellipsis,
              'Are you sure you want to remove $productName from $brandName'),
          actions: [
            MyTextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: "NO",
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
                    'productBrandId': "0",
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
              text: "YES",
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
      appBar: AppBar(),
      body: LayoutBuilder(builder: ((context, constraints) {
        double width = constraints.maxWidth;

        return SingleChildScrollView(
          child: StreamBuilder(
            stream: brandStream,
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                      overflow: TextOverflow.ellipsis, 'Something went wrong'),
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
                                      : GestureDetector(
                                          onTap: changeFit,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: InteractiveViewer(
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
                                                          fit: isFit
                                                              ? BoxFit.cover
                                                              : null,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          // child: Image.network(
                                          //   brandData['imageUrl'],
                                          //   fit: isFit ? BoxFit.cover : null,
                                          //   width: width,
                                          //   height: width,
                                          // ),
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
                                              onPressed: changeBrandImage,
                                              icon: Icon(
                                                Icons.camera_alt_outlined,
                                                size: width * 0.1,
                                              ),
                                              tooltip: "Change Image",
                                            ),
                                          ),
                                          // REMOVE IMAGE
                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: width * 0.0125,
                                              top: width * 0.0125,
                                            ),
                                            child: IconButton.filledTonal(
                                              onPressed: () {
                                                removeBrandImage(
                                                  brandData['imageUrl'],
                                                );
                                              },
                                              icon: Icon(
                                                Icons.highlight_remove_rounded,
                                                size: width * 0.1,
                                              ),
                                              tooltip: "Remove Image",
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            )
                          : Container(
                              width: width,
                              height: width,
                              child: MyTextButton(
                                onPressed: changeBrandImage,
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
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: primaryDark,
                                fontSize: width * 0.0725,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                changeName();
                              },
                              icon: Icon(
                                Icons.edit,
                                size: width * 0.0725,
                                color: primaryDark,
                              ),
                              tooltip: "Change Name",
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
                                        overflow: TextOverflow.ellipsis,
                                        'Something Went Wrong'),
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
                                                overflow: TextOverflow.ellipsis,
                                                "${data['discountAmount']}% off",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            : Text(
                                                overflow: TextOverflow.ellipsis,
                                                "Save Rs. ${data['discountAmount']}",
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
                                          overflow: TextOverflow.ellipsis,
                                          (data['discountEndDateTime']
                                                          as Timestamp)
                                                      .toDate()
                                                      .difference(
                                                          DateTime.now())
                                                      .inHours <
                                                  24
                                              ? '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours Left'''
                                              : '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days Left''',
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
                                          overflow: TextOverflow.ellipsis,
                                          "This discount is available to all the products within this brand",
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
                        text: "ADD PRODUCT",
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
                          overflow: TextOverflow.ellipsis,
                          'Products',
                          style: TextStyle(
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.0225,
                              vertical: width * 0.02125,
                            ),
                            child: Column(
                              children: [
                                // HEADER
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // TEXTFIELD
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
                                            ? Icons.list
                                            : Icons.grid_view_rounded,
                                      ),
                                      tooltip: isGridView
                                          ? "List View"
                                          : "Grid View",
                                    ),
                                  ],
                                ),

                                // PRODUCTS
                                StreamBuilder(
                                  stream: allProductStream,
                                  builder: ((context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Center(
                                        child: Text(
                                            overflow: TextOverflow.ellipsis,
                                            "Something went wrong"),
                                      );
                                    }

                                    if (snapshot.hasData) {
                                      return SafeArea(
                                        child: isGridView
                                            // PRODUCTS IN GRIDVIEW
                                            ? GridView.builder(
                                                shrinkWrap: true,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 0,
                                                  mainAxisSpacing: 0,
                                                  childAspectRatio:
                                                      width * 0.5 / width * 1.5,
                                                ),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: (context, index) {
                                                  final productData = snapshot
                                                      .data!.docs[index];
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: width * 0.025,
                                                      horizontal:
                                                          width * 0.0125,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                ((context) =>
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primary2
                                                              .withOpacity(
                                                            0.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            12,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                            width * 0.0015,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                height: 2,
                                                              ),
                                                              Center(
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    12,
                                                                  ),
                                                                  child: Image
                                                                      .network(
                                                                    productData[
                                                                        'images'][0],
                                                                    width:
                                                                        width *
                                                                            0.35,
                                                                    height:
                                                                        width *
                                                                            0.35,
                                                                    fit: BoxFit
                                                                        .cover,
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
                                                                            EdgeInsets.fromLTRB(
                                                                          width *
                                                                              0.025,
                                                                          width *
                                                                              0.0125,
                                                                          width *
                                                                              0.0125,
                                                                          0,
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          productData[
                                                                              'productName'],
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                width * 0.058,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            width *
                                                                                0.025,
                                                                            0,
                                                                            width *
                                                                                0.0125,
                                                                            0),
                                                                        child:
                                                                            Text(
                                                                          productData['productPrice'] != "" && productData['productPrice'] != null
                                                                              ? productData['productPrice']
                                                                              : "N/A",
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                width * 0.04,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      remove(
                                                                        productData[
                                                                            'productId'],
                                                                        productData[
                                                                            'productName'],
                                                                        widget
                                                                            .brandName,
                                                                      );
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .delete_forever,
                                                                      color: const Color
                                                                          .fromARGB(
                                                                        255,
                                                                        215,
                                                                        14,
                                                                        0,
                                                                      ),
                                                                      size: width *
                                                                          0.09,
                                                                    ),
                                                                    tooltip:
                                                                        "Remove Product",
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                })
                                            // PRODUCTS IN LISTVIEW
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: ((context, index) {
                                                  final productData = snapshot
                                                      .data!.docs[index];
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          width * 0.000625,
                                                      vertical: width * 0.02,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                ((context) =>
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
                                                              4,
                                                            ),
                                                            child:
                                                                Image.network(
                                                              productData[
                                                                  'images'][0],
                                                              width:
                                                                  width * 0.15,
                                                              height:
                                                                  width * 0.15,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          title: Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            productData[
                                                                'productName'],
                                                            style: TextStyle(
                                                              fontSize: width *
                                                                  0.0525,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            productData['productPrice'] !=
                                                                        "" &&
                                                                    productData[
                                                                            'productPrice'] !=
                                                                        null
                                                                ? productData[
                                                                    'productPrice']
                                                                : "N/A",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width * 0.035,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          trailing: IconButton(
                                                            onPressed: () {
                                                              remove(
                                                                productData[
                                                                    'productId'],
                                                                productData[
                                                                    'productName'],
                                                                widget
                                                                    .brandName,
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .delete_forever,
                                                              color: const Color
                                                                  .fromRGBO(215,
                                                                  14, 0, 1),
                                                              size:
                                                                  width * 0.09,
                                                            ),
                                                            tooltip:
                                                                "Remove Product",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                      );
                                    }

                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: primaryDark,
                                      ),
                                    );
                                  }),
                                )
                              ],
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
