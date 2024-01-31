import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/view%20page/product/product_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  bool isGridView = true;

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: const Text("YOUR PRODUCTS"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
            icon: isGridView
                ? const Icon(Icons.list)
                : const Icon(Icons.grid_view_rounded),
            tooltip: isGridView ? "List View" : "Grid View",
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          final double width = constraints.maxWidth;
          // final double height = constraints.maxHeight;
          return StreamBuilder(
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
                            childAspectRatio: width * 0.5 / 230,
                          ),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final productData = snapshot.data!.docs[index];
                            final productDataMap =
                                productData.data() as Map<String, dynamic>;
                            return snapshot.data!.docs.length == 0
                                ? Center(
                                    child: Text('No Products Added'),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: ((context) => ProductPage(
                                                  productId: productDataMap[
                                                      'productId'],
                                                  productName: productDataMap[
                                                      'productName'],
                                                )),
                                          ),
                                        );
                                      },
                                      // doubleTap: Options such as delete
                                      child: Container(
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
                                                      BorderRadius.circular(12),
                                                  child: Image.network(
                                                    productData['images'][0],
                                                    height: 140,
                                                    width: 140,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 4, 4, 0),
                                                child: Text(
                                                  productData['productName'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 0, 4, 0),
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
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                          })
                      : ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            final productData = snapshot.data!.docs[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 8,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: primaryDark,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        productData['images'][0],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    productData['productName'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    productData['productPrice'] != "" &&
                                            productData['productPrice'] != null
                                        ? productData['productPrice']
                                        : "N/A",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                );
              }

              return const Center(
                child: CircularProgressIndicator(
                  color: primaryDark,
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
