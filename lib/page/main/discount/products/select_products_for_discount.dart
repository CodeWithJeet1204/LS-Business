import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/provider/discount_products_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/text_button.dart';
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
  bool isGridView = true;
  String? searchedProduct;

  @override
  Widget build(BuildContext context) {
    final selectedProductsProvider =
        Provider.of<SelectProductForDiscountProvider>(context);

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
                    // SEARCH
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
                                childAspectRatio: width * 0.5 / width * 1.565,
                              ),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final productSnap = snapshot.data!.docs[index];
                                final productData =
                                    productSnap.data() as Map<String, dynamic>;

                                // CARD
                                return Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
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
                                                Center(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12,
                                                    ),
                                                    child: Image.network(
                                                      productSnap['images'][0],
                                                      width: width * 0.4,
                                                      height: width * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    width * 0.025,
                                                    width * 0.0125,
                                                    width * 0.0125,
                                                    0,
                                                  ),
                                                  child: Text(
                                                    productSnap['productName'],
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
                                                    width * 0.0125,
                                                    0,
                                                  ),
                                                  child: Text(
                                                    productSnap['productPrice'] !=
                                                                "" &&
                                                            productSnap[
                                                                    'productPrice'] !=
                                                                null
                                                        ? productSnap[
                                                            'productPrice']
                                                        : "N/A",
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
                                                decoration: const BoxDecoration(
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
                                  ),
                                );
                              })
                          : SizedBox(
                              width: width,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: ((context, index) {
                                  final productSnap =
                                      snapshot.data!.docs[index];
                                  final productData = productSnap.data()
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
                                              selectedProductsProvider
                                                  .selectProduct(
                                                productData['productId'],
                                                productData['productPrice'],
                                                context,
                                              );
                                            },
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                productSnap['images'][0],
                                                width: width * 0.166,
                                                height: width * 0.166,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            title: Text(
                                              productSnap['productName'],
                                              style: TextStyle(
                                                fontSize: width * 0.05125,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              productSnap['productPrice'] !=
                                                          "" &&
                                                      productSnap[
                                                              'productPrice'] !=
                                                          null
                                                  ? productSnap['productPrice']
                                                  : "N/A",
                                              style: TextStyle(
                                                fontSize: width * 0.04125,
                                                fontWeight: FontWeight.w500,
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
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: width * 0.095,
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
