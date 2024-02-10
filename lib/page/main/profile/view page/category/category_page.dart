import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/add/category/category_products_add_page.dart';
import 'package:find_easy/page/main/profile/view%20page/product/product_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  final categoryNameKey = GlobalKey<FormState>();
  bool isImageChanging = false;
  bool isFit = false;
  bool isChangingName = false;
  bool isGridView = true;
  bool isDiscount = false;

  @override
  void initState() {
    ifDiscount();
    super.initState();
  }

  // CHANGE CATEGORY IMAGE
  void changeCategoryImage(String imageUrl) async {
    final XFile? im =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (im != null) {
      try {
        setState(() {
          isImageChanging = true;
        });
        Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.putFile(File(im.path));
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

  // CATEGORY NAME CHANGE BACKEND
  void changeCategoryName(String newName) async {
    if (categoryNameKey.currentState!.validate()) {
      try {
        setState(() {
          isChangingName = true;
        });
        await store
            .collection('Business')
            .doc('Data')
            .collection('Category')
            .doc(widget.categoryId)
            .update({
          'categoryName': newName,
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

  // CATEGORY NAME CHANGE
  void changeName() {
    showDialog(
      context: context,
      builder: (context) {
        final propertyStream = FirebaseFirestore.instance
            .collection('Business')
            .doc('Data')
            .collection('Category')
            .doc(widget.categoryId)
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
                    child: Text('Something went wrong'),
                  );
                }

                if (snapshot.hasData) {
                  final categoryData = snapshot.data!;
                  String categoryName = categoryData['categoryName'];

                  return Form(
                    key: categoryNameKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextFormField(
                            initialValue: categoryName,
                            decoration: const InputDecoration(
                              hintText: "Category Name",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              categoryName = value;
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              } else {
                                return "Enter Category Name";
                              }
                            },
                          ),
                          MyButton(
                            text: "SAVE",
                            onTap: () {
                              changeCategoryName(categoryName);
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
  void remove(String productId, String productName, String categoryName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Remove $productName"),
          content: Text(
              'Are you sure you want to remove $productName from $categoryName'),
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
                    'categoryId': '0',
                    'categoryName': 'No Category Selected',
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
      print((data['categories'] as List).contains(widget.categoryId));
      print("ABC");
      if ((data['categories'] as List).contains(widget.categoryId)) {
        print("DEF");
        if ((data['discountEndDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now()) &&
            !(data['discountStartDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now())) {
          setState(() {
            isDiscount = true;
          });
          print(isDiscount);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // CATEGORY STREAM
    final Stream<DocumentSnapshot<Map<String, dynamic>>> categoryStream = store
        .collection('Business')
        .doc('Data')
        .collection('Category')
        .doc(widget.categoryId)
        .snapshots();

    // PRODUCT STREAM
    final allProductStream = store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where('categoryId', isEqualTo: widget.categoryId)
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
            stream: categoryStream,
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong'),
                );
              }

              if (snapshot.hasData) {
                final categoryData = snapshot.data!;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IMAGE
                      Stack(
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
                                    child: Image.network(
                                      categoryData['imageUrl'],
                                      fit: isFit ? BoxFit.cover : null,
                                      width: width,
                                      height: width,
                                    ),
                                  ),
                          ),
                          // IMAGE CHANGING INDICATOR
                          isImageChanging
                              ? Container()
                              : Padding(
                                  padding:
                                      const EdgeInsets.only(right: 4, top: 4),
                                  child: IconButton.filledTonal(
                                    onPressed: () {
                                      changeCategoryImage(
                                        categoryData['imageUrl'],
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 36,
                                    ),
                                    tooltip: "Change Image",
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // NAME
                      Container(
                        width: width,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
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
                              categoryData['categoryName'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: primaryDark,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                changeName();
                              },
                              icon: const Icon(
                                Icons.edit,
                                size: 24,
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
                                  return Center(
                                    child: Text('Something Went Wrong'),
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
                                            const EdgeInsets.only(left: 10),
                                        child: data['isPercent']
                                            ? Text(
                                                "${data['discountAmount']}% off",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            : Text(
                                                "Save Rs. ${data['discountAmount']}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 2,
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
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          top: 8,
                                        ),
                                        child: Text(
                                          "This discount is available to all the products within this category",
                                          style: TextStyle(
                                            color: primaryDark,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return Center(
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
                              builder: ((context) => AddProductsToCategoryPage(
                                    categoryId: widget.categoryId,
                                    categoryName: widget.categoryName,
                                    fromAddCategoryPage: false,
                                  )),
                            ),
                          );
                        },
                        text: "ADD PRODUCT",
                        isLoading: false,
                        horizontalPadding: 0,
                      ),
                      const SizedBox(height: 28),

                      // PRODUCTS IN CATEGORY
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
                        title: const Text(
                          'Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
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
                                        child: Text("Something went wrong"),
                                      );
                                    }

                                    if (snapshot.hasData) {
                                      return SafeArea(
                                        child: isGridView
                                            // PRODUCTS IN GRIDVIEW
                                            ? GridView.builder(
                                                shrinkWrap: true,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 0,
                                                  mainAxisSpacing: 0,
                                                  childAspectRatio: 175 / 250,
                                                ),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: (context, index) {
                                                  final productData = snapshot
                                                      .data!.docs[index];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
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
                                                              const EdgeInsets
                                                                  .all(4),
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
                                                                              12),
                                                                  child: Image
                                                                      .network(
                                                                    productData[
                                                                        'images'][0],
                                                                    height:
                                                                        width *
                                                                            0.4,
                                                                    width:
                                                                        width *
                                                                            0.4,
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
                                                                            const EdgeInsets.fromLTRB(
                                                                          8,
                                                                          4,
                                                                          4,
                                                                          0,
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          productData[
                                                                              'productName'],
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                20,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .fromLTRB(
                                                                            8,
                                                                            0,
                                                                            4,
                                                                            0),
                                                                        child:
                                                                            Text(
                                                                          productData['productPrice'] != "" && productData['productPrice'] != null
                                                                              ? productData['productPrice']
                                                                              : "N/A",
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
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
                                                                            .categoryName,
                                                                      );
                                                                    },
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .delete_forever,
                                                                      color: Color
                                                                          .fromARGB(
                                                                        255,
                                                                        215,
                                                                        14,
                                                                        0,
                                                                      ),
                                                                      size: 32,
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
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 2,
                                                      vertical: 8,
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
                                                                        4),
                                                            child:
                                                                Image.network(
                                                              productData[
                                                                  'images'][0],
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          title: Text(
                                                            productData[
                                                                'productName'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            productData['productPrice'] !=
                                                                        "" &&
                                                                    productData[
                                                                            'productPrice'] !=
                                                                        null
                                                                ? productData[
                                                                    'productPrice']
                                                                : "N/A",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
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
                                                                    .categoryName,
                                                              );
                                                            },
                                                            icon: const Icon(
                                                              Icons
                                                                  .delete_forever,
                                                              color: Color
                                                                  .fromARGB(
                                                                255,
                                                                215,
                                                                14,
                                                                0,
                                                              ),
                                                              size: 32,
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
