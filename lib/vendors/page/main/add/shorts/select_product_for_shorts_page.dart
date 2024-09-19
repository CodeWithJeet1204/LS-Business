import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SelectProductForShortsPage extends StatefulWidget {
  const SelectProductForShortsPage({
    super.key,
    required this.selectedProduct,
  });

  final String? selectedProduct;

  @override
  State<SelectProductForShortsPage> createState() =>
      _SelectProductForShortsPageState();
}

class _SelectProductForShortsPageState
    extends State<SelectProductForShortsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  Map<String, Map<String, dynamic>> currentProducts = {};
  Map<String, Map<String, dynamic>> allProducts = {};
  List? data;
  String? selectedProduct;
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

  // INIT STATE
  @override
  void initState() {
    getProductData();
    getTotal();
    scrollControllerGridView.addListener(scrollListenerGridView);
    scrollControllerListView.addListener(scrollListenerListView);
    super.initState();
    if (widget.selectedProduct != null) {
      setState(() {
        selectedProduct = widget.selectedProduct;
      });
    }
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
        .where('shortsURL', isEqualTo: '')
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
    final productData = await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where('shortsURL', isEqualTo: '')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .limit(isGridView ? noOfGridView : noOfListView)
        .get();

    for (var product in productData.docs) {
      final productId = product.id;

      final productData = product.data();

      myProducts[productId] = productData;
    }

    setState(() {
      currentProducts = myProducts;
      allProducts = myProducts;
      isData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Select Product',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          MyTextButton(
            onPressed: () {
              if (selectedProduct != null) {
                Navigator.of(context).pop(data);
              } else {
                return mySnackBar(context, 'Select Product');
              }
            },
            text: 'DONE',
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
                      iconSize: width * 0.08,
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
                      physics: ClampingScrollPhysics(),
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
                      physics: ClampingScrollPhysics(),
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
              ? SizedBox(
                  height: 80,
                  child: Center(
                    child: Text(
                      'No Products\n(Max. 1 Shorts per product allowed)',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.0166,
                      vertical: width * 0.0225,
                    ),
                    child: LayoutBuilder(
                      builder: ((context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxHeight;

                        return isGridView
                            ? GridView.builder(
                                controller: scrollControllerGridView,
                                cacheExtent: height * 1.5,
                                addAutomaticKeepAlives: true,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.6875,
                                ),
                                itemCount: noOfGridView > currentProducts.length
                                    ? currentProducts.length
                                    : noOfGridView,
                                itemBuilder: ((context, index) {
                                  final productData = currentProducts[
                                      currentProducts.keys.toList()[index]]!;

                                  return GestureDetector(
                                    onTap: () {
                                      if (selectedProduct ==
                                          productData['productName']) {
                                        setState(() {
                                          selectedProduct = null;
                                          data = [];
                                        });
                                      } else {
                                        setState(() {
                                          selectedProduct =
                                              productData['productName'];
                                          data = [
                                            productData['productId'],
                                            productData['productName'],
                                            productData['productPrice'],
                                            productData['productDescription'],
                                            productData['vendorId'],
                                          ];
                                        });
                                      }
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
                                                      productData['images'][0],
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
                                                    productData['productName'],
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                        selectedProduct ==
                                                productData['productName']
                                            ? Container(
                                                margin: EdgeInsets.all(
                                                  width * 0.005,
                                                ),
                                                padding: EdgeInsets.all(
                                                  width * 0.01,
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
                                              )
                                            : Container()
                                      ],
                                    ),
                                  );
                                }),
                              )
                            : ListView.builder(
                                controller: scrollControllerListView,
                                cacheExtent: height * 1.5,
                                addAutomaticKeepAlives: true,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount: noOfListView > currentProducts.length
                                    ? currentProducts.length
                                    : noOfListView,
                                itemBuilder: ((context, index) {
                                  final productData = currentProducts[
                                      currentProducts.keys.toList()[index]]!;

                                  return Stack(
                                    alignment: Alignment.centerRight,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: white,
                                          border: Border.all(
                                            width: 0.5,
                                            color: primaryDark,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        margin: EdgeInsets.all(
                                          width * 0.0125,
                                        ),
                                        child: ListTile(
                                          visualDensity: VisualDensity.standard,
                                          onTap: () {
                                            if (selectedProduct ==
                                                productData['productName']) {
                                              setState(() {
                                                selectedProduct = null;
                                                data = [];
                                              });
                                            } else {
                                              setState(() {
                                                selectedProduct =
                                                    productData['productName'];
                                                data = [
                                                  productData['productId'],
                                                  productData['productName'],
                                                  productData['productPrice'],
                                                  productData[
                                                      'productDescription'],
                                                  productData['vendorId'],
                                                ];
                                              });
                                            }
                                          },
                                          // leading: CachedNetworkImage(
                                          //   imageUrl: productData['images']
                                          //       [0],
                                          //   imageBuilder:
                                          //       (context, imageProvider) {
                                          //     return ClipRRect(
                                          //       borderRadius:
                                          //           BorderRadius.circular(
                                          //         4,
                                          //       ),
                                          //       child: Container(
                                          //         width: width * 0.15,
                                          //         height: width * 0.4,
                                          //         decoration: BoxDecoration(
                                          //           image: DecorationImage(
                                          //             image: imageProvider,
                                          //             fit: BoxFit.cover,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     );
                                          //   },
                                          // ),
                                          leading: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            child: Image.network(
                                              productData['images'][0],
                                              width: width * 0.15,
                                              height: width * 0.15,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          title: Text(
                                            productData['productName'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: width * 0.05,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Rs. ${productData['productPrice']}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: width * 0.045,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      selectedProduct ==
                                              productData['productName']
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                right: width * 0.025,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                  width * 0.01,
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
                                  );
                                }),
                              );
                      }),
                    ),
                  ),
                ),
    );
  }
}
