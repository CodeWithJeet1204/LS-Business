import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/page/register/business_choose_categories_page.dart';
import 'package:ls_business/widgets/select_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/snack_bar.dart';

class BusinessChooseShopTypesPage extends StatefulWidget {
  const BusinessChooseShopTypesPage({
    super.key,
    this.selectedShopTypes,
    required this.isEditing,
  });

  final bool isEditing;
  final List? selectedShopTypes;

  @override
  State<BusinessChooseShopTypesPage> createState() =>
      _BusinessChooseShopTypesPageState();
}

class _BusinessChooseShopTypesPageState
    extends State<BusinessChooseShopTypesPage> {
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
        .collection('Shop Types And Category Data')
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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) => BusinessChooseCategoriesPage(
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : PopScope(
              canPop: false,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
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
                    );
                  }),
                ),
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
