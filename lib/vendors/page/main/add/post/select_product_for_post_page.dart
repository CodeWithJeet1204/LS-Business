import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/provider/select_product_for_post_provider.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/shimmer_skeleton_container.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectProductForPostPage extends StatefulWidget {
  const SelectProductForPostPage({
    super.key,
    required this.isTextPost,
    required this.postRemaining,
  });

  final bool isTextPost;
  final int postRemaining;

  @override
  State<SelectProductForPostPage> createState() =>
      _SelectProductForPostPageState();
}

class _SelectProductForPostPageState extends State<SelectProductForPostPage> {
  final store = FirebaseFirestore.instance;
  bool isGridView = true;
  final TextEditingController searchController = TextEditingController();
  Map<String, Map<String, dynamic>> allProducts = {};
  Map<String, Map<String, dynamic>> currentProducts = {};
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    Map<String, Map<String, dynamic>> myProducts = {};

    final productSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .get();

    productSnap.docs.forEach((productData) {
      final productId = productData.id;

      myProducts[productId] = productData.data();
    });

    setState(() {
      allProducts = myProducts;
      currentProducts = myProducts;
      isData = true;
    });
  }

  // ADD PRODUCT
  Future<void> addProduct(
    SelectProductForPostProvider provider,
    Map<String, dynamic> data,
  ) async {
    final previousPosts = await store
        .collection('Business')
        .doc('Data')
        .collection('Posts')
        .where('postVendorId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    bool postExists = false;

    for (QueryDocumentSnapshot doc in previousPosts.docs) {
      if (data['productId'] == doc['postProductId'] &&
          widget.isTextPost == doc['isTextPost']) {
        postExists = true;
        break;
      }
    }

    if (postExists) {
      if (mounted) {
        mySnackBar(
          context,
          widget.isTextPost
              ? 'Text Post Already Exists for one of the product'
              : 'Image Post Already Exists for the product',
        );
      }
    } else {
      setState(() {
        provider.addSelectedProduct(
          data['productId'],
          widget.postRemaining,
          widget.isTextPost,
          context,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final selectedProductProvider =
        Provider.of<SelectProductForPostProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'SELECT PRODUCTS',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          MyTextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'NEXT',
            textColor: primaryDark,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.width * 0.2,
          ),
          child: Padding(
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
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
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
                          Map<String, Map<String, dynamic>> filteredProducts =
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

                          keysToRemove.forEach((key) {
                            filteredProducts.remove(key);
                          });

                          currentProducts = filteredProducts;
                        }

                        print('All Posts: $allProducts');
                        print('Current Posts: $currentProducts');
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
              ? Center(
                  child: Text('No Products'),
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
                                    childAspectRatio: 0.725,
                                  ),
                                  itemCount: currentProducts.length,
                                  itemBuilder: (context, index) {
                                    print('Current Products: $currentProducts');
                                    final productData = currentProducts[
                                        currentProducts.keys.toList()[index]]!;

                                    return GestureDetector(
                                      onTap: () async {
                                        await addProduct(
                                          selectedProductProvider,
                                          productData,
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
                                          selectedProductProvider
                                                  .selectedProducts
                                                  .contains(
                                            productData['productId'],
                                          )
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
                                                visualDensity:
                                                    VisualDensity.standard,
                                                onTap: () async {
                                                  await addProduct(
                                                    selectedProductProvider,
                                                    productData,
                                                  );
                                                },
                                                // leading: CachedNetworkImage(
                                                //   imageUrl: productSnap['images']
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
                                                  borderRadius:
                                                      BorderRadius.circular(
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
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: width * 0.05,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  productData['productPrice'] !=
                                                              '' &&
                                                          productData[
                                                                  'productPrice'] !=
                                                              null
                                                      ? 'Rs. ${productData['productPrice']}'
                                                      : 'N/A',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: width * 0.045,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            selectedProductProvider
                                                    .selectedProducts
                                                    .contains(
                                              productData['productId'],
                                            )
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                      right: width * 0.025,
                                                    ),
                                                    child: Container(
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
                                                    ),
                                                  )
                                                : Container()
                                          ],
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
