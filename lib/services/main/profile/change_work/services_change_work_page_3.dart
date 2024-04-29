import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/services/main/services_main_page.dart';
import 'package:find_easy/services/models/services_image_map.dart';
import 'package:find_easy/services/models/services_map.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/select_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesChangeWorkPage3 extends StatefulWidget {
  const ServicesChangeWorkPage3({
    super.key,
    required this.category,
    required this.place,
  });

  final List place;
  final List category;

  @override
  State<ServicesChangeWorkPage3> createState() =>
      _ServicesChangeWorkPage3State();
}

class _ServicesChangeWorkPage3State extends State<ServicesChangeWorkPage3> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isNext = false;
  List selectedSubCategories = [];
  List chosenSubCategories = [];
  bool getData = false;

  // INIT STATE
  @override
  void initState() {
    getSubCategory();
    print("SubCategories: $selectedSubCategories");
    setState(() {
      getData = true;
    });
    super.initState();
  }

  // GET SUBCATEGORIES
  void getSubCategory() {
    widget.place.forEach((place) {
      if (servicesMap.containsKey(place)) {
        widget.category.forEach((category) {
          if (servicesMap[place]!.containsKey(category)) {
            selectedSubCategories.addAll(servicesMap[place]![category]!);
          }
        });
      }
    });
  }

  // SELECT CATEGORY
  void selectSubCategory(String subCategory) {
    setState(() {
      if (chosenSubCategories.contains(subCategory)) {
        chosenSubCategories.remove(subCategory);
      } else {
        chosenSubCategories.add(subCategory);
      }
    });
  }

  // NEXT
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

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: ((context) => ServicesMainPage()),
        ),
        (route) => false,
      );
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
        title: Text('Choose Your Sub Category'),
        automaticallyImplyLeading: false,
      ),
      body: !getData
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.0125,
                  vertical: width * 0.0125,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 168,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                              isSelected: chosenSubCategories.contains(name),
                              onTap: () {
                                selectSubCategory(name);
                              },
                              imageUrl: imageUrl,
                            );
                          }),
                        ),
                      ),

                      // NEXT
                      MyButton(
                        text: 'DONE',
                        onTap: () async {
                          await next();
                        },
                        isLoading: isNext,
                        horizontalPadding: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
