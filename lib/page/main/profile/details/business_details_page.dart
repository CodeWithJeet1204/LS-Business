import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/firebase/storage_methods.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/image_picker.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BusinessDetailsPage extends StatefulWidget {
  const BusinessDetailsPage({super.key});

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final specialNoteController = TextEditingController();
  bool isChangingName = false;
  bool isChangingAddress = false;
  bool isChangingSpecialNote = false;
  bool isChangingImage = false;
  bool isSaving = false;

  void changeImage() async {
    Uint8List? im;
    Uint8List? image = await pickImage(ImageSource.gallery);
    im = image;
    if (im != null) {
      try {
        setState(() {
          isChangingImage = true;
        });
        Map<String, dynamic> updatedUserImage = {
          "Image": im,
        };
        String userPhotoUrl = await StorageMethods().uploadImageToStorage(
          'Profile/Shops',
          updatedUserImage["Image"]!,
          false,
        );
        updatedUserImage = {
          "Image": userPhotoUrl,
        };
        await FirebaseFirestore.instance
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update(updatedUserImage);
        setState(() {
          isChangingImage = false;
        });
      } catch (e) {
        setState(() {
          isChangingImage = false;
          mySnackBar(context, e.toString());
        });
      }
    } else {
      if (context.mounted) {
        mySnackBar(context, "Image not selected");
      }
    }
  }

  void save(
    TextEditingController controller,
    String propertyName,
    bool isChanging,
  ) async {
    setState(() {
      isSaving = true;
      isChanging = true;
    });
    try {
      if (controller.text.isEmpty) {
        setState(() {
          isSaving = false;
        });
        return mySnackBar(context, "Enter ${propertyName}");
      } else {
        await FirebaseFirestore.instance
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          propertyName: controller.text.toString(),
        });

        setState(() {
          isSaving = false;
          isChanging = false;
        });
      }
    } catch (e) {
      setState(() {
        isSaving = false;
        isChanging = false;
      });
      mySnackBar(context, e.toString());
    }
  }

  void showImage() {
    final imageStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: ((context) {
        return StreamBuilder(
            stream: imageStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Something went wrong'),
                );
              }

              if (snapshot.hasData) {
                final userData = snapshot.data!;
                return Dialog(
                  elevation: 20,
                  child: InteractiveViewer(
                    child: Image.network(
                      userData['Image'],
                    ),
                  ),
                );
              }
              return Center(
                child: CircularProgressIndicator(
                  color: primaryDark,
                ),
              );
            });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Business Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;

            return StreamBuilder(
                stream: shopStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Something Went Wrong'),
                    );
                  }

                  if (snapshot.hasData) {
                    final shopData = snapshot.data!;

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          isChangingImage
                              ? Container(
                                  width: width * 0.3,
                                  height: width * 0.3,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
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
                                      onTap: isSaving ? null : showImage,
                                      child: CircleAvatar(
                                        radius: width * 0.15,
                                        backgroundImage: NetworkImage(
                                          shopData['Image'],
                                        ),
                                        backgroundColor: primary2,
                                      ),
                                    ),
                                    Positioned(
                                      right: -(width * 0.0015),
                                      bottom: -(width * 0.0015),
                                      child: IconButton.filledTonal(
                                        onPressed: changeImage,
                                        icon: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 40,
                                        ),
                                        tooltip: "Change Photo",
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(height: height * 0.05),

                          // NAME
                          Container(
                            width: width,
                            height:
                                isChangingName ? height * 0.125 : height * 0.08,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isChangingName
                                ? TextField(
                                    maxLength: 24,
                                    autofocus: true,
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      hintText: "Change Name",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: width * 0.05),
                                      Text(
                                        shopData['Name'],
                                        style: TextStyle(
                                          fontSize: shopData['Name'].length > 20
                                              ? 16
                                              : 20,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Expanded(child: Container()),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isChangingName = true;
                                            isChangingAddress = false;
                                            isChangingSpecialNote = false;
                                          });
                                        },
                                        icon: const Icon(Icons.edit),
                                        tooltip: "Edit Name",
                                      ),
                                      SizedBox(width: width * 0.03),
                                    ],
                                  ),
                          ),
                          SizedBox(height: height * 0.02),

                          // ADDRESS
                          Container(
                            width: width,
                            height: isChangingAddress
                                ? height * 0.125
                                : height * 0.08,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isChangingAddress
                                ? TextField(
                                    maxLength: 32,
                                    autofocus: true,
                                    controller: addressController,
                                    decoration: InputDecoration(
                                      hintText: "Change Address",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: width * 0.05),
                                      Text(
                                        shopData['Address'],
                                        style: TextStyle(
                                          fontSize:
                                              shopData['Address'].length > 20
                                                  ? 16
                                                  : 18,
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isChangingName = false;
                                            isChangingAddress = true;
                                            isChangingSpecialNote = false;
                                          });
                                        },
                                        icon: const Icon(Icons.edit),
                                        tooltip: "Edit Addess",
                                      ),
                                      SizedBox(width: width * 0.03),
                                    ],
                                  ),
                          ),
                          SizedBox(height: height * 0.02),

                          // SPECIAL NOTE
                          Container(
                            width: width,
                            height: isChangingSpecialNote
                                ? height * 0.125
                                : height * 0.08,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isChangingSpecialNote
                                ? TextField(
                                    maxLength: 32,
                                    autofocus: true,
                                    controller: specialNoteController,
                                    decoration: InputDecoration(
                                      hintText: "Change Special Note",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: width * 0.05),
                                      Text(
                                        shopData['Special Note'],
                                        style: TextStyle(
                                          fontSize:
                                              shopData['Special Note'].length >
                                                      20
                                                  ? 16
                                                  : 18,
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isChangingName = false;
                                            isChangingAddress = false;
                                            isChangingSpecialNote = true;
                                          });
                                        },
                                        icon: const Icon(Icons.edit),
                                        tooltip: "Edit Special Note",
                                      ),
                                      SizedBox(width: width * 0.03),
                                    ],
                                  ),
                          ),
                          SizedBox(height: height * 0.02),

                          // INDUSTRY
                          Container(
                            width: width,
                            height: height * 0.075,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: width * 0.05),
                                Text(
                                  shopData['Industry'],
                                  style: TextStyle(
                                    fontSize: shopData['Industry'].length > 22
                                        ? 16
                                        : 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.02),

                          // TYPE
                          Container(
                            width: width,
                            height: height * 0.075,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: width * 0.05),
                                Text(
                                  shopData['Type'],
                                  style: TextStyle(
                                    fontSize:
                                        shopData['Type'].length > 22 ? 16 : 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.02),

                          // GST
                          Container(
                            width: width,
                            height: height * 0.075,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: width * 0.05),
                                FittedBox(
                                  child: Text(
                                    shopData['GSTNumber'],
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.02),

                          // MEMBERSHIP
                          Container(
                            width: width,
                            height: height * 0.075,
                            decoration: BoxDecoration(
                              color: shopData['MembershipName'] == "PREMIUM"
                                  ? const Color.fromARGB(255, 202, 226, 238)
                                  : shopData['MembershipName'] == "GOLD"
                                      ? const Color.fromARGB(255, 253, 243, 154)
                                      : white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: width * 0.05),
                                Text(
                                  shopData['MembershipName'],
                                  style: TextStyle(
                                    fontSize:
                                        shopData['MembershipName'].length > 22
                                            ? 16
                                            : 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.05),
                          isChangingName ||
                                  isChangingAddress ||
                                  isChangingSpecialNote
                              ? Column(
                                  children: [
                                    isSaving
                                        ? Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 0,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
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
                                            text: "SAVE",
                                            onTap: () {
                                              if (isChangingName) {
                                                save(
                                                  nameController,
                                                  "Name",
                                                  isChangingName,
                                                );
                                              } else if (isChangingAddress) {
                                                save(
                                                  addressController,
                                                  "Address",
                                                  isChangingAddress,
                                                );
                                              } else if (isChangingSpecialNote) {
                                                save(
                                                  specialNoteController,
                                                  "Special Note",
                                                  isChangingSpecialNote,
                                                );
                                              }
                                            },
                                            isLoading: false,
                                            horizontalPadding: 0,
                                          ),
                                    SizedBox(height: height * 0.015),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom,
                                      ),
                                      child: MyButton(
                                        text: "CANCEL",
                                        onTap: () {
                                          setState(() {
                                            isChangingName = false;
                                            isChangingAddress = false;
                                            isChangingAddress = false;
                                          });
                                        },
                                        isLoading: false,
                                        horizontalPadding: 0,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          SizedBox(height: 40),
                        ],
                      ),
                    );
                  }

                  return Center(
                    child: CircularProgressIndicator(
                      color: primaryDark,
                    ),
                  );
                });
          }),
        ),
      ),
    );
  }
}
