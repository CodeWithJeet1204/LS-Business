import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/services/register/services_choose_page_1.dart';
import 'package:localy/vendors/provider/sign_in_method_provider.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/head_text.dart';
import 'package:localy/widgets/image_pick_dialog.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ServicesRegisterDetailsPage extends StatefulWidget {
  const ServicesRegisterDetailsPage({
    super.key,
  });

  @override
  State<ServicesRegisterDetailsPage> createState() =>
      ServicesRegisterDetailsPageState();
}

class ServicesRegisterDetailsPageState
    extends State<ServicesRegisterDetailsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final GlobalKey<FormState> userFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();
  bool isImageSelected = false;
  File? _image;
  bool isNext = false;
  bool? isMale;
  String? firstLanguage;
  String? secondLanguage;

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    addressController.dispose();
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

  // REGISTER
  Future<void> register(SignInMethodProvider signInMethodProvider) async {
    if (userFormKey.currentState!.validate()) {
      if (_image == null) {
        return mySnackBar(context, 'Select an Image');
      }
      if (isMale == null) {
        return mySnackBar(context, 'Select Gender');
      }
      if (firstLanguage == null) {
        return mySnackBar(context, 'Select First Language');
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
            .child('Services/Owners')
            .child(FirebaseAuth.instance.currentUser!.uid);
        await ref.putFile(File(uploadImagePath)).whenComplete(() async {
          await ref.getDownloadURL().then((value) {
            userPhotoUrl = value;
          });
        });

        Map<String, dynamic> info = {
          'Name': nameController.text,
          'Email': emailController.text,
          'Phone Number': phoneController.text,
          'Age': ageController.text,
          'Address': addressController.text,
          'Gender': isMale! ? 'Male' : 'Female',
          'First Language': firstLanguage,
          'Second Language': secondLanguage,
          'Image': userPhotoUrl,
          'ViewsTimestamp': 0,
          'Followers': [],
          'workImages': {},
        };

        await store.collection('Services').doc(auth.currentUser!.uid).set(info);
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: ((context) => const ServicesChoosePage1()),
            ),
          );
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
              // USER DETAILS HEADTEXT
              const SizedBox(height: 100),
              const Center(
                child: HeadText(
                  text: 'YOUR\nDETAILS',
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
                            tooltip: 'Change User Picture',
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
                      hintText: 'Name',
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
                      hintText: 'Phone Number (Personal)',
                      controller: phoneController,
                      borderRadius: 12,
                      horizontalPadding: width * 0.055,
                      verticalPadding: width * 0.033,
                      keyboardType: TextInputType.number,
                      autoFillHints: const [
                        AutofillHints.telephoneNumber,
                      ],
                    ),

                    // AGE
                    MyTextFormField(
                      hintText: 'Age',
                      controller: ageController,
                      borderRadius: 12,
                      keyboardType: TextInputType.number,
                      horizontalPadding: width * 0.055,
                      verticalPadding: width * 0.033,
                      autoFillHints: const [],
                    ),

                    // ADDRESS
                    MyTextFormField(
                      hintText: 'Address',
                      controller: addressController,
                      borderRadius: 12,
                      horizontalPadding: width * 0.055,
                      verticalPadding: width * 0.033,
                      autoFillHints: const [],
                    ),

                    // GENDER
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
                          horizontal: width * 0.05,
                          vertical: 12,
                        ),
                        child: DropdownButton(
                          dropdownColor: primary,
                          hint: const Text(
                            'Select Gender',
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: isMale != null
                              ? (isMale! ? 'Male' : 'Female')
                              : null,
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
                          onChanged: (value) {
                            setState(() {
                              if (value == 'Male') {
                                isMale = true;
                              } else {
                                isMale = false;
                              }
                            });
                          },
                        ),
                      ),
                    ),

                    // FIRST LANGUAGE
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
                          horizontal: width * 0.05,
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
                          onChanged: (value) {
                            if (value == secondLanguage &&
                                secondLanguage != null) {
                              return mySnackBar(
                                context,
                                'First Language cannot be same as Second Language',
                              );
                            } else {
                              setState(() {
                                firstLanguage = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    // SECOND LANGUAGE
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
                          horizontal: width * 0.05,
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
                          onChanged: (value) {
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
                            }
                          },
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
                        horizontalPadding: width * 0.055,
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
