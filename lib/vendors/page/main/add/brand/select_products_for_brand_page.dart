import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/provider/products_added_to_brand.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddProductsToBrandPage extends StatefulWidget {
  const AddProductsToBrandPage({
    super.key,
    this.brandId,
    this.brandName,
    this.isFromBrandPage,
  });

  final String? brandId;
  final String? brandName;
  final bool? isFromBrandPage;

  @override
  State<AddProductsToBrandPage> createState() => _AddProductsToBrandPageState();
}

class _AddProductsToBrandPageState extends State<AddProductsToBrandPage> {
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
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (var product in productSnap.docs) {
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

  // ADD PRODUCT TO BRAND
  Future<void> addProductToBrand(ProductAddedToBrandProvider provider) async {
    for (String id in provider.selectedProducts) {
      await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(id)
          .update({
        'productBrandId': widget.brandId,
        'productBrand': widget.brandName,
      });
    }

    provider.clearProducts();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final productsAddedToBrandProvider =
        Provider.of<ProductAddedToBrandProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Select Products',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          MyTextButton(
            onPressed: () async {
              if (widget.isFromBrandPage != null) {
                if (widget.isFromBrandPage!) {
                  await addProductToBrand(productsAddedToBrandProvider);
                }
              }
              if (context.mounted) {
                Navigator.of(context).pop();
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
                      physics: ClampingScrollPhysics(),
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
              ? const Center(
                  child: Text('No Products'),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.006125),
                    child: LayoutBuilder(
                      builder: ((context, constraints) {
                        final width = constraints.maxWidth;

                        return SafeArea(
                          child: isGridView
                              ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: width * 0.6875 / width,
                                  ),
                                  itemCount: currentProducts.length,
                                  itemBuilder: (context, index) {
                                    final productData = currentProducts[
                                        currentProducts.keys.toList()[index]]!;

                                    return GestureDetector(
                                      onTap: () {
                                        productsAddedToBrandProvider.addProduct(
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
                                                        height: width * 0.5,
                                                        width: width * 0.5,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    width * 0.0125,
                                                    width * 0.0125,
                                                    width * 0.0125,
                                                    0,
                                                  ),
                                                  child: SizedBox(
                                                    width: width * 0.5,
                                                    child: Text(
                                                      productData[
                                                          'productName'],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                              ],
                                            ),
                                          ),
                                          productsAddedToBrandProvider
                                                  .selectedProducts
                                                  .contains(
                                                      productData['productId'])
                                              ? Padding(
                                                  padding: EdgeInsets.only(
                                                    right: width * 0.01,
                                                    top: width * 0.01,
                                                  ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
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
                                      ),
                                    );
                                  })
                              : SizedBox(
                                  width: width,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemCount: currentProducts.length,
                                      itemBuilder: (context, index) {
                                        final productData = currentProducts[
                                            currentProducts.keys
                                                .toList()[index]]!;

                                        return GestureDetector(
                                          onTap: () {
                                            productsAddedToBrandProvider
                                                .addProduct(
                                              productData['productId'],
                                            );
                                          },
                                          child: Stack(
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
                                                      BorderRadius.circular(
                                                    2,
                                                  ),
                                                ),
                                                margin: EdgeInsets.all(
                                                  width * 0.0125,
                                                ),
                                                child: ListTile(
                                                  visualDensity:
                                                      VisualDensity.standard,
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
                                              productsAddedToBrandProvider
                                                      .selectedProducts
                                                      .contains(productData[
                                                          'productId'])
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                        right: width * 0.01,
                                                      ),
                                                      child: Container(
                                                        padding: EdgeInsets.all(
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
