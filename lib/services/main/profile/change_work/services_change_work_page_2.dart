import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/services/main/profile/change_work/services_change_work_page_3.dart';
import 'package:find_easy/services/models/services_image_map.dart';
import 'package:find_easy/services/models/services_map.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/select_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesChangeWorkPage2 extends StatefulWidget {
  const ServicesChangeWorkPage2({
    super.key,
    required this.place,
  });

  final List place;

  @override
  State<ServicesChangeWorkPage2> createState() =>
      _ServicesChangeWorkPage2State();
}

class _ServicesChangeWorkPage2State extends State<ServicesChangeWorkPage2> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isNext = false;
  List allCategories = [];
  List chosenCategories = [];

  // INIT STATE
  @override
  void initState() {
    getCategory();

    print('Selected Categories: $allCategories');
    super.initState();
  }

  // GET CATEGORY
  void getCategory() {
    setState(() {
      widget.place.forEach((place) {
        allCategories.addAll(servicesMap[place]!.keys);
      });
    });
  }

  // SELECT CATEGORY
  void selectCategory(String category) {
    setState(() {
      if (chosenCategories.contains(category)) {
        chosenCategories.remove(category);
      } else {
        chosenCategories.add(category);
      }
    });
  }

  // NEXT
  Future<void> next() async {
    setState(() {
      isNext = true;
    });
    if (chosenCategories.isNotEmpty) {
      await store.collection('Services').doc(auth.currentUser!.uid).update({
        'Category': chosenCategories,
      });

      print("Chosen Categories: $chosenCategories");

      setState(() {
        isNext = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) => ServicesChangeWorkPage3(
                place: widget.place,
                category: chosenCategories,
              )),
        ),
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
        title: Text('Choose Your Category'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 16 / 9,
                  ),
                  itemCount: allCategories.length,
                  itemBuilder: ((context, index) {
                    print('Selected Categories: $allCategories');
                    String name = allCategories[index];
                    String imageUrl = categoryImageMap[name]!;

                    return SelectContainer(
                      width: width,
                      text: name,
                      isSelected: chosenCategories.contains(name),
                      onTap: () {
                        selectCategory(name);
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
    );
  }
}
