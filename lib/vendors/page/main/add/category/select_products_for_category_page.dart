import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/provider/products_added_to_category_provider.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/shimmer_skeleton_container.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class SelectProductsForCategoryPage extends StatefulWidget {
  const SelectProductsForCategoryPage({
    super.key,
    required this.fromAddCategoryPage,
    this.categoryName,
  });

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
  int? total;
  int noOfGridView = 8;
  bool isLoadMoreGridView = false;
  final scrollControllerGridView = ScrollController();
  int noOfListView = 20;
  bool isLoadMoreListView = false;
  final scrollControllerListView = ScrollController();
  bool isAdding = false;
  bool isGridView = true;
  bool isData = false;
  bool isDialog = false;

  // INIT STATE
  @override
  void initState() {
    getProductData();
    getTotal();
    scrollControllerGridView.addListener(scrollListenerGridView);
    scrollControllerListView.addListener(scrollListenerListView);
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    scrollControllerGridView.dispose();
    scrollControllerListView.dispose();
    super.dispose();
  }

  // SCROLL LISTENER GRID VIEW
  Future<void> scrollListenerGridView() async {
    if (total != null && noOfGridView < total!) {
      if (scrollControllerGridView.position.pixels ==
          scrollControllerGridView.position.maxScrollExtent) {
        setState(() {
          isLoadMoreGridView = true;
        });
        noOfGridView = noOfGridView + 8;
        await getProductData();
        setState(() {
          isLoadMoreGridView = false;
        });
      }
    }
  }

  // SCROLL LISTENER LIST VIEW
  Future<void> scrollListenerListView() async {
    if (total != null && noOfListView < total!) {
      if (scrollControllerListView.position.pixels ==
          scrollControllerListView.position.maxScrollExtent) {
        setState(() {
          isLoadMoreListView = true;
        });
        noOfListView = noOfListView + 12;
        await getProductData();
        setState(() {
          isLoadMoreListView = false;
        });
      }
    }
  }

  // GET TOTAL
  Future<void> getTotal() async {
    final productSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    final productLength = productSnap.docs.length;

    setState(() {
      total = productLength;
    });
  }

  // GET PRODUCT DATA
  Future<void> getProductData() async {
    Map<String, Map<String, dynamic>> myProducts = {};

    final productSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .limit(isGridView ? noOfGridView : noOfListView)
        .get();

    for (var product in productSnap.docs) {
      final productId = product.id;

      final productData = product.data();

      myProducts[productId] = productData;
    }

    setState(() {
      allProducts = myProducts;
      currentProducts = myProducts;
      isData = true;
    });
  }

  // ADD PRODUCT TO CATEGORY
  Future<void> addProductToCategory(List<String> products) async {
    setState(() {
      isAdding = true;
      isDialog = true;
    });

    await Future.wait(
      products.map((productId) async {
        await store
            .collection('Business')
            .doc('Data')
            .collection('Products')
            .doc(productId)
            .update({
          'categoryName': widget.categoryName,
        });
      }),
    );

    setState(() {
      isAdding = false;
      isDialog = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final productsAddedToCategoryProvider =
        Provider.of<ProductAddedToCategory>(context);

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        progressIndicator: const LoadingIndicator(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text(
              'Select Products',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await showYouTubePlayerDialog(
                    context,
                    'select_products_for_category_page',
                  );
                },
                icon: const Icon(
                  Icons.question_mark_outlined,
                ),
                tooltip: 'Help',
              ),
              MyTextButton(
                onTap: widget.fromAddCategoryPage
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
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size(
                double.infinity,
                80,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.0166,
                  vertical: width * 0.0225,
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
                          hintText: 'Search ...',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() async {
                            if (value.isEmpty) {
                              currentProducts =
                                  Map<String, Map<String, dynamic>>.from(
                                      allProducts);
                            } else {
                              Map<String, Map<String, dynamic>>
                                  filteredProducts =
                                  Map<String, Map<String, dynamic>>.from(
                                      allProducts);
                              List<String> keysToRemove = (await Future.wait(
                                filteredProducts.entries.map(
                                  (entry) async {
                                    return !entry.value['productName']
                                            .toString()
                                            .toLowerCase()
                                            .contains(
                                                value.toLowerCase().trim())
                                        ? entry.key
                                        : null;
                                  },
                                ),
                              ))
                                  .whereType<String>()
                                  .toList();

                              keysToRemove.forEach(filteredProducts.remove);
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
                      iconSize: width * 0.08,
                      tooltip: isGridView ? 'List View' : 'Grid View',
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: !isData
              ? SafeArea(
                  child: isGridView
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                          physics: const ClampingScrollPhysics(),
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
                      height: 80,
                      child: Center(
                        child: Text('No Products'),
                      ),
                    )
                  : SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.006125),
                        child: LayoutBuilder(builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final height = constraints.maxHeight;

                          return isGridView
                              ? GridView.builder(
                                  controller: scrollControllerGridView,
                                  cacheExtent: height * 1.5,
                                  addAutomaticKeepAlives: true,
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                    childAspectRatio: 0.6875,
                                  ),
                                  itemCount:
                                      noOfGridView > currentProducts.length
                                          ? currentProducts.length
                                          : noOfGridView,
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
                                              color: white,
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
                                                        productData['images'][0]
                                                            .toString()
                                                            .trim(),
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
                                                      productData['productName']
                                                          .toString()
                                                          .trim(),
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
                                                      'Rs. ${productData['productPrice']}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                      controller: scrollControllerListView,
                                      cacheExtent: height * 1.5,
                                      addAutomaticKeepAlives: true,
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount:
                                          noOfListView > currentProducts.length
                                              ? currentProducts.length
                                              : noOfListView,
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
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          4,
                                                        ),
                                                        child: Container(
                                                          width: width * 0.15,
                                                          height: width * 0.166,
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image: productData[
                                                                  'images'][0],
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      productData['productName']
                                                          .toString()
                                                          .trim(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: width * 0.055,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      'Rs. ${productData['productPrice']}',
                                                      maxLines: 1,
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
                                );
                        }),
                      ),
                    ),
        ),
      ),
    );
  }
}
