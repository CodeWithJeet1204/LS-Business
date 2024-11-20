import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ls_business/vendors/page/main/add/product/add_product_page_1.dart';
import 'package:ls_business/vendors/page/main/profile/view%20page/product/product_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/shimmer_skeleton_container.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  Map<String, Map<String, dynamic>> allProducts = {};
  Map<String, Map<String, dynamic>> currentProducts = {};
  int? total;
  int noOfGridView = 8;
  bool isLoadMoreGridView = false;
  final scrollControllerGridView = ScrollController();
  int noOfListView = 20;
  bool isLoadMoreListView = false;
  final scrollControllerListView = ScrollController();
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

  // CONFIRM DELETE
  Future<void> confirmDelete(String productId) async {
    await showDialog(
      context: context,
      builder: (context) {
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
                await delete(productId);
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
      },
    );
  }

  // DELETE
  Future<void> delete(String productId) async {
    try {
      final productSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(productId)
          .get();

      final productData = productSnap.data()!;

      final List images = productData['images'];
      final shortsURL = productData['shortsURL'];
      final shortsThumbnail = productData['shortsThumbnail'];

      await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(productId)
          .delete();

      final shortsSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Shorts')
          .where('productId', isEqualTo: productId)
          .get();

      List<Future<void>> deleteOperations = [];

      shortsSnap.docs.forEach((short) {
        deleteOperations.add(short.reference.delete());
      });

      await Future.wait(deleteOperations);

      if (shortsURL != '') {
        await storage.refFromURL(shortsURL).delete();
      }
      if (images.isNotEmpty) {
        List<Future<void>> deleteOperations = [];

        images.forEach((image) {
          deleteOperations.add(storage.refFromURL(image).delete());
        });

        await Future.wait(deleteOperations);
      }

      if (shortsThumbnail != '') {
        await storage.refFromURL(shortsThumbnail).delete();
      }
    } catch (e) {
      if (mounted) {
        return mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('All Products'),
        actions: [
          IconButton(
            onPressed: () async {
              await showYouTubePlayerDialog(
                context,
                getYoutubeVideoId(
                  '',
                ),
              );
            },
            icon: const Icon(
              Icons.question_mark_outlined,
            ),
            tooltip: 'Help',
          ),
          IconButton(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddProductPage1(),
                ),
              );
            },
            icon: const Icon(
              Icons.add,
            ),
            tooltip: 'Add Product',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
            width,
            width * 0.2,
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
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
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
                          Map<String, Map<String, dynamic>> filteredProducts =
                              Map<String, Map<String, dynamic>>.from(
                                  allProducts);

                          List<String> keysToRemove = await Future.wait(
                            filteredProducts.entries.map((entry) async {
                              if (!entry.value['productName']
                                  .toString()
                                  .toLowerCase()
                                  .contains(value.toLowerCase().trim())) {
                                return entry.key;
                              }
                              return null;
                            }),
                          ).then(
                              (result) => result.whereType<String>().toList());

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
                            isPrice: false,
                            isDelete: true,
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(
                            width * 0.02,
                          ),
                          child: ListViewSkeleton(
                            width: width,
                            isPrice: false,
                            height: 30,
                            isDelete: true,
                          ),
                        );
                      },
                    ),
            )
          : currentProducts.isEmpty
              ? const Center(
                  child: Text('No Products'),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.0225,
                    ),
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
                                childAspectRatio: 0.6875,
                              ),
                              itemCount: noOfGridView > currentProducts.length
                                  ? currentProducts.length
                                  : noOfGridView,
                              itemBuilder: (context, index) {
                                final productData = currentProducts[
                                    currentProducts.keys.toList()[index]]!;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ProductPage(
                                          productId: productData['productId'],
                                          productName:
                                              productData['productName'],
                                          categoryName:
                                              productData['categoryName'],
                                          productBrandId:
                                              productData['productBrandId'],
                                        ),
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
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    margin: EdgeInsets.all(width * 0.00625),
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
                                                  BorderRadius.circular(2),
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    width * 0.0125,
                                                    width * 0.0125,
                                                    width * 0.0125,
                                                    0,
                                                  ),
                                                  child: SizedBox(
                                                    width: width * 0.275,
                                                    child: Text(
                                                      productData['productName']
                                                          .toString()
                                                          .trim(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: width * 0.05,
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
                                                  child: Text(
                                                    productData['productPrice'] ==
                                                            0
                                                        ? 'Rs. N/A'
                                                        : 'Rs. ${productData['productPrice'].round()}',
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
                                              ],
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await confirmDelete(
                                                  productData['productId'],
                                                );
                                                if (context.mounted) {
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const AllProductsPage()),
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                FeatherIcons.trash,
                                                color: Colors.red,
                                                size: width * 0.09,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                          : ListView.builder(
                              controller: scrollControllerListView,
                              cacheExtent: height * 1.5,
                              addAutomaticKeepAlives: true,
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: noOfListView > currentProducts.length
                                  ? currentProducts.length
                                  : noOfListView,
                              itemBuilder: (context, index) {
                                final productData = currentProducts[
                                    currentProducts.keys.toList()[index]]!;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ProductPage(
                                          productId: productData['productId'],
                                          productName:
                                              productData['productName'],
                                        ),
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
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    margin: EdgeInsets.all(
                                      width * 0.0125,
                                    ),
                                    child: ListTile(
                                      visualDensity: VisualDensity.standard,
                                      // leading: CachedNetworkImage(
                                      //   imageUrl: productData['images'][0],
                                      //   imageBuilder: (context, imageProvider) {
                                      //     return Padding(
                                      //       padding: EdgeInsets.symmetric(
                                      //         vertical: width * 0.0125,
                                      //       ),
                                      //       child: ClipRRect(
                                      //         borderRadius:
                                      //             BorderRadius.circular(4),
                                      //         child: Container(
                                      //           width: width * 0.133,
                                      //           height: width * 0.133,
                                      //           decoration: BoxDecoration(
                                      //             image: DecorationImage(
                                      //               image: imageProvider,
                                      //               fit: BoxFit.cover,
                                      //             ),
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
                                          productData['images'][0]
                                              .toString()
                                              .trim(),
                                          width: width * 0.15,
                                          height: width * 0.15,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(
                                        productData['productName']
                                            .toString()
                                            .trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: width * 0.05,
                                        ),
                                      ),
                                      subtitle: Text(
                                        productData['productPrice'] == 0
                                            ? 'Rs. N/A'
                                            : 'Rs. ${productData['productPrice'].round()}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: width * 0.045,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () async {
                                          await confirmDelete(
                                            productData['productId'],
                                          );
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AllProductsPage(),
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          FeatherIcons.trash,
                                          color: Colors.red,
                                          size: width * 0.075,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                    }),
                  ),
                ),
    );
  }
}
