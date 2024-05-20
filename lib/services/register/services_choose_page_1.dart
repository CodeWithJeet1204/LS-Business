import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/services/main/services_main_page.dart';
import 'package:localy/services/register/services_choose_page_2.dart';
import 'package:localy/services/register/services_choose_page_3.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/select_container.dart';
import 'package:localy/widgets/snack_bar.dart';
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
  bool isRetailSelected = false;
  bool isEducationalSelected = false;
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
    }
    if (isOfficeSelected) {
      selectedPlaces.add('Office');
    }
    if (isOutdoorSelected) {
      selectedPlaces.add('Outdoor');
    }
    if (isRetailSelected) {
      selectedPlaces.add('Retail Stores');
    }
    if (isEducationalSelected) {
      selectedPlaces.add('Educational Institutes');
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
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: ((context) => ServicesChoosePage2(
                  place: selectedPlaces,
                )),
          ),
          (route) => false,
        );
      }
    } else if (serviceData['SubCategory'] == null) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: ((context) => ServicesChoosePage3(
                  place: selectedPlaces,
                  category: serviceData['Category'],
                )),
          ),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => const ServicesMainPage()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Place'),
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(width * 0.0125),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SelectContainer(
                      width: width,
                      text: 'Outdoor',
                      isSelected: isOutdoorSelected,
                      onTap: () {
                        setState(() {
                          isOutdoorSelected = !isOutdoorSelected;
                        });
                      },
                    ),
                    SelectContainer(
                      width: width,
                      text: 'Retail Stores',
                      isSelected: isRetailSelected,
                      onTap: () {
                        setState(() {
                          isRetailSelected = !isRetailSelected;
                        });
                      },
                    ),
                  ],
                ),
                SelectContainer(
                  width: width,
                  text: 'Educational Institutes',
                  isSelected: isEducationalSelected,
                  onTap: () {
                    setState(() {
                      isEducationalSelected = !isEducationalSelected;
                    });
                  },
                  imageUrl:
                      'https://cdn.pixabay.com/photo/2016/07/07/16/46/dice-1502706_640.jpg',
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
