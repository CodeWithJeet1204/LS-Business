import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Localsearch/services/main/profile/change_work/services_change_work_page_2.dart';
import 'package:Localsearch/widgets/button.dart';
import 'package:Localsearch/widgets/select_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesChangeWorkPage1 extends StatefulWidget {
  const ServicesChangeWorkPage1({
    super.key,
  });

  @override
  State<ServicesChangeWorkPage1> createState() =>
      _ServicesChangeWorkPage1State();
}

class _ServicesChangeWorkPage1State extends State<ServicesChangeWorkPage1> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isHomeSelected = false;
  bool isOfficeSelected = false;
  bool isOutdoorSelected = false;
  bool isRetailSelected = false;
  bool isEducationalSelected = false;
  bool isData = false;
  bool isNext = false;

  List<bool>? initialSelection;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    final serviceSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    final List places = serviceData['Place'];

    setState(() {
      if (places.contains('Home')) {
        isHomeSelected = true;
      }
      if (places.contains('Office')) {
        isOfficeSelected = true;
      }
      if (places.contains('Outdoor')) {
        isOutdoorSelected = true;
      }
      if (places.contains('Retail Stores')) {
        isRetailSelected = true;
      }
      if (places.contains('Educational Institutes')) {
        isEducationalSelected = true;
      }
      initialSelection = [];
      isData = true;
    });
  }

  // LIST EQUALS
  bool listEquals(List<dynamic>? a, List<dynamic>? b) {
    if (a == null || b == null) {
      return a == b;
    }
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }

  // HAS SELECTION CHANGED
  bool hasSelectionChanged() {
    final currentSelection = [
      isHomeSelected,
      isOfficeSelected,
      isOutdoorSelected
    ];
    return !listEquals(initialSelection, currentSelection);
  }

  // NEXT
  Future<void> next() async {
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
      'Category': [],
      'SubCategory': {},
    });

    setState(() {
      isNext = false;
    });
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) => ServicesChangeWorkPage2(
                place: selectedPlaces,
              )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Work'),
      ),
      bottomSheet: hasSelectionChanged()
          ? Padding(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width * 0.0225,
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: MyButton(
                  onTap: () async {
                    await next();
                  },
                  text: 'NEXT',
                  isLoading: isNext,
                  horizontalPadding: MediaQuery.of(context).size.width * 0.125,
                ),
              ),
            )
          : const SizedBox(
              width: 0,
              height: 0,
            ),
      body: !isData
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width * 0.0125,
              ),
              child: LayoutBuilder(
                builder: ((context, constraints) {
                  final width = constraints.maxWidth;

                  return SingleChildScrollView(
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
                              imageUrl:
                                  'https://cdn.pixabay.com/photo/2016/07/07/16/46/dice-1502706_640.jpg',
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
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
    );
  }
}
