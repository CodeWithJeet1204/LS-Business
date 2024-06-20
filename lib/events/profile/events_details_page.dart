import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/events/events_main_page.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/details_container.dart';
import 'package:localy/widgets/image_pick_dialog.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EventsDetailsPage extends StatefulWidget {
  const EventsDetailsPage({super.key});

  @override
  State<EventsDetailsPage> createState() => _EventsDetailsPageState();
}

class _EventsDetailsPageState extends State<EventsDetailsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();
  final websiteController = TextEditingController();
  final addressController = TextEditingController();
  String? type;
  String? doe;
  Map<String, dynamic>? data;
  bool isChangingImage = false;
  bool isSaving = false;

  Map<String, bool> isChanging = {
    'Name': false,
    'Email': false,
    'Phone Number': false,
    'Website': false,
    'Address': false,
    'Description': false,
  };

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    final organizerSnap =
        await store.collection('Organizers').doc(auth.currentUser!.uid).get();

    final organizerData = organizerSnap.data()!;

    setState(() {
      type = organizerData['Type'];
      doe = organizerData['DOE'];
      data = organizerData;
    });
  }

  // SHOW IMAGE
  Future<void> showImage(String imageUrl) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: ((context) {
        return Dialog(
          elevation: 20,
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
            ),
          ),
        );
      }),
    );
  }

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
      controller = phoneController;
    } else if (isChanging['Website']!) {
      text = 'Website';
      controller = websiteController;
    } else if (isChanging['Address']!) {
      text = 'Address';
      controller = addressController;
    } else if (isChanging['Description']!) {
      text = 'Description';
      controller = descriptionController;
    }

    await store.collection('Organizers').doc(auth.currentUser!.uid).update({
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
          builder: ((context) => const EventsDetailsPage()),
        ),
      );
    }
  }

  // CHANGE TYPE
  Future<void> changeType(String type) async {
    await store.collection('Organizers').doc(auth.currentUser!.uid).update({
      'Type': type,
    });
  }

  // CHANGE USER IMAGE
  Future<void> changeImage(String previousUrl) async {
    XFile? im = await showImagePickDialog(context);
    String? userPhotoUrl;
    if (im != null) {
      try {
        setState(() {
          isChangingImage = true;
        });
        await storage.refFromURL(previousUrl).delete();

        Map<String, dynamic> updatedUserImage = {
          'Image': im.path,
        };
        Reference ref =
            storage.ref().child('Organizers').child(auth.currentUser!.uid);
        await ref
            .putFile(File(updatedUserImage['Image']!))
            .whenComplete(() async {
          await ref.getDownloadURL().then((value) {
            userPhotoUrl = value;
          });
        });
        updatedUserImage = {
          'Image': userPhotoUrl,
        };
        await FirebaseFirestore.instance
            .collection('Organizers')
            .doc(auth.currentUser!.uid)
            .update(updatedUserImage);
        setState(() {
          isChangingImage = false;
        });
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: ((context) => const EventsMainPage()),
            ),
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: ((context) => const EventsDetailsPage()),
            ),
          );
        }
      } catch (e) {
        setState(() {
          isChangingImage = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      if (mounted) {
        mySnackBar(context, 'Image not selected');
      }
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
                          child: isChangingImage
                              ? const SizedBox(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: primaryDark,
                                    ),
                                  ),
                                )
                              : Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await showImage(data!['Image']);
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
                                    Positioned(
                                      right: -(width * 0.0055),
                                      bottom: -(width * 0.0055),
                                      child: IconButton.filledTonal(
                                        onPressed: () async {
                                          await changeImage(data!['Image']);
                                        },
                                        icon: Icon(
                                          FeatherIcons.camera,
                                          size: width * 0.08,
                                        ),
                                        tooltip: 'Change Image',
                                      ),
                                    ),
                                  ],
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
                          controller: phoneController,
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

                        // DESCRIPTION
                        DetailsContainer(
                          value: data!['Description'],
                          text: 'Description',
                          controller: descriptionController,
                          onTap: () async {
                            edit('Description');
                          },
                          isChanging: isChanging['Description']!,
                          width: width,
                        ),

                        // WEBSITE
                        DetailsContainer(
                          value: data!['Website'],
                          text: 'Website',
                          controller: websiteController,
                          onTap: () async {
                            edit('Website');
                          },
                          isChanging: isChanging['Website']!,
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

                        // TYPE
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primary3,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.0225,
                              vertical: width * 0.0125,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: width * 0.0225,
                              vertical: 12,
                            ),
                            child: DropdownButton(
                              dropdownColor: primary,
                              hint: const Text(
                                'First Language',
                                overflow: TextOverflow.ellipsis,
                              ),
                              value: type,
                              underline: Container(),
                              items: [
                                'For - Profit',
                                'NGO',
                                'Government',
                                'Cooperative',
                                'Professional Assosciations',
                              ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) async {
                                if (value != null) {
                                  setState(() {
                                    type = value;
                                  });
                                  await changeType(value);
                                }
                              },
                            ),
                          ),
                        ),

                        // DOE
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primary3,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(
                              width * 0.05,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: width * 0.0225,
                              vertical: 12,
                            ),
                            child: Text(
                              'DOE: ${doe!}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        // SAVE & CANCEL BUTTON
                        isChanging['Name']! ||
                                isChanging['Phone Number']! ||
                                isChanging['Email']! ||
                                isChanging['Website']! ||
                                isChanging['Description']! ||
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
