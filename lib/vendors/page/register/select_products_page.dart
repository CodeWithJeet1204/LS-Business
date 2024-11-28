import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/vendors/page/main/profile/details/business_details_page.dart';
import 'package:ls_business/vendors/page/register/business_timings_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class SelectProductsPage extends StatefulWidget {
  const SelectProductsPage({
    super.key,
    required this.selectedCategories,
    required this.selectedTypes,
    required this.isEditing,
    this.selectedProducts,
  });

  final bool isEditing;
  final List selectedTypes;
  final List selectedCategories;
  final List? selectedProducts;

  @override
  State<SelectProductsPage> createState() => _SelectProductsPageState();
}

class _SelectProductsPageState extends State<SelectProductsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Map<String, dynamic>? allProducts;
  Map<String, bool> selectAll = {};
  List selectedProducts = [];
  int? total;
  int noOf = 4;
  final scrollController = ScrollController();
  bool isDialog = false;

  // INIT STATE
  @override
  void initState() {
    getProductsForCategory();
    scrollController.addListener(scrollListener);
    if (widget.selectedProducts != null) {
      setState(() {
        selectedProducts = widget.selectedProducts!;
      });
    }
    for (var selectedCategory in widget.selectedCategories) {
      selectAll.addAll({
        selectedCategory: false,
      });
    }
    super.initState();
  }

  // SCROLL LISTENER
  void scrollListener() {
    if (total != null && noOf < total!) {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          noOf = noOf + 4;
        });
      }
    }
  }

  // GET PRODUCTS FOR CATEGORY
  Future<void> getProductsForCategory() async {
    Map<String, dynamic> myProducts = {};
    int totalSubCategories = 0;
    final catalogueSnap = await store
        .collection('Shop Types And Category Data')
        .doc('Catalogue')
        .get();

    final catalogueData = catalogueSnap.data()!;

    final catalogue = catalogueData['catalogueData'];

    for (var shopType in widget.selectedTypes) {
      final subCategories = catalogue[shopType];
      if (subCategories != null) {
        totalSubCategories =
            totalSubCategories + (subCategories as Map<String, dynamic>).length;
        myProducts.addAll(subCategories);
      }
    }

    setState(() {
      total = totalSubCategories;
      allProducts = myProducts;
    });
  }

  // NEXT
  Future<void> next() async {
    if (selectedProducts.isEmpty) {
      return mySnackBar(context, 'Select Atleast One Product');
    }

    try {
      setState(() {
        isDialog = true;
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
        isDialog = false;
      });

      if (mounted) {
        if (widget.isEditing) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ),
            (route) => false,
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BusinessDetailsPage(),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BusinessTimingsPage(
                fromMainPage: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isDialog = false;
      });
      mySnackBar(context, 'Some error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        progressIndicator: LoadingIndicator(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Select Products'),
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
            ],
          ),
          body: allProducts == null
              ? const Center(
                  child: LoadingIndicator(),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
                    child: ListView.builder(
                      controller: scrollController,
                      cacheExtent: height * 1.5,
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: noOf > widget.selectedCategories.length
                          ? widget.selectedCategories.length
                          : noOf,
                      itemBuilder: (context, index) {
                        final String? subCategory =
                            widget.selectedCategories[index];

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.0225,
                                  ),
                                  child: Text(
                                    subCategory!.toString().trim(),
                                    style: TextStyle(
                                      fontSize: width * 0.05,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value:
                                      selectAll[subCategory.toString().trim()],
                                  onChanged: (value) {
                                    setState(() {
                                      selectAll[subCategory.toString().trim()] =
                                          !selectAll[
                                              subCategory.toString().trim()]!;
                                    });
                                    if (selectAll[
                                        subCategory.toString().trim()]!) {
                                      for (var product
                                          in allProducts![subCategory]) {
                                        if (!selectedProducts
                                            .contains(product)) {
                                          setState(() {
                                            selectedProducts.add(product);
                                          });
                                        }
                                      }
                                    } else {
                                      for (var product
                                          in allProducts![subCategory]) {
                                        if (selectedProducts
                                            .contains(product)) {
                                          setState(() {
                                            selectedProducts.remove(product);
                                          });
                                        }
                                      }
                                    }
                                  },
                                  activeColor: primaryDark,
                                  checkColor: primary2,
                                ),
                              ],
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: allProducts![subCategory].length,
                              itemBuilder: (context, productIndex) {
                                final product =
                                    allProducts?[subCategory]?[productIndex];

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
                                          ? const Color.fromRGBO(
                                              133,
                                              255,
                                              137,
                                              1,
                                            )
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
                                            product.toString().trim(),
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
                                                color: const Color.fromRGBO(
                                                  133,
                                                  255,
                                                  137,
                                                  1,
                                                ),
                                                onPressed: () {
                                                  if (!selectedProducts
                                                      .contains(product)) {
                                                    setState(() {
                                                      selectedProducts
                                                          .add(product);
                                                    });
                                                  }
                                                },
                                                tooltip: "Select",
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
            child: Icon(widget.isEditing ? Icons.done : Icons.arrow_forward),
          ),
        ),
      ),
    );
  }
}
