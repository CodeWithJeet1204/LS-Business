import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/vendors/page/main/main_page.dart';
import 'package:Localsearch/vendors/page/main/profile/details/business_details_page.dart';
import 'package:Localsearch/vendors/register/business_timings_page.dart';
import 'package:Localsearch/widgets/snack_bar.dart';

class BusinessChooseCategoryPage3 extends StatefulWidget {
  const BusinessChooseCategoryPage3({
    super.key,
    required this.selectedCategories,
    required this.selectedTypes,
    this.selectedProducts,
    this.isEditing,
  });

  final List selectedTypes;
  final List selectedCategories;
  final List? selectedProducts;
  final bool? isEditing;

  @override
  State<BusinessChooseCategoryPage3> createState() =>
      _BusinessChooseCategoryPage3State();
}

class _BusinessChooseCategoryPage3State
    extends State<BusinessChooseCategoryPage3> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isNext = false;
  List selectedProducts = [];

  // INIT STATE
  @override
  void initState() {
    if (widget.selectedProducts != null) {
      setState(() {
        selectedProducts = widget.selectedProducts!;
      });
    }
    super.initState();
  }

  // NEXT
  Future<void> next() async {
    if (selectedProducts.isEmpty) {
      return mySnackBar(context, 'Select Atleast One Product');
    }

    setState(() {
      isNext = true;
    });

    await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .update({
      'Products': selectedProducts,
    });

    setState(() {
      isNext = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
      if (widget.isEditing != null && widget.isEditing!) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => const MainPage()),
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => const BusinessDetailsPage()),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => const SelectBusinessTimingsPage()),
          ),
        );
      }
    }
  }

  // GET PRODUCTS FOR SUB CATEGORY
  Future<List<String>> getProductsForSubCategory(String subCategory) async {
    final catalogueSnap = await store
        .collection('Shop Types & Category Data')
        .doc('Catalogue')
        .get();

    final catalogueData = catalogueSnap.data()!;

    final catalogue = catalogueData['catalogueData'];

    for (var category in widget.selectedTypes) {
      final subCategories = catalogue[category.trim()];
      if (subCategories != null && subCategories.containsKey(subCategory)) {
        return subCategories[subCategory]!;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Products'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
          child: ListView.builder(
            itemCount: widget.selectedCategories.length,
            itemBuilder: (context, index) {
              final subCategory = widget.selectedCategories[index];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.0225,
                      vertical: 8,
                    ),
                    child: Text(
                      subCategory,
                      style: TextStyle(
                        fontSize: width * 0.055,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: getProductsForSubCategory(subCategory),
                    builder: (context, future) {
                      if (future.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: future.data!.length,
                          itemBuilder: (context, productIndex) {
                            final product = future.data![productIndex];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (!selectedProducts.contains(product)) {
                                    selectedProducts.add(product);
                                  } else {
                                    selectedProducts.remove(product);
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedProducts.contains(product)
                                      ? const Color.fromRGBO(133, 255, 137, 1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(width * 0.0225),
                                margin: EdgeInsets.all(width * 0.0125),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: width * 0.66,
                                      child: AutoSizeText(
                                        product,
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Visibility(
                                          visible: !selectedProducts
                                              .contains(product),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.check,
                                              color: Color.fromRGBO(
                                                133,
                                                255,
                                                137,
                                                1,
                                              ),
                                            ),
                                            onPressed: () {
                                              if (!selectedProducts
                                                  .contains(product)) {
                                                setState(() {
                                                  selectedProducts.add(product);
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        Visibility(
                                          visible: selectedProducts
                                              .contains(product),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: selectedProducts
                                                      .contains(product)
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            onPressed: () {
                                              if (selectedProducts
                                                  .contains(product)) {
                                                setState(() {
                                                  selectedProducts
                                                      .remove(product);
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await next();
        },
        child: isNext
            ? const CircularProgressIndicator()
            : const Icon(Icons.arrow_forward),
      ),
    );
  }
}
