import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:localy/events/events_main_page.dart';
import 'package:localy/events/register/events_register_details_page_2.dart';
import 'package:localy/vendors/provider/sign_in_method_provider.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/head_text.dart';
import 'package:localy/widgets/image_pick_dialog.dart';
import 'package:localy/widgets/pick_location.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventsRegisterDetailsPage1 extends StatefulWidget {
  const EventsRegisterDetailsPage1({
    super.key,
  });

  @override
  State<EventsRegisterDetailsPage1> createState() =>
      EventsRegisterDetailsPage1State();
}

class EventsRegisterDetailsPage1State
    extends State<EventsRegisterDetailsPage1> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final GlobalKey<FormState> userFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  bool isImageSelected = false;
  File? _image;
  String? type;
  DateTime? doe;
  double? latitude;
  double? longitude;
  String? address;
  bool gettingLocation = false;
  bool isNext = false;

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  // SELECT IMAGE
  Future<void> selectImage() async {
    XFile? im = await showImagePickDialog(context);
    if (im == null) {
      setState(() {
        isImageSelected = false;
      });
    } else {
      setState(() {
        _image = File(im.path);
        isImageSelected = true;
      });
    }
  }

  // GET ADDRESS
  Future<void> getAddress(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    setState(() {
      address =
          '${placemarks[0].name}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}';
    });
  }

  // SELECT DOE
  Future<void> selectDoe() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        doe = selectedDate;
      });
    } else {
      if (mounted) {
        return mySnackBar(context, 'Select Date Of Establishment');
      }
    }
  }

  // REGISTER
  Future<void> register(SignInMethodProvider signInMethodProvider) async {
    if (userFormKey.currentState!.validate()) {
      if (_image == null) {
        return mySnackBar(context, 'Select an Image');
      }
      if (type == null) {
        return mySnackBar(context, 'Select Type');
      }
      if (doe == null) {
        return mySnackBar(context, 'Select Date of Establishment');
      }
      if (latitude == null || longitude == null) {
        return mySnackBar(context, 'Select Location');
      }

      String? uploadImagePath;
      String? userPhotoUrl;
      setState(() {
        isNext = true;
      });

      try {
        uploadImagePath = _image!.path;
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('Organizers')
            .child(FirebaseAuth.instance.currentUser!.uid);
        await ref.putFile(File(uploadImagePath)).whenComplete(() async {
          await ref.getDownloadURL().then((value) {
            userPhotoUrl = value;
          });
        });

        final eventSnap = await store
            .collection('Organizers')
            .doc(auth.currentUser!.uid)
            .get();

        if (eventSnap.exists && eventSnap.data()!['Description'] != null) {
          Map<String, dynamic> info = {
            'Name': nameController.text,
            'Email': emailController.text,
            'Phone Number': phoneController.text,
            'Website': websiteController.text,
            'Latitude': latitude,
            'Longitude': longitude,
            'Image': userPhotoUrl,
            'ViewsTimestamp': [],
            'Type': type,
            'DOE': DateFormat('d MMM y').format(doe!),
            'workImages': [],
          };

          await store
              .collection('Organizers')
              .doc(auth.currentUser!.uid)
              .update(info);

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: ((context) => const EventsMainPage()),
              ),
              (route) => false,
            );
          }
        } else {
          Map<String, dynamic> info = {
            'Name': nameController.text,
            'Email': emailController.text,
            'Phone Number': phoneController.text,
            'Website': websiteController.text,
            'Latitude': latitude,
            'Longitude': longitude,
            'Image': userPhotoUrl,
            'ViewsTimestamp': [],
            'Type': type,
            'DOE': DateFormat('d MMM y').format(doe!),
            'Description': '',
          };

          await store
              .collection('Organizers')
              .doc(auth.currentUser!.uid)
              .set(info);
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const EventsRegisterDetailsPage2()),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signInMethodProvider = Provider.of<SignInMethodProvider>(context);
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ORG> DETAILS HEADTEXT
              const SizedBox(height: 60),
              const Center(
                child: HeadText(
                  text: 'ORG.\nDETAILS',
                ),
              ),
              const SizedBox(height: 40),

              // IMAGE
              Center(
                child: isImageSelected
                    ? Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          // IMAGE NOT CHOSEN
                          CircleAvatar(
                            radius: width * 0.14,
                            backgroundImage: FileImage(_image!),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.camera_alt_outlined),
                            iconSize: width * 0.09,
                            tooltip: 'Change Organization Picture',
                            onPressed: () async {
                              await selectImage();
                            },
                            color: primaryDark,
                          ),
                        ],
                      )
                    // IMAGE CHOSEN
                    : CircleAvatar(
                        radius: 50,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            size: 60,
                          ),
                          onPressed: () async {
                            await selectImage();
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 12),

              Form(
                key: userFormKey,
                child: Column(
                  children: [
                    // NAME
                    MyTextFormField(
                      hintText: 'Organization Name',
                      controller: nameController,
                      borderRadius: 12,
                      horizontalPadding: width * 0.055,
                      verticalPadding: width * 0.033,
                      autoFillHints: const [AutofillHints.name],
                    ),

                    // EMAIL
                    MyTextFormField(
                      hintText: 'Email',
                      controller: emailController,
                      borderRadius: 12,
                      horizontalPadding: width * 0.055,
                      verticalPadding: width * 0.033,
                      keyboardType: TextInputType.emailAddress,
                      autoFillHints: const [
                        AutofillHints.email,
                      ],
                    ),

                    // NUMBER
                    MyTextFormField(
                      hintText: 'Phone Number',
                      controller: phoneController,
                      borderRadius: 12,
                      horizontalPadding: width * 0.055,
                      verticalPadding: width * 0.033,
                      keyboardType: TextInputType.number,
                      autoFillHints: const [
                        AutofillHints.telephoneNumber,
                      ],
                    ),

                    // LOCATION
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          gettingLocation = true;
                        });
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: ((context) => PickLocationPage()),
                          ),
                        )
                            .then((value) {
                          print('Value: $value');
                          setState(() {
                            latitude = value[0];
                            longitude = value[1];
                            address = value[2];
                          });
                        });
                        setState(() {
                          gettingLocation = false;
                        });
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primary2,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.all(width * 0.025),
                          margin: EdgeInsets.symmetric(
                            horizontal: width * 0.025,
                          ),
                          child: gettingLocation
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Text(
                                  address ?? 'Get Location',
                                  style: TextStyle(
                                    fontSize: width * 0.045,
                                    color: primaryDark2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

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
                          horizontal: width * 0.055,
                          vertical: 12,
                        ),
                        child: DropdownButton(
                          dropdownColor: primary2,
                          hint: const Text(
                            'Type',
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
                          onChanged: (value) {
                            setState(() {
                              type = value;
                            });
                          },
                        ),
                      ),
                    ),

                    // DATE OF ESTABLISHMENT
                    GestureDetector(
                      onTap: () async {
                        await selectDoe();
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primary3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.05,
                            vertical: width * 0.05,
                          ),
                          margin: EdgeInsets.symmetric(
                            horizontal: width * 0.055,
                            vertical: 12,
                          ),
                          child: Text(
                            doe == null
                                ? 'Select Date Of Establishment'
                                : DateFormat('d MMM y').format(doe!),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // NEXT BUTTON
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: MyButton(
                        text: 'NEXT',
                        onTap: () async {
                          await register(signInMethodProvider);
                        },
                        isLoading: isNext,
                        horizontalPadding: width * 0.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
