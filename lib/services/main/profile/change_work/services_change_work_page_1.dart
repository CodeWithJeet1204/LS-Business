import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/services/main/profile/change_work/services_change_work_page_2.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/select_container.dart';
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
  bool isData = false;
  bool isNext = false;

  late List<bool> initialSelection;

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
    print("Places: $places");

    setState(() {
      if (places.contains('Home')) {
        print("Yes 1");
        isHomeSelected = true;
      }
      if (places.contains('Office')) {
        print("Yes 2");
        isOfficeSelected = true;
      }
      if (places.contains('Outdoor')) {
        print("Yes 3");
        isOutdoorSelected = true;
      }
      initialSelection = [isHomeSelected, isOfficeSelected, isOutdoorSelected];
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

    print("Home: $isHomeSelected");
    print("Office: $isOfficeSelected");
    print("Outdoor: $isOutdoorSelected");

    if (isHomeSelected) {
      selectedPlaces.add('Home');
    }
    if (isOfficeSelected) {
      selectedPlaces.add('Office');
    }
    if (isOutdoorSelected) {
      selectedPlaces.add('Outdoor');
    }

    await store.collection('Services').doc(auth.currentUser!.uid).update({
      'Place': selectedPlaces,
      'Category': [],
      'SubCategory': [],
    });

    print("Places: $selectedPlaces");

    setState(() {
      isNext = false;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => ServicesChangeWorkPage2(
              place: selectedPlaces,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Work'),
      ),
      bottomSheet: hasSelectionChanged()
          ? Padding(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width * 0.0225,
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
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
          : Container(
              width: 0,
              height: 0,
            ),
      body: !isData
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width * 0.00625,
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
                      ],
                    ),
                  );
                }),
              ),
            ),
    );
  }
}
