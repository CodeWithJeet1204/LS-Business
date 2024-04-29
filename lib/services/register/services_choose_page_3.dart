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

  final List? place;
  final List? category;

  @override
  State<ServicesChoosePage3> createState() => _ServicesChoosePage3State();
}

class _ServicesChoosePage3State extends State<ServicesChoosePage3> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isNext = false;
  List place = [];
  List category = [];
  List selectedSubCategories = [];
  List chosenSubCategories = [];
  bool getData = false;

  // INIT STATE
  @override
  void initState() {
    if (widget.place == null) {
      getPlace();
    }
    if (widget.category == null) {
      if (widget.place == null) {
        getCategory(place);
      } else {
        getCategory(widget.place!);
      }
    }
    if (widget.place == null && widget.category == null) {
      getSubCategory(place, category);
    } else if (widget.place != null && widget.category == null) {
      getSubCategory(widget.place!, category);
    } else if (widget.place == null && widget.category != null) {
      getSubCategory(place, widget.category!);
    } else {
      getSubCategory(place, category);
    }
    setState(() {
      getData = true;
    });
    super.initState();
  }

  // GET PLACE
  Future<void> getPlace() async {
    final serviceSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    final myPlace = serviceData['Place'];

    setState(() {
      place = myPlace;
    });

    await getCategory(myPlace);
  }

  // GET CATEGORY
  Future<void> getCategory(List place) async {
    final serviceSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    final myCategory = serviceData['Category'];

    setState(() {
      category = myCategory;
    });

    getSubCategory(place, myCategory);
  }

  // GET SUBCATEGORIES
  void getSubCategory(List places, List categories) {
    for (var place in places) {
      if (servicesMap.containsKey(place)) {
        for (var category in categories) {
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
      mySnackBar(context, 'Select Category');
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
      body: !getData
          ? const Center(
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
                        text: 'NEXT',
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
