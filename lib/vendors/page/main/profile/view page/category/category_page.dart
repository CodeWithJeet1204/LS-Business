import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/add/category/select_products_for_category_page.dart';
import 'package:localy/vendors/page/main/profile/view%20page/product/product_page.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/shimmer_skeleton_container.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({
    super.key,
    required this.categoryName,
  });

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
  String type = '';
  String categoryName = '';
  String categoryImageUrl = '';
  Map<String, dynamic> currentProducts = {};
  Map<String, dynamic> allProducts = {};
  bool getProductsData = false;
  bool isDiscount = false;

  // INIT STATE
  @override
  void initState() {
    getVendorType();
    ifDiscount();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET VENDOR TYPE
  Future<void> getVendorType() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final shopType = vendorData['Type'];

    setState(() {
      type = shopType;
    });

    await getCategoryInfo(shopType);
  }

  // GET CATEGORY INFO
  Future<void> getCategoryInfo(String type) async {
    final categorySnap = await store
        .collection('Business')
        .doc('Special Categories')
        .collection(type)
        .doc(widget.categoryName)
        .get();

    final categoryData = categorySnap.data()!;

    final name = categoryData['specialCategoryName'];
    final imageUrl = categoryData['specialCategoryImageUrl'];

    setState(() {
      categoryName = name;
      categoryImageUrl = imageUrl;
    });

    await getProductsInfo(type);
  }

  // GET PRODUCTS INFO
  Future<void> getProductsInfo(String type) async {
    Map<String, dynamic> myProducts = {};
    final productsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where('categoryName', isEqualTo: widget.categoryName)
        .get();

    for (var productData in productsSnap.docs) {
      final id = productData.id;
      final name = productData['productName'];
      final imageUrl = productData['images'][0];
      final price = productData['productPrice'];

      myProducts[id] = [name, imageUrl, price];
    }

    setState(() {
      allProducts = myProducts;
      currentProducts = myProducts;
      getProductsData = true;
    });
  }

  // SEARCH PRODUCTS
  void searchProducts(String searchText) {
    setState(() {
      Map<String, dynamic> searchedProducts = {};
      currentProducts.forEach((id, value) {
        if (value[0]
            .toString()
            .toUpperCase()
            .contains(searchText.toUpperCase())) {
          searchedProducts[id] = value;
        }
      });
    });
  }

  // IMAGE FIT CHANGE
  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  // REMOVE PRODUCT
  Future<void> remove(
      String productId, String productName, String categoryName) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Remove $productName',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          content: Text(
            'Are you sure you want to remove \'$productName\'\nfrom $categoryName',
            maxLines: 3,
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
                    'categoryName': '0',
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoryPage(
                          categoryName: widget.categoryName,
                        ),
                      ),
                    );
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
      if ((data['categories'] as List).contains(widget.categoryName)) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  11,
                                ),
                                child: InteractiveViewer(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      11,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            categoryImageUrl,
                                          ),
                                          fit: isFit ? null : BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
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
                        categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryDark,
                          fontSize: width * 0.0725,
                          fontWeight: FontWeight.bold,
                        ),
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
                            for (QueryDocumentSnapshot<Map<String, dynamic>> doc
                                in priceSnap.docs) {
                              data = doc.data();
                            }

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: width * 0.01),
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
                                    (data['discountEndDateTime'] as Timestamp)
                                                .toDate()
                                                .difference(DateTime.now())
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
                                    'This discount is available to all the products within this category',
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
                        builder: ((context) => SelectProductsForCategoryPage(
                              categoryName: widget.categoryName,
                              fromAddCategoryPage: false,
                            )),
                      ),
                    );
                  },
                  text: 'ADD PRODUCT',
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
                  title: Text(
                    'Products',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.0125,
                        vertical: width * 0.02125,
                      ),
                      child: Column(
                        children: [
                          // HEADER
                          Row(
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
                                        currentProducts = Map<String,
                                            Map<String, dynamic>>.from(
                                          allProducts,
                                        );
                                      } else {
                                        Map<String, Map<String, dynamic>>
                                            filteredProducts = Map<String,
                                                Map<String, dynamic>>.from(
                                          allProducts,
                                        );
                                        List<String> keysToRemove = [];

                                        filteredProducts
                                            .forEach((key, productData) {
                                          if (!productData['productName']
                                              .toString()
                                              .toLowerCase()
                                              .contains(
                                                  value.toLowerCase().trim())) {
                                            keysToRemove.add(key);
                                          }
                                        });

                                        for (var key in keysToRemove) {
                                          filteredProducts.remove(key);
                                        }

                                        currentProducts = filteredProducts;
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

                          const SizedBox(height: 4),

                          // PRODUCTS
                          getProductsData
                              ? currentProducts.isEmpty
                                  ? const SizedBox(
                                      height: 60,
                                      child: Center(
                                        child: Text('No Products'),
                                      ),
                                    )
                                  : SafeArea(
                                      child: isGridView
                                          // PRODUCTS IN GRIDVIEW
                                          ? GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const ClampingScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 0.675,
                                              ),
                                              itemCount: currentProducts.length,
                                              itemBuilder: (context, index) {
                                                final id = currentProducts.keys
                                                    .toList()[index];
                                                final name = currentProducts
                                                    .values
                                                    .toList()[index][0];
                                                final imageUrl = currentProducts
                                                    .values
                                                    .toList()[index][1];
                                                final price = currentProducts
                                                    .values
                                                    .toList()[index][2];

                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: ((context) =>
                                                            ProductPage(
                                                              productId: id,
                                                              productName: name,
                                                            )),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: primary2
                                                          .withOpacity(0.125),
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
                                                            child:
                                                                Image.network(
                                                              imageUrl,
                                                              width:
                                                                  width * 0.5,
                                                              height:
                                                                  width * 0.5,
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
                                                                  child:
                                                                      SizedBox(
                                                                    width: width *
                                                                        0.275,
                                                                    child: Text(
                                                                      name,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            width *
                                                                                0.058,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .fromLTRB(
                                                                    width *
                                                                        0.025,
                                                                    0,
                                                                    width *
                                                                        0.0125,
                                                                    0,
                                                                  ),
                                                                  child:
                                                                      SizedBox(
                                                                    width:
                                                                        width *
                                                                            0.25,
                                                                    child: Text(
                                                                      price != '' &&
                                                                              price != null
                                                                          ? 'Rs. $price'
                                                                          : 'N/A',
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          1,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            width *
                                                                                0.04,
                                                                        fontWeight:
                                                                            FontWeight.w600,
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
                                                                  id,
                                                                  name,
                                                                  widget
                                                                      .categoryName,
                                                                );
                                                              },
                                                              icon: Icon(
                                                                FeatherIcons.x,
                                                                color: const Color
                                                                    .fromRGBO(
                                                                  215,
                                                                  14,
                                                                  0,
                                                                  1,
                                                                ),
                                                                size: width *
                                                                    0.075,
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
                                              physics:
                                                  const ClampingScrollPhysics(),
                                              itemCount: currentProducts.length,
                                              itemBuilder: ((context, index) {
                                                final id = currentProducts.keys
                                                    .toList()[index];
                                                final name = currentProducts
                                                    .values
                                                    .toList()[index][0];
                                                final imageUrl = currentProducts
                                                    .values
                                                    .toList()[index][1];
                                                final price = currentProducts
                                                    .values
                                                    .toList()[index][2];

                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        width * 0.000625,
                                                    vertical: width * 0.02,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: ((context) =>
                                                              ProductPage(
                                                                productId: id,
                                                                productName:
                                                                    name,
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
                                                            BorderRadius
                                                                .circular(2),
                                                      ),
                                                      margin: EdgeInsets.all(
                                                        width * 0.0125,
                                                      ),
                                                      child: ListTile(
                                                        leading: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            4,
                                                          ),
                                                          child: Image.network(
                                                            imageUrl,
                                                            width: width * 0.15,
                                                            height:
                                                                width * 0.15,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        title: Text(
                                                          name,
                                                          maxLines: 1,
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
                                                          price != '' &&
                                                                  price != null
                                                              ? 'Rs. $price'
                                                              : 'N/A',
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
                                                              id,
                                                              name,
                                                              widget
                                                                  .categoryName,
                                                            );
                                                          },
                                                          icon: Icon(
                                                            FeatherIcons.x,
                                                            color: const Color
                                                                .fromRGBO(
                                                              215,
                                                              14,
                                                              0,
                                                              1,
                                                            ),
                                                            size: width * 0.09,
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
                                    )
                              : SafeArea(
                                  child: isGridView
                                      ? GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 0,
                                            mainAxisSpacing: 0,
                                            childAspectRatio: 0.75,
                                          ),
                                          itemCount: 4,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.all(
                                                width * 0.0125,
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
                                          physics:
                                              const ClampingScrollPhysics(),
                                          itemCount: 4,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.all(
                                                width * 0.0125,
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
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      })),
    );
  }
}
