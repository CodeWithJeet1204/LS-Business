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

class OwnerDetailsPage extends StatefulWidget {
  const OwnerDetailsPage({super.key});

  @override
  State<OwnerDetailsPage> createState() => _OwnerDetailsPageState();
}

class _OwnerDetailsPageState extends State<OwnerDetailsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  bool isChangingName = false;
  bool isChangingNumber = false;
  bool isChangingImage = false;
  bool isSaving = false;
  bool isDataLoaded = false;

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
          'Profile/Users',
          updatedUserImage["Image"]!,
          false,
        );
        updatedUserImage = {
          "Image": userPhotoUrl,
        };
        await FirebaseFirestore.instance
            .collection('Business')
            .doc('Owners')
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update(updatedUserImage);
        setState(() {
          isChangingImage = false;
        });
      } catch (e) {
        setState(() {
          isChangingImage = false;
        });
        if (context.mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      if (context.mounted) {
        mySnackBar(context, "Image not selected");
      }
    }
  }

  void save() async {
    try {
      setState(() {
        isSaving = true;
      });
      if (isChangingName && !isChangingNumber) {
        if (nameController.text.isEmpty) {
          mySnackBar(context, "Name should be atleast 1 characters long");
          setState(() {
            isSaving = false;
          });
          return;
        } else {
          Map<String, dynamic> updatedUserName = {
            "Name": nameController.text.toString(),
          };
          await FirebaseFirestore.instance
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(updatedUserName);
        }
        setState(() {
          isSaving = false;
          isChangingName = false;
          isChangingNumber = false;
        });
      } else if (!isChangingName && isChangingNumber) {
        if (numberController.text.length != 10) {
          mySnackBar(context, "Number should be 10 characters long");
          setState(() {
            isSaving = false;
          });
          return;
        } else {
          Map<String, dynamic> updatedUserNumber = {
            "Phone Number": numberController.text.toString(),
          };
          await FirebaseFirestore.instance
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(updatedUserNumber);
          setState(() {
            isSaving = false;
            isChangingName = false;
            isChangingNumber = false;
          });
        }
      } else if (isChangingName && isChangingNumber) {
        if (nameController.text.isEmpty) {
          setState(() {
            isSaving = false;
          });
          return mySnackBar(
            context,
            "Name should be atleast 1 characters long",
          );
        }
        if (numberController.text.length != 10) {
          setState(() {
            isSaving = false;
          });
          return mySnackBar(context, "Number should be 10 characters long");
        } else {
          // NAME
          Map<String, dynamic> updatedUserName = {
            "Name": nameController.text.toString(),
          };
          await FirebaseFirestore.instance
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(updatedUserName);

          // NUMBER
          Map<String, dynamic> updatedUserNumber = {
            "Phone Number": numberController.text.toString(),
          };
          await FirebaseFirestore.instance
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(updatedUserNumber);
          setState(() {
            isSaving = false;
            isChangingName = false;
            isChangingNumber = false;
          });
        }
      }
      setState(() {
        isSaving = false;
      });
    } catch (e) {
      if (context.mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  void showImage() {
    final imageStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Owners')
        .collection('Users')
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
                return const Center(
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
              return const Center(
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
    final userStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Owners')
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Owner Details"),
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: SizedBox(
              width: width,
              height: height,
              child: StreamBuilder(
                  stream: userStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Something went wrong"),
                      );
                    }

                    if (snapshot.hasData) {
                      final userData = snapshot.data!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: Container()),
                          isChangingImage
                              ? Container(
                                  width: width * 0.3,
                                  height: width * 0.3,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryDark,
                                    ),
                                  ),
                                )
                              : Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    GestureDetector(
                                      onTap: showImage,
                                      child: CircleAvatar(
                                        radius: width * 0.15,
                                        backgroundImage: NetworkImage(
                                          userData['Image'],
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
                          Container(
                            width: width,
                            height: height * 0.075,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isChangingName
                                ? TextField(
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
                                        userData['Name'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isChangingName = true;
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
                          Container(
                            width: width,
                            height: height * 0.075,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isChangingNumber
                                ? TextField(
                                    autofocus: true,
                                    controller: numberController,
                                    decoration: InputDecoration(
                                      hintText: "Change Number",
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
                                        userData['Phone Number'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isChangingNumber = true;
                                          });
                                        },
                                        icon: const Icon(Icons.edit),
                                        tooltip: "Edit Phone Number",
                                      ),
                                      SizedBox(width: width * 0.03),
                                    ],
                                  ),
                          ),
                          SizedBox(height: height * 0.02),
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
                                  userData['Email'],
                                  style: TextStyle(
                                    fontSize:
                                        userData['Email'].length > 22 ? 16 : 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.05),
                          isChangingName || isChangingNumber
                              ? Column(
                                  children: [
                                    isSaving
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(
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
                                            onTap: save,
                                            isLoading: false,
                                            horizontalPadding: 0,
                                          ),
                                    SizedBox(height: height * 0.015),
                                    MyButton(
                                      text: "CANCEL",
                                      onTap: () {
                                        setState(() {
                                          isChangingName = false;
                                          isChangingNumber = false;
                                        });
                                      },
                                      isLoading: false,
                                      horizontalPadding: 0,
                                    ),
                                  ],
                                )
                              : Container(),
                          Expanded(child: Container()),
                        ],
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ),
          );
        }),
      ),
    );
  }
}
