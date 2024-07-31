import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/provider/discount_products_provider.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectProductForDiscountPage extends StatefulWidget {
  const SelectProductForDiscountPage({super.key});

  @override
  State<SelectProductForDiscountPage> createState() =>
      _SelectProductForDiscountPageState();
}

class _SelectProductForDiscountPageState
    extends State<SelectProductForDiscountPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isGridView = true;
  Map<String, Map<String, dynamic>> currentProducts = {};
  Map<String, Map<String, dynamic>> allProducts = {};
  String? searchedProduct;
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final selectedProductsProvider =
        Provider.of<SelectProductForDiscountProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'SELECT PRODUCT',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          MyTextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'DONE',
            textColor: primaryDark,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 80),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.0166,
              vertical: MediaQuery.of(context).size.width * 0.0225,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // SEARCH
                Expanded(
                  child: TextField(
                    autocorrect: false,
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
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
              ? const Center(
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
                                    final Map<String, dynamic> productData =
                                        currentProducts[currentProducts.keys
                                            .toList()[index]]!;

                                    // CARD
                                    return GestureDetector(
                                      onTap: () {
                                        selectedProductsProvider.selectProduct(
                                          productData['productId'],
                                          productData['productPrice'],
                                          context,
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
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                    width * 0.00625,
                                                  ),
                                                  child: Center(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
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
                                                    width * 0.0125,
                                                    width * 0.0125,
                                                    0,
                                                  ),
                                                  child: SizedBox(
                                                    width: width * 0.275,
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
                                              ],
                                            ),
                                          ),
                                          selectedProductsProvider
                                                  .selectedProducts
                                                  .contains(
                                            productData['productId'],
                                          )
                                              ? Container(
                                                  padding: EdgeInsets.all(
                                                    width * 0.006125,
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
                                        final Map<String, dynamic> productData =
                                            currentProducts[currentProducts.keys
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
                                                onTap: () {
                                                  selectedProductsProvider
                                                      .selectProduct(
                                                    productData['productId'],
                                                    productData['productPrice'],
                                                    context,
                                                  );
                                                },
                                                // leading: CachedNetworkImage(
                                                //   imageUrl: productData['images'][0],
                                                //   imageBuilder:
                                                //       (context, imageProvider) {
                                                //     return ClipRRect(
                                                //       borderRadius:
                                                //           BorderRadius.circular(
                                                //         4,
                                                //       ),
                                                //       child: Container(
                                                //         width: width * 0.166,
                                                //         height: width * 0.166,
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
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: width * 0.045,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            selectedProductsProvider
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
                                                        width * 0.00625,
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
