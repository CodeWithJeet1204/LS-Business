import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/page/register/business_choose_products_page.dart';
import 'package:ls_business/widgets/select_container.dart';
import 'package:ls_business/widgets/snack_bar.dart';

class BusinessChooseCategoriesPage extends StatefulWidget {
  const BusinessChooseCategoriesPage({
    super.key,
    required this.selectedTypes,
    required this.isEditing,
    this.selectedCategories,
  });

  final bool isEditing;
  final List selectedTypes;
  final List? selectedCategories;

  @override
  State<BusinessChooseCategoriesPage> createState() =>
      _BusinessChooseCategoriesPageState();
}

class _BusinessChooseCategoriesPageState
    extends State<BusinessChooseCategoriesPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  List<String> selectedCategories = [];
  Map<String, dynamic>? categories;
  String? expandedCategory;
  bool isNext = false;

  // INIT STATE
  @override
  void initState() {
    getCategories();
    super.initState();
  }

  // GET CATEGORIES
  Future<void> getCategories() async {
    final catalogueSnap = await store
        .collection('Shop Types And Category Data')
        .doc('Catalogue')
        .get();

    final catalogueData = catalogueSnap.data()!;

    final catalogue = catalogueData['catalogueData'];

    setState(() {
      categories = catalogue;
    });
  }

  // NEXT
  Future<void> next() async {
    if (selectedCategories.isEmpty) {
      return mySnackBar(context, 'Select Atleast One Category');
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
      'Categories': selectedCategories,
    });

    setState(() {
      isNext = false;
    });

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BusinessChooseProductsPage(
            selectedCategories: selectedCategories,
            selectedTypes: widget.selectedTypes,
            isEditing: widget.isEditing,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Categories'),
        // actions: [
        //   MyTextButton(
        //     onPressed: () async {
        //       await store
        //           .collection('Shop Types And Category Data')
        //           .doc('Category Properties')
        //           .set({
        //         'categoryPropertiesData': householdCategoryProperties,
        //       });
        //     },
        //     text: 'ADD',
        //   ),
        // ],
      ),
      body: categories == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : PopScope(
              canPop: false,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
                  child: Column(
                    children: widget.selectedTypes.map((category) {
                      final categoryData = categories![category.trim()];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 16 / 9,
                            ),
                            itemCount: categoryData?.length ?? 0,
                            itemBuilder: (context, index) {
                              final entry =
                                  categoryData!.entries.toList()[index];
                              final category = entry.key;

                              return SelectContainer(
                                width: width,
                                text: category,
                                isSelected:
                                    selectedCategories.contains(category),
                                onTap: () {
                                  setState(() {
                                    if (selectedCategories.contains(category)) {
                                      selectedCategories.remove(category);
                                    } else {
                                      selectedCategories.add(category);
                                    }
                                  });
                                },
                                imageUrl: null,
                              );
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
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
