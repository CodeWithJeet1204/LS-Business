import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Localsearch/vendors/register/business_register_details_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/button.dart';
import 'package:Localsearch/widgets/image_pick_dialog.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

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
  bool isImageSelected = false;
  File? _image;
  bool isNext = false;
  String? uploadImagePath;

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
        });

        Reference ref =
            storage.ref().child('Vendor/Owners').child(auth.currentUser!.uid);
        await ref.putFile(File(_image!.path)).whenComplete(() async {
          await ref.getDownloadURL().then((value) {
            userPhotoUrl = value;
          });
        });

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
          if (context.mounted) {
            mySnackBar(context, 'Some error occured');
          }
        }

        setState(() {
          isNext = false;
        });
        if (context.mounted) {
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
        });
        if (context.mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Owner Details'),
      ),
      body: userData == null
          ? Center(
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
                            hintText: 'Your Name',
                            controller: nameController,
                            borderRadius: 12,
                            horizontalPadding: width * 0.055,
                            verticalPadding: width * 0.033,
                            autoFillHints: const [AutofillHints.name],
                          ),

                          // EMAIL
                          userData!['registration'] == 'email' ||
                                  userData!['registration'] == 'google'
                              ? Container()
                              : MyTextFormField(
                                  hintText: 'Email',
                                  controller: emailController,
                                  borderRadius: 12,
                                  horizontalPadding: width * 0.055,
                                  verticalPadding: width * 0.033,
                                  keyboardType: TextInputType.emailAddress,
                                  autoFillHints: const [AutofillHints.email],
                                ),

                          // NUMBER
                          userData!['registration'] == 'phone number'
                              ? Container()
                              : MyTextFormField(
                                  hintText: 'Your Phone Number',
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
                              text: widget.fromMainPage ? 'DONE' : 'NEXT',
                              onTap: () async {
                                await next();
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
