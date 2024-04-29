import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/services/main/services_main_page.dart';
import 'package:find_easy/services/register/services_choose_page_2.dart';
import 'package:find_easy/services/register/services_choose_page_3.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/select_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesChoosePage1 extends StatefulWidget {
  const ServicesChoosePage1({super.key});

  @override
  State<ServicesChoosePage1> createState() => _ServicesChoosePage1State();
}

class _ServicesChoosePage1State extends State<ServicesChoosePage1> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isHomeSelected = false;
  bool isOfficeSelected = false;
  bool isOutdoorSelected = false;
  bool isNext = false;

  // NEXT
  Future<void> next() async {
    if (!isHomeSelected && !isOfficeSelected && !isOutdoorSelected) {
      return mySnackBar(context, 'Select a Place');
    }

    setState(() {
      isNext = true;
    });

    List selectedPlaces = [];

    if (isHomeSelected) {
      selectedPlaces.add('Home');
    } else if (isOfficeSelected) {
      selectedPlaces.add('Office');
    } else if (isOutdoorSelected) {
      selectedPlaces.add('Outdoor');
    }

    await store.collection('Services').doc(auth.currentUser!.uid).update({
      'Place': selectedPlaces,
    });

    final serviceSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    setState(() {
      isNext = false;
    });

    if (serviceData['Category'] == null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) => ServicesChoosePage2(
                place: selectedPlaces,
              )),
        ),
      );
    } else if (serviceData['SubCategory'] == null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) => ServicesChoosePage3(
                place: selectedPlaces,
                category: serviceData['Category'],
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
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Place'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.0125,
            vertical: width * 0.0125,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SelectContainer(
                      width: width,
                      text: 'Home',
                      isSelected: isHomeSelected,
                      onTap: () {
                        setState(() {
                          isHomeSelected = !isHomeSelected;
                        });
                      },
                    ),
                    SelectContainer(
                      width: width,
                      text: 'Office',
                      isSelected: isOfficeSelected,
                      onTap: () {
                        setState(() {
                          isOfficeSelected = !isOfficeSelected;
                        });
                      },
                    ),
                  ],
                ),
                SelectContainer(
                  width: width,
                  text: 'Outdoor',
                  isSelected: isOutdoorSelected,
                  onTap: () {
                    setState(() {
                      isOutdoorSelected = !isOutdoorSelected;
                    });
                  },
                  imageUrl:
                      'https://cdn.pixabay.com/photo/2016/07/07/16/46/dice-1502706_640.jpg',
                ),

                SizedBox(height: 24),

                // NEXT
                MyButton(
                  onTap: () async {
                    await next();
                  },
                  text: 'NEXT',
                  isLoading: isNext,
                  horizontalPadding: width * 0.125,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
