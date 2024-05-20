import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/services/models/services_image_map.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/select_container.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesChooseWorkImagesSubCategoryPage extends StatefulWidget {
  const ServicesChooseWorkImagesSubCategoryPage({super.key});

  @override
  State<ServicesChooseWorkImagesSubCategoryPage> createState() =>
      _ServicesChooseWorkImagesSubCategoryPageState();
}

class _ServicesChooseWorkImagesSubCategoryPageState
    extends State<ServicesChooseWorkImagesSubCategoryPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Map<String, dynamic> subCategories = {};
  String? chosenSubCategory;
  bool getData = false;

  // INIT STATE
  @override
  void initState() {
    getSubCategory();

    super.initState();
  }

  // GET SUBCATEGORIES
  void getSubCategory() async {
    final serviceSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    setState(() {
      subCategories = serviceData['SubCategory'];
      getData = true;
    });
    print('SubCategories: $subCategories');
  }

  // SELECT CATEGORY
  void selectSubCategory(String subCategory) {
    setState(() {
      if (chosenSubCategory == subCategory) {
        chosenSubCategory = null;
        ;
      } else {
        chosenSubCategory = subCategory;
      }
    });
  }

  // NEXT
  void next() {
    if (chosenSubCategory != null) {
      if (mounted) {
        Navigator.of(context).pop(chosenSubCategory!);
      }
    } else {
      return mySnackBar(context, 'Select Sub Category');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Sub Category'),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: width,
          height: 60,
          child: MyButton(
            text: 'DONE',
            onTap: next,
            isLoading: false,
            horizontalPadding: MediaQuery.of(context).size.width * 0.0225,
          ),
        ),
      ),
      body: !getData
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(width * 0.0125),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 168,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 16 / 9,
                    ),
                    itemCount: subCategories.length,
                    itemBuilder: ((context, index) {
                      final String name = subCategories.keys.toList()[index];
                      final String imageUrl = subCategoryImageMap[name]!;

                      return SelectContainer(
                        width: width,
                        text: name,
                        isSelected: chosenSubCategory == name,
                        onTap: () {
                          selectSubCategory(name);
                        },
                        imageUrl: imageUrl,
                      );
                    }),
                  ),
                ),
              ),
            ),
    );
  }
}
