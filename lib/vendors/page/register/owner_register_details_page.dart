import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/page/register/business_register_details_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/image_pick_dialog.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class OwnerRegisterDetailsPage extends StatefulWidget {
  const OwnerRegisterDetailsPage({
    super.key,
    required this.fromMainPage,
  });

  final bool fromMainPage;

  @override
  State<OwnerRegisterDetailsPage> createState() =>
      _OwnerRegisterDetailsPageState();
}

class _OwnerRegisterDetailsPageState extends State<OwnerRegisterDetailsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final userFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  Map<String, dynamic>? userData;
  String? uploadImagePath;
  File? _image;
  bool isImageSelected = false;
  bool isNext = false;
  bool isDialog = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // GET DATA
  Future<void> getData() async {
    final userSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .get();

    final myUserData = userSnap.data()!;

    setState(() {
      userData = myUserData;
    });
  }

  // SELECT IMAGE
  Future<void> selectImage() async {
    final images = await showImagePickDialog(context, true);
    final im = images[0];
    setState(() {
      _image = File(im.path);
      isImageSelected = true;
    });
  }

  // NEXT
  Future<void> next() async {
    if (userFormKey.currentState!.validate()) {
      try {
        String? userPhotoUrl;
        setState(() {
          isNext = true;
          isDialog = true;
        });

        if (_image != null) {
          Reference ref =
              storage.ref().child('Vendor/Owners').child(auth.currentUser!.uid);
          await ref.putFile(File(_image!.path)).whenComplete(() async {
            await ref.getDownloadURL().then((value) {
              userPhotoUrl = value;
            });
          });
        }

        if (userData!['Name'] != null && userData!['Email'] != null) {
          await store
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(auth.currentUser!.uid)
              .update({
            'Phone Number': phoneController.text,
            'Image': userPhotoUrl ??
                'https://upload.wikimedia.org/wikipedia/commons/a/af/Default_avatar_profile.jpg',
          });
        } else if (userData!['Phone Number'] != null) {
          await store
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(auth.currentUser!.uid)
              .update({
            'Name': nameController.text.toString(),
            'Email': emailController.text.toString(),
            'Image': userPhotoUrl ??
                'https://upload.wikimedia.org/wikipedia/commons/a/af/Default_avatar_profile.jpg',
          });
        } else if (userData!['Email'] != null && userData!['Name'] == null) {
          await store
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(auth.currentUser!.uid)
              .update({
            'Name': nameController.text.toString(),
            'Phone Number': phoneController.text.toString(),
            'Image': userPhotoUrl ??
                'https://upload.wikimedia.org/wikipedia/commons/a/af/Default_avatar_profile.jpg',
          });
        } else {
          if (mounted) {
            mySnackBar(context, 'Some error occured');
          }
        }

        setState(() {
          isNext = false;
          isDialog = false;
        });
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BusinessRegisterDetailsPage(
                fromMainPage: false,
              ),
            ),
          );
        }
      } catch (e) {
        setState(() {
          isNext = false;
          isDialog = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 0.5,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Owner Details'),
            actions: [
              IconButton(
                onPressed: () async {
                  await showYouTubePlayerDialog(
                    context,
                    getYoutubeVideoId(
                      '',
                    ),
                  );
                },
                icon: const Icon(
                  Icons.question_mark_outlined,
                ),
                tooltip: 'Help',
              ),
            ],
          ),
          body: userData == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // USER DETAILS HEADTEXT
                        // const SizedBox(height: 100),
                        // const HeadText(
                        //   text: 'OWNER\nDETAILS',
                        // ),
                        // const SizedBox(height: 140),

                        // IMAGE
                        isImageSelected
                            ? Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: width * 0.14,
                                    backgroundImage: FileImage(_image!),
                                  ),
                                  IconButton.filledTonal(
                                    icon: const Icon(Icons.camera_alt_outlined),
                                    iconSize: width * 0.09,
                                    tooltip: 'Change Owner Picture',
                                    onPressed: () async {
                                      await selectImage();
                                    },
                                    color: primaryDark,
                                  ),
                                ],
                              )
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
                        const SizedBox(height: 12),

                        Form(
                          key: userFormKey,
                          child: Column(
                            children: [
                              // NAME
                              MyTextFormField(
                                hintText: 'Your Name*',
                                controller: nameController,
                                borderRadius: 12,
                                horizontalPadding: width * 0.055,
                                verticalPadding: width * 0.033,
                                autoFillHints: const [AutofillHints.name],
                              ),

                              // EMAIL
                              userData!['Registration'] == 'email' ||
                                      userData!['Registration'] == 'google'
                                  ? Container()
                                  : MyTextFormField(
                                      hintText: 'Email*',
                                      controller: emailController,
                                      borderRadius: 12,
                                      horizontalPadding: width * 0.055,
                                      verticalPadding: width * 0.033,
                                      keyboardType: TextInputType.emailAddress,
                                      autoFillHints: const [
                                        AutofillHints.email
                                      ],
                                    ),

                              // NUMBER
                              userData!['Registration'] == 'phone number'
                                  ? Container()
                                  : MyTextFormField(
                                      hintText: 'Your Phone Number*',
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
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: MyButton(
                                  text: widget.fromMainPage ? 'DONE' : 'NEXT',
                                  onTap: () async {
                                    await next();
                                  },
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
        ),
      ),
    );
  }
}
