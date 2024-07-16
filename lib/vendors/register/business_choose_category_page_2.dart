import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/vendors/models/household_special_categories_images.dart';
import 'package:localy/vendors/page/main/main_page.dart';
import 'package:localy/vendors/page/main/profile/details/business_details_page.dart';
import 'package:localy/vendors/register/business_timings_page.dart';
import 'package:localy/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  List selected = [];
  Map<String, Map<String, String>> filteredCategories = {};
  bool isNext = false;

  // INIT STATE
  @override
  void initState() {
    print("IsEditing : ${widget.isEditing}");
    if (widget.isEditing != null && widget.selectedCategories != null) {
      setState(() {
        selected = widget.selectedCategories!;
      });
    }
    getCategories();
    super.initState();
  }

  // GET CATEGORIES
  void getCategories() {
    householdSpecialCategories.keys.forEach((key) {
      if (widget.selectedTypes.contains(key)) {
        filteredCategories.addAll(
          {
            key: householdSpecialCategories[key]!,
          },
        );
      }
    });

    setState(() {});
  }

  // GET WIDGETS
  List<Widget> getWidgets(BuildContext context) {
    List<Widget> widgets = [];

    filteredCategories.forEach((categoryName, categoryValue) {
      widgets.add(categoryContainer(categoryName, categoryValue, context));
    });

    return widgets;
  }

  // CATEGORY CONTAINER
  Widget categoryContainer(
    String name,
    Map<String, String> values,
    BuildContext context,
  ) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: EdgeInsets.all(width * 0.006125),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: width * 0.0225),
            child: Text(
              name,
              style: TextStyle(
                fontSize: width * 0.055,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 16 / 9,
            ),
            itemCount: values.length,
            itemBuilder: (context, index) {
              final name = values.keys.toList()[index];
              final imageUrl = values.values.toList()[index];

              return SelectContainer(
                width: width,
                text: name,
                imageUrl: imageUrl,
                isSelected: selected.contains(name),
                onTap: () {
                  setState(() {
                    if (selected.contains(name)) {
                      selected.remove(name);
                    } else {
                      selected.add(name);
                    }
                  });
                },
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }

  // NEXT
  Future<void> next() async {
    if (selected.isEmpty) {
      return mySnackBar(context, 'Select atleast one Type');
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
      'Categories': selected,
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
            builder: ((context) => MainPage()),
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => BusinessDetailsPage()),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => SelectBusinessTimingsPage()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Choose Your Categories'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: width,
                  height: height * 0.925,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      child: Column(
                        children: getWidgets(context),
                      ),
                    ),
                  ),
                ),
                MyButton(
                  text: 'NEXT',
                  onTap: () async {
                    await next();
                  },
                  isLoading: isNext,
                  horizontalPadding: MediaQuery.of(context).size.width * 0.0225,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
