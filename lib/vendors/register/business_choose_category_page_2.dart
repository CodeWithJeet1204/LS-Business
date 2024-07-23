import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localy/vendors/models/household_special_categories_images.dart';
import 'package:localy/vendors/register/business_choose_category_page_3.dart';
import 'package:localy/widgets/select_container.dart';
import 'package:localy/widgets/snack_bar.dart';

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
  String? expandedCategory;
  bool isNext = false;

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
          child: Column(
            children: widget.selectedTypes.map((category) {
              final categories = householdSpecialCategories[category.trim()];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 16 / 9,
                    ),
                    itemCount: categories?.length ?? 0,
                    itemBuilder: (context, index) {
                      final entry = categories!.entries.toList()[index];
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
        child: isNext ? CircularProgressIndicator() : Icon(Icons.arrow_forward),
      ),
    );
  }
}
