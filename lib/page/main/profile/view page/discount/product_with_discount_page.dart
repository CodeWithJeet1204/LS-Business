import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ProductWithDiscountPage extends StatefulWidget {
  const ProductWithDiscountPage({
    super.key,
    required this.discountId,
  });

  final String discountId;

  @override
  State<ProductWithDiscountPage> createState() =>
      _ProductWithDiscountPageState();
}

class _ProductWithDiscountPageState extends State<ProductWithDiscountPage> {
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  bool isGridView = true;

  void confirmRemove(String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Remove $productName"),
          content: Text(
              'Are you sure you want to remove $productName from Discount?'),
          actions: [
            MyTextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: "NO",
              textColor: Colors.green,
            ),
            MyTextButton(
              onPressed: () {
                remove(productId);
              },
              text: "YES",
              textColor: Colors.red,
            ),
          ],
        );
      },
    );
  }

  void remove(String productId) async {
    final discountData = await store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .doc(widget.discountId)
        .get();

    final List products = discountData['products'];
    print(products);

    await store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .doc(widget.discountId)
        .update({
      'products': products.remove(productId),
    });

    Navigator.of(context).pop();
  }

  Stream<List<Map<String, String>>> getDiscountProductsStream() {
    return store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .doc(widget.discountId)
        .snapshots()
        .map((snapshot) => snapshot.data()!['products'] as List)
        .switchMap((productIds) => Rx.combineLatest(
              productIds.map((productId) => store
                  .collection('Business')
                  .doc('Data')
                  .collection('Products')
                  .doc(productId)
                  .snapshots()),
              (List<DocumentSnapshot<Map<String, dynamic>>> snapshots) =>
                  snapshots
                      .map((snapshot) => {
                            'productId': snapshot.id,
                            'productName':
                                snapshot.data()!['productName'] as String,
                            'imageUrl': snapshot.data()!['images'][0] as String,
                          })
                      .toList()
                      .cast<Map<String, String>>(),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PRODUCTS'),
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            80,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autocorrect: false,
                    decoration: const InputDecoration(
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
                    isGridView ? Icons.list : Icons.grid_view_rounded,
                  ),
                  tooltip: isGridView ? "List View" : "Grid View",
                ),
              ],
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          double width = constraints.maxWidth;

          return StreamBuilder(
            stream: getDiscountProductsStream(),
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Something went wrong'),
                );
              }

              if (snapshot.hasData) {
                final products = snapshot.data!;
                print(snapshot.data);
                print(products);
                return isGridView
                    ? GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: width / 415,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return products[index]['productName']!
                                  .toLowerCase()
                                  .contains(searchController.text
                                      .toString()
                                      .toLowerCase())
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.01),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: primary2.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: width * 0.02,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              products[index]['imageUrl']!,
                                              width: width * 0.45,
                                              height: width * 0.4,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.01,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: width * 0.45,
                                                height: width * 0.1,
                                                child: Text(
                                                  products[index]
                                                      ['productName']!,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: width * 0.06,
                                                    fontWeight: FontWeight.w500,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              // IconButton(
                                              //   onPressed: () {
                                              //     confirmRemove(
                                              //       products[index]
                                              //           ['productId']!,
                                              //       products[index]
                                              //           ['productName']!,
                                              //     );
                                              //   },
                                              //   icon: Icon(
                                              //     Icons
                                              //         .highlight_remove_outlined,
                                              //     color: Colors.red,
                                              //     size: width * 0.075,
                                              //   ),
                                              //   tooltip: "Remove",
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container();
                        },
                      )
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return Container();
                        },
                      );
              }

              print(snapshot.connectionState);
              return Center(
                child: Text("No Products Added"),
              );
            }),
          );
        }),
      ),
    );
  }
}
