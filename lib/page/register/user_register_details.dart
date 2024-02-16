import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/register/business_register_details.dart';
import 'package:find_easy/provider/sign_in_method_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/image_pick_dialog.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserRegisterDetailsPage extends StatefulWidget {
  const UserRegisterDetailsPage({
    super.key,
  });

  @override
  State<UserRegisterDetailsPage> createState() =>
      _UserRegisterDetailsPageState();
}

class _UserRegisterDetailsPageState extends State<UserRegisterDetailsPage> {
  final GlobalKey<FormState> userFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isImageSelected = false;
  File? _image;
  bool isNext = false;
  String? uploadImagePath;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // SELECT IMAGE
  void selectImage() async {
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

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final store = FirebaseFirestore.instance;
    final String uid = auth.currentUser!.uid;
    final signInMethodProvider = Provider.of<SignInMethodProvider>(context);
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // USER DETAILS HEADTEXT
              const SizedBox(height: 100),
              const HeadText(text: "USER\nDETAILS"),
              const SizedBox(height: 40),

              Column(
                children: [
                  isImageSelected
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
                              tooltip: "Change User Picture",
                              onPressed: selectImage,
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
                    // NAME
                    MyTextFormField(
                      hintText: "Your Name",
                      controller: nameController,
                      borderRadius: 12,
                      horizontalPadding: width * 0.055,
                      verticalPadding: width * 0.033,
                      autoFillHints: const [AutofillHints.name],
                    ),

                    // EMAIL
                    !signInMethodProvider.isNumberChosen
                        ? Container()
                        : MyTextFormField(
                            hintText: "Email",
                            controller: emailController,
                            borderRadius: 12,
                            horizontalPadding: width * 0.055,
                            verticalPadding: width * 0.033,
                            keyboardType: TextInputType.emailAddress,
                            autoFillHints: const [AutofillHints.email],
                          ),

                    // NUMBER
                    signInMethodProvider.isNumberChosen
                        ? Container()
                        : MyTextFormField(
                            hintText: "Your Phone Number (Personal)",
                            controller: phoneController,
                            borderRadius: 12,
                            horizontalPadding: width * 0.055,
                            verticalPadding: width * 0.033,
                            keyboardType: TextInputType.number,
                            autoFillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                          ),

                    // NEXT BUTTON
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: MyButton(
                        text: "Next",
                        onTap: () async {
                          if (userFormKey.currentState!.validate()) {
                            if (confirmPasswordController.text ==
                                passwordController.text) {
                              if (_image != null) {
                                try {
                                  String? userPhotoUrl;
                                  setState(() {
                                    isNext = true;
                                  });
                                  uploadImagePath = _image!.path;
                                  Reference ref = FirebaseStorage.instance
                                      .ref()
                                      .child('Profile/Owners')
                                      .child(FirebaseAuth
                                          .instance.currentUser!.uid);
                                  await ref
                                      .putFile(File(uploadImagePath!))
                                      .whenComplete(() async {
                                    await ref.getDownloadURL().then((value) {
                                      userPhotoUrl = value;
                                    });
                                  });
                                  final getUser = await store
                                      .collection('Business')
                                      .doc('Owners')
                                      .collection('Users')
                                      .doc(auth.currentUser!.uid)
                                      .get();
                                  if (getUser['Name'] != null &&
                                      getUser['Email'] != null) {
                                    await store
                                        .collection('Business')
                                        .doc('Owners')
                                        .collection('Users')
                                        .doc(auth.currentUser!.uid)
                                        .update({
                                      "Phone Number": phoneController.text,
                                      "Image": userPhotoUrl,
                                    });
                                  } else if (getUser['Phone Number'] != null) {
                                    await store
                                        .collection('Business')
                                        .doc('Owners')
                                        .collection('Users')
                                        .doc(auth.currentUser!.uid)
                                        .update({
                                      "uid": uid,
                                      "Email": emailController.text.toString(),
                                      "Name": nameController.text.toString(),
                                      "Image": userPhotoUrl,
                                    });
                                  } else if (getUser['Email'] != null &&
                                      getUser['Name'] == null) {
                                    await store
                                        .collection('Business')
                                        .doc('Owners')
                                        .collection('Users')
                                        .doc(auth.currentUser!.uid)
                                        .update({
                                      "uid": uid,
                                      "Phone Number":
                                          phoneController.text.toString(),
                                      "Image": userPhotoUrl,
                                      "Name": nameController.text.toString(),
                                    });
                                  } else {
                                    if (context.mounted) {
                                      mySnackBar(context, "Some error occured");
                                    }
                                  }

                                  setState(() {
                                    isNext = false;
                                  });
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BusinessRegisterDetailsPage(),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setState(() {
                                    isNext = false;
                                  });
                                  if (context.mounted) {
                                    mySnackBar(context, e.toString());
                                  }
                                }
                              } else {
                                mySnackBar(context, "Select Profile Image");
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
