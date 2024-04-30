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

    super.initState();
  }

  // GET CATEGORY
  void getCategory() {
    setState(() {
      for (var place in widget.place) {
        allCategories.addAll(servicesMap[place]!.keys);
      }
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

      setState(() {
        isNext = false;
      });
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => ServicesChangeWorkPage3(
                  place: widget.place,
                  category: chosenCategories,
                )),
          ),
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
        title: const Text('Choose Your Category'),
        automaticallyImplyLeading: false,
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 60,
          child: MyButton(
            text: 'NEXT',
            onTap: () async {
              await next();
            },
            isLoading: isNext,
            horizontalPadding: MediaQuery.of(context).size.width * 0.0225,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.0125),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 16 / 9,
            ),
            itemCount: allCategories.length,
            itemBuilder: ((context, index) {
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
      ),
    );
  }
}
