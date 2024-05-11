import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/services/main/services_main_page.dart';
import 'package:find_easy/services/models/services_image_map.dart';
import 'package:find_easy/services/models/services_map.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/select_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesChoosePage3 extends StatefulWidget {
  const ServicesChoosePage3({
    super.key,
    required this.category,
    required this.place,
  });

  final List place;
  final List category;

  @override
  State<ServicesChoosePage3> createState() => _ServicesChoosePage3State();
}

class _ServicesChoosePage3State extends State<ServicesChoosePage3> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isNext = false;
  List selectedSubCategories = [];
  Map<String, List> chosenSubCategories = {};
  bool getData = false;

  // INIT STATE
  @override
  void initState() {
    getSubCategory();
    setState(() {
      getData = true;
    });
    super.initState();
  }

  // GET SUBCATEGORIES
  void getSubCategory() {
    for (var place in widget.place) {
      if (servicesMap.containsKey(place)) {
        for (var category in widget.category) {
          if (servicesMap[place]!.containsKey(category)) {
            selectedSubCategories.addAll(servicesMap[place]![category]!);
          }
        }
      }
    }
  }

  // SELECT CATEGORY
  void selectSubCategory(String subCategory) {
    setState(() {
      if (chosenSubCategories.keys.toList().contains(subCategory)) {
        chosenSubCategories.remove(subCategory);
      } else {
        chosenSubCategories.addAll({
          subCategory: [0, 'Service'],
        });
      }
    });
  }

  // DONE
  Future<void> next() async {
    setState(() {
      isNext = true;
    });
    if (chosenSubCategories.isNotEmpty) {
      await store.collection('Services').doc(auth.currentUser!.uid).update({
        'SubCategory': chosenSubCategories,
      });

      setState(() {
        isNext = false;
      });
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: ((context) => const ServicesMainPage()),
          ),
          (route) => false,
        );
      }
    } else {
      setState(() {
        isNext = false;
      });
      mySnackBar(context, 'Select Sub Category');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Sub Category'),
        automaticallyImplyLeading: false,
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 60,
          child: MyButton(
            text: 'DONE',
            onTap: () async {
              await next();
            },
            isLoading: isNext,
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
                    itemCount: selectedSubCategories.length,
                    itemBuilder: ((context, index) {
                      final String name = selectedSubCategories[index];
                      final String imageUrl = subCategoryImageMap[name]!;

                      return SelectContainer(
                        width: width,
                        text: name,
                        isSelected:
                            chosenSubCategories.keys.toList().contains(name),
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
