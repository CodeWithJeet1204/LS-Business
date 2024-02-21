import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/provider/select_product_for_post_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectProductForPostPage extends StatefulWidget {
  const SelectProductForPostPage({super.key});

  @override
  State<SelectProductForPostPage> createState() =>
      _SelectProductForPostPageState();
}

class _SelectProductForPostPageState extends State<SelectProductForPostPage> {
  bool isGridView = true;
  String? searchedProduct;

  @override
  Widget build(BuildContext context) {
    final selectedProductProvider =
        Provider.of<SelectProductForPostProvider>(context);

    final Stream<QuerySnapshot> allProductStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where(
          'vendorId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .orderBy('datetime', descending: true)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("SELECT PRODUCT"),
        actions: [
          MyTextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: "NEXT",
            textColor: primaryDark,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          final double width = constraints.maxWidth;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "Search ...",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          searchedProduct = value;
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
                        isGridView ? Icons.list : Icons.grid_view_rounded,
                      ),
                      tooltip: isGridView ? "List View" : "Grid View",
                    ),
                  ],
                ),
              ),
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
                                final productDataMap =
                                    productData.data() as Map<String, dynamic>;
                                return Padding(
                                  padding: EdgeInsets.all(width * 0.02),
                                  child: GestureDetector(
                                    onTap: () {
                                      selectedProductProvider
                                          .changeSelectedProduct(
                                        productDataMap['productId'],
                                        productDataMap['productName'],
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
                                            padding:
                                                EdgeInsets.all(width * 0.01),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 2),
                                                CachedNetworkImage(
                                                  imageUrl:
                                                      productData['images'][0],
                                                  imageBuilder:
                                                      (context, imageProvider) {
                                                    return Center(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
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
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.06,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.04,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        selectedProductProvider.selectedProduct
                                                .contains(
                                          productDataMap['productId'],
                                        )
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
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: width * 0.1,
                                                ),
                                              )
                                            : Container()
                                      ],
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
                                  final productData =
                                      snapshot.data!.docs[index];
                                  final productDataMap = productData.data()
                                      as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 8,
                                    ),
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
                                            onTap: () {
                                              selectedProductProvider
                                                  .changeSelectedProduct(
                                                productDataMap['productId'],
                                                productDataMap['productName'],
                                              );
                                            },
                                            leading: CachedNetworkImage(
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
                                                    height: width * 0.4,
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
                                            title: Text(
                                              productData['productName'],
                                              style: TextStyle(
                                                fontSize: width * 0.055,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              productData['productPrice'] !=
                                                          "" &&
                                                      productData[
                                                              'productPrice'] !=
                                                          null
                                                  ? productData['productPrice']
                                                  : "N/A",
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        selectedProductProvider.selectedProduct
                                                .contains(
                                          productDataMap['productId'],
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
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: width * 0.09,
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryDark,
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
