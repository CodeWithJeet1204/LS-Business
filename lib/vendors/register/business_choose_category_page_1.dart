import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/vendors/models/household_categories.dart';
import 'package:localy/vendors/register/business_choose_category_page_2.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/select_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localy/widgets/snack_bar.dart';

class BusinessChooseCategoryPage1 extends StatefulWidget {
  const BusinessChooseCategoryPage1({
    super.key,
    this.preSelected,
    this.isEditing,
  });

  final List? preSelected;
  final bool? isEditing;

  @override
  State<BusinessChooseCategoryPage1> createState() =>
      _BusinessChooseCategoryPage1State();
}

class _BusinessChooseCategoryPage1State
    extends State<BusinessChooseCategoryPage1> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  List selected = [];
  bool isNext = false;

  // INIT STATE
  @override
  void initState() {
    print("Editing: ${widget.isEditing}");
    print("PreSelected: ${widget.preSelected}");
    if (widget.isEditing != null && widget.preSelected != null) {
      setState(() {
        selected = widget.preSelected!;
      });
    }
    print("Selected: $selected");
    super.initState();
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
      'Type': selected,
    });

    setState(() {
      isNext = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) => BusinessChooseCategoryPage2(
                selectedTypes: selected,
                isEditing: widget.isEditing,
              )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Choose Your Type'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: width,
                  height: height * 0.8875,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 16 / 9,
                    ),
                    itemCount: householdCategories.length,
                    itemBuilder: (context, index) {
                      final name = householdCategories.keys.toList()[index];
                      final imageUrl =
                          householdCategories.values.toList()[index];

                      return SelectContainer(
                        width: width,
                        text: name,
                        isSelected: selected.contains(name),
                        imageUrl: imageUrl,
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
                ),

                SizedBox(height: height * 0.0125),

                // NEXT
                MyButton(
                  text: 'NEXT',
                  onTap: () async {
                    await next();
                  },
                  isLoading: isNext,
                  horizontalPadding: MediaQuery.of(context).size.width * 0.0225,
                ),

                SizedBox(height: height * 0.0125),
              ],
            );
          }),
        ),
      ),
    );
  }
}
