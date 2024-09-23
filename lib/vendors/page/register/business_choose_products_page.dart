import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/vendors/page/main/main_page.dart';
import 'package:Localsearch/vendors/page/main/profile/details/business_details_page.dart';
import 'package:Localsearch/vendors/page/register/business_timings_page.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class BusinessChooseProductsPage extends StatefulWidget {
  const BusinessChooseProductsPage({
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
  State<BusinessChooseProductsPage> createState() =>
      _BusinessChooseProductsPageState();
}

class _BusinessChooseProductsPageState
    extends State<BusinessChooseProductsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Map<String, dynamic>? allProducts;
  List selectedProducts = [];
  bool isNext = false;
  int? total;
  int noOf = 4;
  final scrollController = ScrollController();

  // INIT STATE
  @override
  void initState() {
    getProductsForSubCategory();
    scrollController.addListener(scrollListener);
    if (widget.selectedProducts != null) {
      setState(() {
        selectedProducts = widget.selectedProducts!;
      });
    }
    super.initState();
  }

  // SCROLL LISTENER
  void scrollListener() {
    if (total != null && noOf < total!) {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        print('total: $total');
        setState(() {
          noOf = noOf + 4;
        });
      }
    }
  }

  // GET PRODUCTS FOR SUB CATEGORY
  Future<void> getProductsForSubCategory() async {
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
      print('total: $total');
      allProducts = myProducts;
    });
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
      if (widget.isEditing) {
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
            builder: ((context) => const SelectBusinessTimingsPage(
                  fromMainPage: false,
                )),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Products'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              BetterFeedback.of(context).show((feedback) async {
                Future<String> writeImageToStorage(
                    Uint8List feedbackScreenshot) async {
                  final Directory output = await getTemporaryDirectory();
                  final String screenshotFilePath =
                      '${output.path}/feedback.png';
                  final File screenshotFile = File(screenshotFilePath);
                  await screenshotFile.writeAsBytes(feedbackScreenshot);
                  return screenshotFilePath;
                }

                final screenshotFilePath =
                    await writeImageToStorage(feedback.screenshot);

                final Email email = Email(
                  body: feedback.text,
                  subject: 'Localsearch Feedback',
                  recipients: ['infinitylab1204@gmail.com'],
                  attachmentPaths: [screenshotFilePath],
                  isHTML: false,
                );
                await FlutterEmailSender.send(email);
              });
            },
            icon: const Icon(
              Icons.bug_report_outlined,
            ),
            tooltip: 'Report Problem',
          ),
        ],
      ),
      body: allProducts == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
                child: ListView.builder(
                  controller: scrollController,
                  cacheExtent: height * 1.5,
                  addAutomaticKeepAlives: true,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: noOf > widget.selectedCategories.length
                      ? widget.selectedCategories.length
                      : noOf,
                  itemBuilder: (context, index) {
                    final String? subCategory =
                        widget.selectedCategories[index];

                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.0225,
                          ),
                          child: Text(
                            subCategory!,
                            style: TextStyle(
                              fontSize: width * 0.055,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
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
                                            color: Color.fromRGBO(
                                              133,
                                              255,
                                              137,
                                              1,
                                            ),
                                            onPressed: () {
                                              if (!selectedProducts
                                                  .contains(product)) {
                                                setState(() {
                                                  selectedProducts.add(product);
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
        child: isNext
            ? const CircularProgressIndicator()
            : Icon(widget.isEditing ? Icons.done : Icons.arrow_forward),
      ),
    );
  }
}
