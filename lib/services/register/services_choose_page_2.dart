import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/services/main/services_main_page.dart';
import 'package:find_easy/services/models/services_image_map.dart';
import 'package:find_easy/services/models/services_map.dart';
import 'package:find_easy/services/register/services_choose_page_3.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/select_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesChoosePage2 extends StatefulWidget {
  const ServicesChoosePage2({
    super.key,
    this.place,
  });

  final String? place;

  @override
  State<ServicesChoosePage2> createState() => _ServicesChoosePage2State();
}

class _ServicesChoosePage2State extends State<ServicesChoosePage2> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isNext = false;
  String? place;
  String? selectedCategory;

  // INIT STATE
  @override
  void initState() {
    if (widget.place == null) {
      getPlace();
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
  }

  // SELECT CATEGORY
  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  // NEXT
  Future<void> next() async {
    setState(() {
      isNext = true;
    });
    await store.collection('Services').doc(auth.currentUser!.uid).update({
      'Category': selectedCategory,
    });

    if (selectedCategory != null) {
      final serviceSnap =
          await store.collection('Services').doc(auth.currentUser!.uid).get();

      final serviceData = serviceSnap.data()!;

      setState(() {
        isNext = false;
      });

      if (serviceData['SubCategory'] == null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => ServicesChoosePage3(
                  place: widget.place ?? place,
                )),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => ServicesMainPage()),
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
                  itemCount: servicesMap[widget.place ?? place]!.length,
                  itemBuilder: ((context, index) {
                    final String name = servicesMap[widget.place ?? place]!
                        .keys
                        .toList()[index];
                    final String imageUrl = categoryImageMap[name]!;

                    return SelectContainer(
                      width: width,
                      text: name,
                      isSelected: selectedCategory == name,
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
