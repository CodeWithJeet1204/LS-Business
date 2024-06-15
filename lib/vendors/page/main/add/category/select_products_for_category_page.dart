import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/provider/products_added_to_category_provider.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/shimmer_skeleton_container.dart';
import 'package:localy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectProductsForCategoryPage extends StatefulWidget {
  const SelectProductsForCategoryPage({
    super.key,
    required this.fromAddCategoryPage,
    this.categoryId,
    this.categoryName,
  });

  final String? categoryId;
  final String? categoryName;
  final bool fromAddCategoryPage;

  @override
  State<SelectProductsForCategoryPage> createState() =>
      _SelectProductsForCategoryPageState();
}

class _SelectProductsForCategoryPageState
    extends State<SelectProductsForCategoryPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  Map<String, Map<String, dynamic>> currentProducts = {};
  Map<String, Map<String, dynamic>> allProducts = {};
  bool isGridView = true;
  bool isAdding = false;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET DATA
  Future<void> getData() async {
    Map<String, Map<String, dynamic>> myProducts = {};

    final productSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .get();

    for (var product in productSnap.docs) {
      final productId = product.id;

      final productData = product.data();

      if (productData['vendorId'] == auth.currentUser!.uid) {
        myProducts[productId] = productData;
      }
    }

    setState(() {
      allProducts = myProducts;
      currentProducts = myProducts;
      isData = true;
    });
  }

  // ADD PRODUCT TO CATEGORY
  Future<void> addProductToCategory(List<String> products) async {
    for (int i = 0; i < products.length; i++) {
      setState(() {
        isAdding = true;
      });
      await FirebaseFirestore.instance
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(products[i])
          .update({
        'categoryName': widget.categoryName,
      });
      setState(() {
        isAdding = false;
      });
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final productsAddedToCategoryProvider =
        Provider.of<ProductAddedToCategory>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'SELECT PRODUCTS',
        ),
        actions: [
          MyTextButton(
            onPressed: widget.fromAddCategoryPage
                ? () {
                    Navigator.of(context).pop();
                  }
                : () async {
                    await addProductToCategory(
                      productsAddedToCategoryProvider.selectedProducts,
                    );
                    productsAddedToCategoryProvider.clearProducts();
                  },
            text: 'NEXT',
            textColor: primaryDark,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
            double.infinity,
            isAdding ? 90 : 80,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.0166,
                  vertical: MediaQuery.of(context).size.width * 0.0225,
                ),
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
                          labelText: 'Case - Sensitive',
                          hintText: 'Search ...',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isEmpty) {
                              currentProducts =
                                  Map<String, Map<String, dynamic>>.from(
                                allProducts,
                              );
                            } else {
                              Map<String, Map<String, dynamic>>
                                  filteredProducts =
                                  Map<String, Map<String, dynamic>>.from(
                                allProducts,
                              );
                              List<String> keysToRemove = [];

                              filteredProducts.forEach((key, productData) {
                                if (!productData['productName']
                                    .toString()
                                    .toLowerCase()
                                    .contains(value.toLowerCase().trim())) {
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
                        isGridView ? FeatherIcons.list : FeatherIcons.grid,
                      ),
                      iconSize: MediaQuery.of(context).size.width * 0.08,
                      tooltip: isGridView ? 'List View' : 'Grid View',
                    ),
                  ],
                ),
              ),
              isAdding ? const LinearProgressIndicator() : Container(),
            ],
          ),
        ),
      ),
      body: !isData
          ? SafeArea(
              child: isGridView
                  ? GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                        childAspectRatio: width * 0.5 / width * 1.6,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(
                            width * 0.02,
                          ),
                          child: GridViewSkeleton(
                            width: width,
                            isPrice: true,
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
                            isPrice: true,
                            height: 30,
                          ),
                        );
                      },
                    ),
            )
          : currentProducts.isEmpty
              ? const SizedBox(
                  height: 60,
                  child: Center(
                    child: Text('No Products'),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.006125),
                    child: LayoutBuilder(
                      builder: ((context, constraints) {
                        final double width = constraints.maxWidth;

                        return SafeArea(
                          child: isGridView
                              ? GridView.builder(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                    childAspectRatio: 0.725,
                                  ),
                                  itemCount: currentProducts.length,
                                  itemBuilder: (context, index) {
                                    final productData = currentProducts[
                                        currentProducts.keys.toList()[index]]!;

                                    return GestureDetector(
                                      onTap: () async {
                                        productsAddedToCategoryProvider
                                            .addProduct(
                                          productData['productId'],
                                        );
                                      },
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  primary2.withOpacity(0.125),
                                              border: Border.all(
                                                width: 0.25,
                                                color: primaryDark,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            margin:
                                                EdgeInsets.all(width * 0.00625),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // CachedNetworkImage(
                                                //   imageUrl:
                                                //       productSnap['images']
                                                //           [0],
                                                //   imageBuilder: (context,
                                                //       imageProvider) {
                                                //     return Center(
                                                //       child: ClipRRect(
                                                //         borderRadius:
                                                //             BorderRadius
                                                //                 .circular(
                                                //           12,
                                                //         ),
                                                //         child: Container(
                                                //           width: width * 0.4,
                                                //           height: width * 0.4,
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
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                    width * 0.00625,
                                                  ),
                                                  child: Center(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        2,
                                                      ),
                                                      child: Image.network(
                                                        productData['images']
                                                            [0],
                                                        width: width * 0.5,
                                                        height: width * 0.5,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    width * 0.0125,
                                                    width * 0.01,
                                                    width * 0.01,
                                                    0,
                                                  ),
                                                  child: SizedBox(
                                                    width: width * 0.5,
                                                    child: Text(
                                                      productData[
                                                          'productName'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: width * 0.05,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    width * 0.0125,
                                                    0,
                                                    width * 0.0125,
                                                    0,
                                                  ),
                                                  child: SizedBox(
                                                    width: width * 0.275,
                                                    child: Text(
                                                      productData['productPrice'] !=
                                                                  '' &&
                                                              productData[
                                                                      'productPrice'] !=
                                                                  null
                                                          ? '''Rs. ${productData['productPrice']}'''
                                                          : 'N/A',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: width * 0.045,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          productsAddedToCategoryProvider
                                                  .selectedProducts
                                                  .contains(
                                                      productData['productId'])
                                              ? Container(
                                                  margin: EdgeInsets.all(
                                                    width * 0.005,
                                                  ),
                                                  padding: EdgeInsets.all(
                                                    width * 0.01,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: primaryDark2,
                                                  ),
                                                  child: Icon(
                                                    FeatherIcons.check,
                                                    color: Colors.white,
                                                    size: width * 0.1,
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    );
                                  })
                              : SizedBox(
                                  width: width,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: currentProducts.length,
                                      itemBuilder: (context, index) {
                                        final productData = currentProducts[
                                            currentProducts.keys
                                                .toList()[index]]!;
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.015,
                                            vertical: width * 0.02,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              productsAddedToCategoryProvider
                                                  .addProduct(
                                                productData['productId'],
                                              );
                                            },
                                            child: Stack(
                                              alignment: Alignment.centerRight,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: primary2
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: ListTile(
                                                    leading: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical:
                                                            width * 0.00125,
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl: productData[
                                                            'images'][0],
                                                        imageBuilder: (context,
                                                            imageProvider) {
                                                          return ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              4,
                                                            ),
                                                            child: Container(
                                                              width:
                                                                  width * 0.15,
                                                              height:
                                                                  width * 0.166,
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
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    title: Text(
                                                      productData[
                                                          'productName'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: width * 0.055,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      productData['productPrice'] !=
                                                                  '' &&
                                                              productData[
                                                                      'productPrice'] !=
                                                                  null
                                                          ? productData[
                                                              'productPrice']
                                                          : 'N/A',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: width * 0.04,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                productsAddedToCategoryProvider
                                                        .selectedProducts
                                                        .contains(productData[
                                                            'productId'])
                                                    ? Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          right: width * 0.01,
                                                        ),
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                            width * 0.005,
                                                          ),
                                                          decoration:
                                                              const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: primaryDark2,
                                                          ),
                                                          child: Icon(
                                                            FeatherIcons.check,
                                                            color: Colors.white,
                                                            size: width * 0.1,
                                                          ),
                                                        ),
                                                      )
                                                    : Container()
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                        );
                      }),
                    ),
                  ),
                ),
    );
  }
}
