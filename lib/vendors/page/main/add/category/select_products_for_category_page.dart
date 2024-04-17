import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/vendors/provider/products_added_to_category_provider.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/shimmer_skeleton_container.dart';
import 'package:find_easy/widgets/text_button.dart';
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
  final searchController = TextEditingController();
  bool isGridView = true;
  bool isAdding = false;
  String? searchedProduct;

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
        'categoryId': widget.categoryId,
        'categoryName': widget.categoryName,
      });
      setState(() {
        isAdding = false;
      });
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAddedToCategoryProvider =
        Provider.of<ProductAddedToCategory>(context);

    final Stream<QuerySnapshot> allProductStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where(
          'vendorId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .orderBy('productName')
        .where('productName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('productName', isLessThan: '${searchController.text}\uf8ff')
        .orderBy('datetime', descending: true)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          "SELECT PRODUCTS",
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
            text: "NEXT",
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
                        isGridView ? FeatherIcons.list : FeatherIcons.grid,
                      ),
                      iconSize: MediaQuery.of(context).size.width * 0.08,
                      tooltip: isGridView ? "List View" : "Grid View",
                    ),
                  ],
                ),
              ),
              isAdding ? const LinearProgressIndicator() : Container(),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          final double width = constraints.maxWidth;
          return StreamBuilder(
            stream: allProductStream,
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    "Something went wrong",
                  ),
                );
              }

              if (snapshot.hasData) {
                return SafeArea(
                  child: isGridView
                      ? GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                            childAspectRatio: width * 0.5 / width * 1.6,
                          ),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final productData = snapshot.data!.docs[index];
                            return Padding(
                              padding: EdgeInsets.all(width * 0.0175),
                              child: SizedOverflowBox(
                                size: Size(width * 0.5, 210),
                                child: GestureDetector(
                                  onTap: () {
                                    productsAddedToCategoryProvider.addProduct(
                                      productData['productId'],
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        width: width * 0.5,
                                        decoration: BoxDecoration(
                                          color: primary2.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 2),
                                              CachedNetworkImage(
                                                imageUrl: productData['images']
                                                    [0],
                                                imageBuilder:
                                                    (context, imageProvider) {
                                                  return Center(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        12,
                                                      ),
                                                      child: Container(
                                                        width: width * 0.4,
                                                        height: width * 0.4,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                  width * 0.025,
                                                  width * 0.01,
                                                  width * 0.01,
                                                  0,
                                                ),
                                                child: Text(
                                                  productData['productName'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: width * 0.06,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                  width * 0.025,
                                                  0,
                                                  width * 0.01,
                                                  0,
                                                ),
                                                child: Text(
                                                  productData['productPrice'] !=
                                                              "" &&
                                                          productData[
                                                                  'productPrice'] !=
                                                              null
                                                      ? productData[
                                                          'productPrice']
                                                      : "N/A",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      productsAddedToCategoryProvider
                                              .selectedProducts
                                              .contains(
                                                  productData['productId'])
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                right: width * 0.01,
                                                top: width * 0.01,
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
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
                              ),
                            );
                          })
                      : SizedBox(
                          width: width,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: ((context, index) {
                              final productData = snapshot.data!.docs[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.015,
                                  vertical: width * 0.02,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    productsAddedToCategoryProvider.addProduct(
                                      productData['productId'],
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.centerRight,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: primary2.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: ListTile(
                                          leading: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: width * 0.00125,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: productData['images']
                                                  [0],
                                              imageBuilder:
                                                  (context, imageProvider) {
                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    4,
                                                  ),
                                                  child: Container(
                                                    width: width * 0.15,
                                                    height: width * 0.166,
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
                                          title: Text(
                                            productData['productName'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: width * 0.055,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            productData['productPrice'] != "" &&
                                                    productData[
                                                            'productPrice'] !=
                                                        null
                                                ? productData['productPrice']
                                                : "N/A",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: width * 0.04,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      productsAddedToCategoryProvider
                                              .selectedProducts
                                              .contains(
                                                  productData['productId'])
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                right: width * 0.01,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                  width * 0.005,
                                                ),
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
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
                        ),
                );
              }

              return SafeArea(
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
              );
            }),
          );
        }),
      ),
    );
  }
}
