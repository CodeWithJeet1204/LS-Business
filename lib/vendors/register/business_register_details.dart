import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/vendors/models/industry_segments.dart';
import 'package:localy/vendors/register/select_business_category_page.dart';
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

class BusinessRegisterDetailsPage extends StatefulWidget {
  const BusinessRegisterDetailsPage({
    super.key,
  });

  @override
  State<BusinessRegisterDetailsPage> createState() =>
      _BusinessRegisterDetailsPageState();
}

class _BusinessRegisterDetailsPageState
    extends State<BusinessRegisterDetailsPage> {
  final store = FirebaseFirestore.instance;
  final GlobalKey<FormState> businessFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isNext = false;
  String? selectedIndustrySegment;
  bool isImageSelected = false;
  File? _image;
  String? uploadImagePath;

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    gstController.dispose();
    addressController.dispose();
    descriptionController.dispose();
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

  // UPLOAD DETAILS
  Future<void> uploadDetails() async {
    if (businessFormKey.currentState!.validate()) {
      try {
        String? businessPhotoUrl;
        setState(() {
          isNext = true;
        });
        if (_image != null) {
          uploadImagePath = _image!.path;
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('VendorShops')
              .child(FirebaseAuth.instance.currentUser!.uid);
          await ref.putFile(File(uploadImagePath!)).whenComplete(() async {
            await ref.getDownloadURL().then((value) {
              businessPhotoUrl = value;
            });
          });
        }
        await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'Name': nameController.text.toString(),
          'Views': 0,
          'viewsTimestamp': [],
          'Followers': [],
          'followersDateTime': [],
          'GSTNumber': gstController.text.toString(),
          'Address': addressController.text.toString(),
          'Description': descriptionController.text.toString(),
          'Industry': selectedIndustrySegment,
          'Image': _image != null
              ? businessPhotoUrl
              : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1fDf705o-VZ3lVxTLh0jLPyFApbnwGoNHhSpwODOC0g&s',
        });

        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: ((context) => const SelectBusinessCategoryPage()),
            ),
          );
        }
        setState(() {
          isNext = false;
        });
      } catch (e) {
        setState(() {
          isNext = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.875,
                child: const HeadText(
                  text: 'BUSINESS\nDETAILS',
                ),
              ),
              const SizedBox(height: 40),

              // IMAGE
              isImageSelected
                  ? Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.13885,
                          backgroundImage: FileImage(_image!),
                        ),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.camera_alt_outlined),
                          iconSize: MediaQuery.of(context).size.width * 0.1,
                          tooltip: 'Change Shop Picture',
                          onPressed: () async {
                            await selectImage();
                          },
                          color: primaryDark,
                        ),
                      ],
                    )
                  : CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.13885,
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          size: MediaQuery.of(context).size.width * 0.166,
                        ),
                        onPressed: () async {
                          await selectImage();
                        },
                      ),
                    ),
              const SizedBox(height: 12),
              Form(
                key: businessFormKey,
                child: Column(
                  children: [
                    // SHOP NAME
                    MyTextFormField(
                      hintText: 'Shop Name',
                      controller: nameController,
                      borderRadius: 12,
                      horizontalPadding:
                          MediaQuery.of(context).size.width * 0.055,
                      verticalPadding:
                          MediaQuery.of(context).size.width * 0.01125,
                      autoFillHints: const [AutofillHints.streetAddressLevel1],
                    ),

                    // GST NUMBER
                    MyTextFormField(
                      hintText: 'GST Number',
                      controller: gstController,
                      borderRadius: 12,
                      horizontalPadding:
                          MediaQuery.of(context).size.width * 0.055,
                      verticalPadding:
                          MediaQuery.of(context).size.width * 0.01125,
                      autoFillHints: null,
                    ),

                    // ADDRESS
                    MyTextFormField(
                      hintText: 'Address (Don\'t include Shop Name)',
                      controller: addressController,
                      borderRadius: 12,
                      horizontalPadding:
                          MediaQuery.of(context).size.width * 0.055,
                      verticalPadding:
                          MediaQuery.of(context).size.width * 0.033,
                      keyboardType: TextInputType.streetAddress,
                      autoFillHints: const [AutofillHints.streetAddressLevel2],
                    ),

                    // INDUSTRY SEGMENT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primary2.withOpacity(0.75),
                              width: 1,
                            ),
                          ),
                        ),
                        elevation: 0,
                        isDense: false,
                        menuMaxHeight: 700,
                        itemHeight: 48,
                        dropdownColor: primary2,
                        hint: const Text(
                          overflow: TextOverflow.ellipsis,
                          'Select Industry Segment',
                        ),
                        items: industrySegments
                            .map((element) => DropdownMenuItem(
                                  value: element,
                                  child: Text(
                                      overflow: TextOverflow.ellipsis, element),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedIndustrySegment = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SPECIAL NOTE
                    MyTextFormField(
                      hintText: 'Description',
                      controller: descriptionController,
                      borderRadius: 12,
                      horizontalPadding:
                          MediaQuery.of(context).size.width * 0.055,
                      autoFillHints: null,
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 20),

                    // NEXT
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: MyButton(
                        text: 'NEXT',
                        onTap: () async {
                          await uploadDetails();
                        },
                        isLoading: isNext,
                        horizontalPadding:
                            MediaQuery.of(context).size.width * 0.055,
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
