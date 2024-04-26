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
    this.category,
    this.place,
  });

  final String? place;
  final String? category;

  @override
  State<ServicesChoosePage3> createState() => _ServicesChoosePage3State();
}

class _ServicesChoosePage3State extends State<ServicesChoosePage3> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isNext = false;
  String? place;
  String? category;
  String? selectedSubCategory;
  bool getData = false;

  // INIT STATE
  @override
  void initState() {
    if (widget.place == null) {
      getPlace();
    }
    if (widget.category == null) {
      getCategory();
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
  }

  // GET CATEGORY
  Future<void> getCategory() async {
    final serviceSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    final myCategory = serviceData['Category'];

    setState(() {
      category = myCategory;
    });
  }

  // SELECT CATEGORY
  void selectSubCategory(String category) {
    setState(() {
      selectedSubCategory = category;
    });
  }

  // NEXT
  Future<void> next() async {
    setState(() {
      isNext = true;
    });
    if (selectedSubCategory != null) {
      await store.collection('Services').doc(auth.currentUser!.uid).update({
        'SubCategory': selectedSubCategory,
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
      mySnackBar(context, 'Select Category');
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
                          itemCount: servicesMap[widget.place ?? place]![
                                  widget.category ?? category]!
                              .length,
                          itemBuilder: ((context, index) {
                            final String name = servicesMap[widget.place ??
                                place]![widget.category ?? category]![index];
                            final String imageUrl = subCategoryImageMap[name]!;

                            return SelectContainer(
                              width: width,
                              text: name,
                              isSelected: selectedSubCategory == name,
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
