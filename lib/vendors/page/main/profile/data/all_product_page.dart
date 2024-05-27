import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/profile/view%20page/product/product_page.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/shimmer_skeleton_container.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  Map<String, Map<String, dynamic>> allProducts = {};
  Map<String, Map<String, dynamic>> currentProducts = {};
  bool isGridView = true;
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

    productSnap.docs.forEach((product) {
      final productId = product.id;

      final productData = product.data();

      if (productData['vendorId'] == auth.currentUser!.uid) {
        myProducts[productId] = productData;
      }
    });

    setState(() {
      allProducts = myProducts;
      currentProducts = myProducts;
      isData = true;
    });
  }

  // DELETE PRODUCT
  Future<void> delete(String productId) async {
    try {
      await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(productId)
          .delete();

      final postSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Posts')
          .where('postProductId', isEqualTo: productId)
          .get();

      for (QueryDocumentSnapshot doc in postSnap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // CONFIRM DELETE
  Future<void> confirmDelete(String productId) async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            overflow: TextOverflow.ellipsis,
            'Confirm DELETE',
          ),
          content: const Text(
            overflow: TextOverflow.ellipsis,
            'Are you sure you want to delete this product & all its posts',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                overflow: TextOverflow.ellipsis,
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
                overflow: TextOverflow.ellipsis,
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'ALL PRODUCTS',
        ),
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
                        currentProducts.values.forEach((postData) {
                          if (!postData['productName']
                              .toString()
                              .contains(value)) {
                            currentProducts.remove('productId');
                          }
                        });
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
                            isDelete: true,
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
                            isDelete: true,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.0225,
                    ),
                    child: LayoutBuilder(
                      builder: ((context, constraints) {
                        final double width = constraints.maxWidth;

                        return isGridView
                            ? GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.725,
                                ),
                                itemCount: currentProducts.length,
                                itemBuilder: (context, index) {
                                  final productData = currentProducts[
                                      currentProducts.keys.toList()[index]]!;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: ((context) => ProductPage(
                                                productId:
                                                    productData['productId'],
                                                productName:
                                                    productData['productName'],
                                                categoryName:
                                                    productData['categoryName'],
                                                brandId: productData[
                                                    'productBrandId'],
                                              )),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: primary2.withOpacity(0.125),
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
                                                  productData['images'][0],
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
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                      width * 0.0125,
                                                      width * 0.0125,
                                                      width * 0.0125,
                                                      0,
                                                    ),
                                                    child: SizedBox(
                                                      width: width * 0.275,
                                                      child: Text(
                                                        productData[
                                                            'productName'],
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.05,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                      width * 0.0125,
                                                      0,
                                                      width * 0.0125,
                                                      0,
                                                    ),
                                                    child: Text(
                                                      productData['productPrice'] !=
                                                                  '' &&
                                                              productData[
                                                                      'productPrice'] !=
                                                                  null
                                                          ? 'Rs. ${productData['productPrice']}'
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
                                                ],
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  await confirmDelete(
                                                    productData['productId'],
                                                  );
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
                            : SizedBox(
                                width: width,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: currentProducts.length,
                                    itemBuilder: (context, index) {
                                      final productData = currentProducts[
                                          currentProducts.keys
                                              .toList()[index]]!;

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: ((context) =>
                                                  ProductPage(
                                                    productId: productData[
                                                        'productId'],
                                                    productName: productData[
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
                                                BorderRadius.circular(2),
                                          ),
                                          margin: EdgeInsets.all(
                                            width * 0.0125,
                                          ),
                                          child: ListTile(
                                            visualDensity:
                                                VisualDensity.standard,
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
                                              overflow: TextOverflow.ellipsis,
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
                                    }),
                              );
                      }),
                    ),
                  ),
                ),
    );
  }
}
