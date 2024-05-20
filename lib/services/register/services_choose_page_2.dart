import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/services/main/services_main_page.dart';
import 'package:localy/services/models/services_image_map.dart';
import 'package:localy/services/models/services_map.dart';
import 'package:localy/services/register/services_choose_page_3.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/select_container.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesChoosePage2 extends StatefulWidget {
  const ServicesChoosePage2({
    super.key,
    this.place,
  });

  final List? place;

  @override
  State<ServicesChoosePage2> createState() => _ServicesChoosePage2State();
}

class _ServicesChoosePage2State extends State<ServicesChoosePage2> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isNext = false;
  List place = [];
  List selectedCategories = [];
  List chosenCategories = [];

  // INIT STATE
  @override
  void initState() {
    if (widget.place == null) {
      getPlace();
    } else {
      getCategory(widget.place!);
    }
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

    getCategory(myPlace);
  }

  // GET CATEGORY
  void getCategory(List places) {
    setState(() {
      for (var place in places) {
        selectedCategories.addAll(servicesMap[place]!.keys);
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

      final serviceSnap =
          await store.collection('Services').doc(auth.currentUser!.uid).get();

      final serviceData = serviceSnap.data()!;

      setState(() {
        isNext = false;
      });
      if (serviceData['SubCategory'] == null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: ((context) => ServicesChoosePage3(
                    place: widget.place ?? place,
                    category: chosenCategories,
                  )),
            ),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: ((context) => const ServicesMainPage()),
            ),
            (route) => false,
          );
        }
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
        title: const Text('Choose Your Categorys'),
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
          height: MediaQuery.of(context).size.height - 168,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 16 / 9,
            ),
            itemCount: selectedCategories.length,
            itemBuilder: ((context, index) {
              String name = selectedCategories[index];
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
