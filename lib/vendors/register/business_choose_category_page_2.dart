import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/vendors/register/business_choose_category_page_3.dart';
import 'package:Localsearch/widgets/select_container.dart';
import 'package:Localsearch/widgets/snack_bar.dart';

class BusinessChooseCategoryPage2 extends StatefulWidget {
  const BusinessChooseCategoryPage2({
    super.key,
    required this.selectedTypes,
    this.isEditing,
    this.selectedCategories,
  });

  final List selectedTypes;
  final List? selectedCategories;
  final bool? isEditing;

  @override
  State<BusinessChooseCategoryPage2> createState() =>
      _BusinessChooseCategoryPage2State();
}

class _BusinessChooseCategoryPage2State
    extends State<BusinessChooseCategoryPage2> {
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
        .collection('Shop Types & Category Data')
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
          builder: (context) => BusinessChooseCategoryPage3(
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
        automaticallyImplyLeading: false,
      ),
      body: categories == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
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
                            final entry = categoryData!.entries.toList()[index];
                            final category = entry.key;

                            return SelectContainer(
                              width: width,
                              text: category,
                              isSelected: selectedCategories.contains(category),
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
