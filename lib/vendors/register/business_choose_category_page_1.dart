import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Localsearch/vendors/register/business_choose_category_page_2.dart';
import 'package:Localsearch/widgets/select_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/widgets/snack_bar.dart';

class BusinessChooseCategoryPage1 extends StatefulWidget {
  const BusinessChooseCategoryPage1({
    super.key,
    this.selectedShopTypes,
    required this.isEditing,
  });

  final bool isEditing;
  final List? selectedShopTypes;

  @override
  State<BusinessChooseCategoryPage1> createState() =>
      _BusinessChooseCategoryPage1State();
}

class _BusinessChooseCategoryPage1State
    extends State<BusinessChooseCategoryPage1> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Map<String, dynamic>? shopTypes;
  List selected = [];
  bool isNext = false;

  // INIT STATE
  @override
  void initState() {
    if (widget.selectedShopTypes != null) {
      setState(() {
        selected = widget.selectedShopTypes!;
      });
    }
    getShopTypes();
    super.initState();
  }

  // GET SHOP TYPES
  Future<void> getShopTypes() async {
    final shopTypesSnap = await store
        .collection('Shop Types & Category Data')
        .doc('Shop Types Data')
        .get();

    final shopTypesData = shopTypesSnap.data()!;

    final myShopTypes = shopTypesData['shopTypesData'];

    setState(() {
      shopTypes = myShopTypes;
    });
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
      // Navigator.of(context).pop();
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
      body: shopTypes == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
                child: LayoutBuilder(builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;

                  return SizedBox(
                    width: width,
                    height: height * 0.8875,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 16 / 9,
                      ),
                      itemCount: shopTypes!.length,
                      itemBuilder: (context, index) {
                        final name = shopTypes!.keys.toList()[index];
                        final imageUrl = shopTypes!.values.toList()[index];

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
                  );
                }),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await next();
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
