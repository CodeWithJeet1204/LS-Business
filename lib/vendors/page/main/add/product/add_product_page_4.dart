import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/page/main/add/product/add_product_page_5.dart';
import 'package:ls_business/vendors/provider/add_product_provider.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:ls_business/widgets/video_tutorial.dart';
import 'package:provider/provider.dart';

class AddProductPage4 extends StatefulWidget {
  const AddProductPage4({
    super.key,
    required this.shopType,
    required this.category,
  });

  final String shopType;
  final String category;

  @override
  State<AddProductPage4> createState() => _AddProductPage4State();
}

class _AddProductPage4State extends State<AddProductPage4> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  List currentProducts = [];
  List allProducts = [];
  String? selectedProduct;
  bool isProductData = false;

  // INIT STATE
  @override
  void initState() {
    getProductData();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET PRODUCT DATA
  Future<void> getProductData() async {
    final catalogueSnap = await store
        .collection('Shop Types And Category Data')
        .doc('Catalogue')
        .get();

    final catalogueData = catalogueSnap.data()!;
    final productData = catalogueData['catalogueData'];
    final List products = productData[widget.shopType][widget.category]!;

    setState(() {
      allProducts = products;
      currentProducts = products;
      isProductData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Product'),
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
          MyTextButton(
            onTap: () {
              if (selectedProduct != null) {
                final productProvider = Provider.of<AddProductProvider>(
                  context,
                  listen: false,
                );

                productProvider.add(
                  {
                    'productProductName': selectedProduct,
                  },
                  true,
                );

                if (mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddProductPage5(
                        shopType: widget.shopType,
                      ),
                    ),
                  );
                }
              } else {
                return mySnackBar(context, 'Select Product');
              }
            },
            text: 'NEXT',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(width, 60),
          child: Padding(
            padding: EdgeInsets.all(width * 0.0125),
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
                          currentProducts = allProducts;
                        } else {
                          List filteredProducts = allProducts;

                          filteredProducts.removeWhere((item) {
                            return !item
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          });

                          currentProducts = filteredProducts;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SizedBox(
              width: width,
              child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: currentProducts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedProduct = currentProducts[index];
                      });
                    },
                    child: Container(
                      width: width,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: primary2,
                        border: Border.all(
                          width: selectedProduct == currentProducts[index]
                              ? 1
                              : 0.5,
                          color: primaryDark2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(width * 0.0225),
                      margin: EdgeInsets.all(width * 0.0125),
                      child: Text(
                        currentProducts[index],
                        style: TextStyle(
                          fontSize: selectedProduct == currentProducts[index]
                              ? width * 0.04
                              : width * 0.035,
                          fontWeight: selectedProduct == currentProducts[index]
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
