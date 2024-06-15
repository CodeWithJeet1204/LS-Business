import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/details_container.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesDetailsPage extends StatefulWidget {
  const ServicesDetailsPage({super.key});

  @override
  State<ServicesDetailsPage> createState() => _ServicesDetailsPageState();
}

class _ServicesDetailsPageState extends State<ServicesDetailsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();
  String? firstLanguage;
  String? secondLanguage;
  bool isSaving = false;
  Map<String, dynamic>? data;
  bool isMale = true;

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

    setState(() {
      isMale = serviceData['Gender'] == 'Male';
      firstLanguage = serviceData['First Language'];
      secondLanguage = serviceData['Second Language'];
      data = serviceData;
    });
  }

  // SHOW IMAGE
  Future<void> showImage() async {
    final imageStream = FirebaseFirestore.instance
        .collection('Services')
        .doc(auth.currentUser!.uid)
        .snapshots();

    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: ((context) {
        return StreamBuilder(
            stream: imageStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    'Something went wrong',
                  ),
                );
              }

              if (snapshot.hasData) {
                final userData = snapshot.data!;
                return Dialog(
                  elevation: 20,
                  child: InteractiveViewer(
                    child: Image.network(
                      userData['Image'] ??
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                    ),
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryDark,
                ),
              );
            });
      }),
    );
  }

  // EDIT
  // void edit(bool isChanging) {
  //   setState(() {
  //     if (isChanging == isChangingName) {
  //       isChangingName = true;
  //       isChangingAddress = false;
  //       isChangingAge = false;
  //       isChangingEmail = false;
  //       isChangingPhone = false;
  //       return;
  //     } else if (isChanging == isChangingAddress) {
  //       isChangingAddress = true;
  //       isChangingName = false;
  //       isChangingAge = false;
  //       isChangingEmail = false;
  //       isChangingPhone = false;
  //       return;
  //     } else if (isChanging == isChangingAge) {
  //       isChangingAge = true;
  //       isChangingName = false;
  //       isChangingAddress = false;
  //       isChangingEmail = false;
  //       isChangingPhone = false;
  //       return;
  //     } else if (isChanging == isChangingEmail) {
  //       isChangingEmail = true;
  //       isChangingName = false;
  //       isChangingAge = false;
  //       isChangingAddress = false;
  //       isChangingPhone = false;
  //       return;
  //     } else if (isChanging == isChangingPhone) {
  //       isChangingPhone = true;
  //       isChangingName = false;
  //       isChangingAge = false;
  //       isChangingEmail = false;
  //       isChangingAddress = false;
  //       return;
  //     }
  //   });
  // }

  Map<String, bool> isChanging = {
    'Name': false,
    'Email': false,
    'Phone Number': false,
    'Age': false,
    'Address': false,
  };

  // EDIT
  void edit(String key) {
    setState(() {
      isChanging.forEach((key, value) {
        isChanging[key] = false;
      });
      isChanging[key] = true;
    });
  }

  // EDIT DATA
  Future<void> save() async {
    String? text;
    TextEditingController? controller;

    if (isChanging['Name']!) {
      text = 'Name';
      controller = nameController;
    } else if (isChanging['Email']!) {
      text = 'Email';
      controller = emailController;
    } else if (isChanging['Phone Number']!) {
      text = 'Phone Number';
      controller = phoneNumberController;
    } else if (isChanging['Age']!) {
      text = 'Age';
      controller = ageController;
    } else if (isChanging['Address']!) {
      text = 'Address';
      controller = addressController;
    }

    await store.collection('Services').doc(auth.currentUser!.uid).update({
      text!: controller!.text,
    });

    setState(() {
      isSaving = false;
      setState(() {
        isChanging.forEach((key, value) {
          isChanging[key] = false;
        });
      });
    });
    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) => const ServicesDetailsPage()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Details'),
      ),
      body: data == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.0125,
                ),
                child: LayoutBuilder(builder: ((context, constraints) {
                  final width = constraints.maxWidth;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // IMAGE
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: GestureDetector(
                              onTap: () async {
                                await showImage();
                              },
                              child: CircleAvatar(
                                radius: width * 0.1195,
                                backgroundColor: primary2,
                                backgroundImage: NetworkImage(
                                  data!['Image'] ??
                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpFN1Tvo80rYwu-eXsDNNzsuPITOdtyRPlYIsIqKaIbw&s',
                                ),
                              ),
                            ),
                          ),
                        ),

                        // NAME
                        DetailsContainer(
                          value: data!['Name'],
                          text: 'Name',
                          controller: nameController,
                          onTap: () async {
                            edit('Name');
                          },
                          isChanging: isChanging['Name']!,
                          width: width,
                        ),

                        // PHONE NUMBER
                        DetailsContainer(
                          value: data!['Phone Number'],
                          text: 'Phone Number',
                          controller: phoneNumberController,
                          onTap: () async {
                            edit('Phone Number');
                          },
                          isChanging: isChanging['Phone Number']!,
                          width: width,
                        ),

                        // EMAIL
                        DetailsContainer(
                          value: data!['Email'],
                          text: 'Email',
                          controller: emailController,
                          onTap: () async {
                            edit('Email');
                          },
                          isChanging: isChanging['Email']!,
                          width: width,
                        ),

                        // AGE
                        DetailsContainer(
                          value: data!['Age'],
                          text: 'Age',
                          controller: ageController,
                          onTap: () async {
                            edit('Age');
                          },
                          isChanging: isChanging['Age']!,
                          width: width,
                        ),

                        // ADDRESS
                        DetailsContainer(
                          value: data!['Address'],
                          text: 'Address',
                          controller: addressController,
                          onTap: () async {
                            edit('Address');
                          },
                          isChanging: isChanging['Address']!,
                          width: width,
                        ),

                        // GENDER
                        Container(
                          decoration: BoxDecoration(
                            color: primary3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.0225,
                            vertical: width * 0.0125,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: DropdownButton(
                            dropdownColor: primary,
                            hint: const Text(
                              'Select Gender',
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: (isMale ? 'Male' : 'Female'),
                            underline: Container(),
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                            ],
                            onChanged: (value) async {
                              setState(() {
                                if (value == 'Male') {
                                  isMale = true;
                                } else {
                                  isMale = false;
                                }
                              });
                              await store
                                  .collection('Services')
                                  .doc(auth.currentUser!.uid)
                                  .update({
                                'Gender': value,
                              });
                            },
                          ),
                        ),

                        // FIRST LANGUAGE
                        Container(
                          decoration: BoxDecoration(
                            color: primary3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.0225,
                            vertical: width * 0.0125,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: DropdownButton(
                            dropdownColor: primary,
                            hint: const Text(
                              'First Language',
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: firstLanguage,
                            underline: Container(),
                            items: [
                              'Hindi',
                              'English',
                              'Marathi',
                            ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) async {
                              if (value == secondLanguage &&
                                  firstLanguage != null) {
                                return mySnackBar(
                                  context,
                                  'First Language cannot be same as First Language',
                                );
                              } else {
                                setState(() {
                                  firstLanguage = value;
                                });
                                await store
                                    .collection('Services')
                                    .doc(auth.currentUser!.uid)
                                    .update({
                                  'First Language': value,
                                });
                              }
                            },
                          ),
                        ),

                        // SECOND LANGUAGE
                        Container(
                          decoration: BoxDecoration(
                            color: primary3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.0225,
                            vertical: width * 0.0125,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: DropdownButton(
                            dropdownColor: primary,
                            hint: const Text(
                              'Second Language',
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: secondLanguage,
                            underline: Container(),
                            items: [
                              'Hindi',
                              'English',
                              'Marathi',
                            ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) async {
                              if (value == firstLanguage &&
                                  firstLanguage != null) {
                                return mySnackBar(
                                  context,
                                  'Second Language cannot be same as First Language',
                                );
                              } else {
                                setState(() {
                                  secondLanguage = value;
                                });
                                await store
                                    .collection('Services')
                                    .doc(auth.currentUser!.uid)
                                    .update({
                                  'Second Language': value,
                                });
                              }
                            },
                          ),
                        ),

                        // SAVE & CANCEL BUTTON
                        isChanging['Name']! ||
                                isChanging['Phone Number']! ||
                                isChanging['Email']! ||
                                isChanging['Age']! ||
                                isChanging['Address']!
                            ? Column(
                                children: [
                                  // SAVE
                                  isSaving
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          alignment: Alignment.center,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: buttonColor,
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: white,
                                            ),
                                          ))
                                      : MyButton(
                                          text: 'SAVE',
                                          onTap: () async {
                                            setState(() {
                                              isSaving = true;
                                            });
                                            await save();
                                          },
                                          isLoading: false,
                                          horizontalPadding: 0,
                                        ),
                                  const SizedBox(height: 12),

                                  // CANCEL
                                  MyButton(
                                    text: 'CANCEL',
                                    onTap: () {
                                      setState(() {
                                        setState(() {
                                          isChanging.forEach((key, value) {
                                            isChanging[key] = false;
                                          });
                                        });
                                      });
                                    },
                                    isLoading: false,
                                    horizontalPadding: 0,
                                  ),
                                ],
                              )
                            : Container(),

                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                })),
              ),
            ),
    );
  }
}
