// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:find_easy/firebase/auth_methods.dart';
import 'package:find_easy/firebase/storage_methods.dart';
import 'package:find_easy/page/register/business_register_details.dart';
import 'package:find_easy/page/register/firestore_info.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/image_picker.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class UserRegisterDetailsPage extends StatefulWidget {
  const UserRegisterDetailsPage({
    super.key,
    required this.emailChosen,
    required this.numberChosen,
    required this.googleChosen,
  });

  final bool emailChosen;
  final bool numberChosen;
  final bool googleChosen;

  @override
  State<UserRegisterDetailsPage> createState() =>
      _UserRegisterDetailsPageState();
}

class _UserRegisterDetailsPageState extends State<UserRegisterDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> userFormKey = GlobalKey<FormState>();
  bool isImageSelected = false;
  Uint8List? _image;
  Uint8List? image2;
  bool isNext = false;

  @override
  void initState() {
    super.initState();
    if (widget.emailChosen) {
      emailController.text == AuthMethods().user.email;
    } else if (widget.numberChosen) {
      phoneController.text == AuthMethods().user.phoneNumber;
    }
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    if (im == null) {
      setState(() {
        isImageSelected = false;
      });
    } else {
      setState(() {
        _image = im;
        isImageSelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final FirebaseAuth _auth = FirebaseAuth.instance;
    // ignore: unused_local_variable
    final AuthMethods auth = AuthMethods();
    final String uid = _auth.currentUser!.uid;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 723,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                const HeadText(text: "USER\nDETAILS"),
                const SizedBox(height: 40),
                widget.googleChosen
                    ? Container()
                    : Column(
                        children: [
                          isImageSelected
                              ? Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage: MemoryImage(_image!),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: IconButton.filledTonal(
                                        icon: const Icon(
                                            Icons.camera_alt_outlined),
                                        iconSize: 30,
                                        tooltip: "Change User Picture",
                                        onPressed: selectImage,
                                        color: primaryDark,
                                      ),
                                    ),
                                  ],
                                )
                              : CircleAvatar(
                                  radius: 50,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 60,
                                    ),
                                    onPressed: selectImage,
                                  ),
                                ),
                          const SizedBox(height: 12),
                        ],
                      ),
                Form(
                  key: userFormKey,
                  child: Column(
                    children: [
                      widget.googleChosen
                          ? Container()
                          : MyTextFormField(
                              hintText: "Your Name",
                              controller: nameController,
                              borderRadius: 12,
                              horizontalPadding: 20,
                              verticalPadding: 12,
                              autoFillHints: const [AutofillHints.name],
                            ),
                      widget.emailChosen || widget.googleChosen
                          ? Container()
                          : MyTextFormField(
                              hintText:
                                  widget.emailChosen ? "Same Email" : "Email",
                              controller: emailController,
                              borderRadius: 12,
                              horizontalPadding: 20,
                              verticalPadding: 12,
                              keyboardType: TextInputType.emailAddress,
                              autoFillHints: const [AutofillHints.email],
                            ),
                      widget.numberChosen
                          ? Container()
                          : widget.googleChosen || widget.emailChosen
                              ? MyTextFormField(
                                  hintText: "Your Phone Number (Personal)",
                                  controller: phoneController,
                                  borderRadius: 12,
                                  horizontalPadding: 20,
                                  verticalPadding: 12,
                                  keyboardType: TextInputType.number,
                                  autoFillHints: const [
                                    AutofillHints.telephoneNumber
                                  ],
                                )
                              : Container(),
                      MyButton(
                        text: "Next",
                        onTap: () async {
                          if (userFormKey.currentState!.validate()) {
                            if (confirmPasswordController.text ==
                                passwordController.text) {
                              try {
                                if (_image == null) {
                                  setState(() {
                                    File imageFile = File('files/profile.png');
                                    image2 = imageFile.readAsBytesSync();
                                  });
                                }
                                print("Started");
                                setState(() {
                                  isNext = true;
                                });
                                userImage.addAll({
                                  "Image": isImageSelected
                                      ? _image == null
                                          ? image2!
                                          : _image!
                                      : image2!,
                                });
                                print("Image Added");
                                String userPhotoUrl =
                                    await StorageMethods().uploadImageToStorage(
                                  'Users',
                                  userImage["Image"]!,
                                  false,
                                );
                                print("Image URL DONE");
                                !widget.numberChosen
                                    ? userFirestoreData.addAll(
                                        {
                                          "uid": uid,
                                          "Name": widget.googleChosen
                                              ? FirebaseAuth.instance
                                                  .currentUser!.displayName
                                              : nameController.text.toString(),
                                          "Phone Number": phoneController.text,
                                          "Image": userPhotoUrl,
                                        },
                                      )
                                    : userFirestoreData.addAll({
                                        "uid": uid,
                                        "Email":
                                            emailController.text.toString(),
                                        "Name": nameController.text.toString(),
                                        "Image": userPhotoUrl,
                                      });
                                print("DONE");
                                setState(() {
                                  isNext = false;
                                });
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BusinessRegisterDetailsPage(),
                                  ),
                                );
                              } catch (e) {
                                setState(() {
                                  isNext = false;
                                });
                                if (context.mounted) {
                                  mySnackBar(context, e.toString());
                                }
                              }
                            } else {
                              mySnackBar(
                                context,
                                "Passwords do not match. Check Again!",
                              );
                            }
                          }
                        },
                        isLoading: isNext,
                        horizontalPadding: 20,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
