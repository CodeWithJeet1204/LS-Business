import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/image_pick_dialog.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BusinessDetailsPage extends StatefulWidget {
  const BusinessDetailsPage({super.key});

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  String name = "";
  String phoneNo = "";
  String email = "";
  String photoUrl = "";
  Uint8List? newImage;
  Map<String, dynamic> userData = {};
  bool isChangingName = false;
  bool isChangingNumber = false;
  bool isSaving = false;
  bool isDataLoaded = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnap = await FirebaseFirestore
          .instance
          .collection('Business')
          .doc('Owners')
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      userData = userSnap.data()!;
      setState(() {
        name = userData["Name"];
        phoneNo = userData["Phone Number"];
        email = userData["Email"];
        photoUrl = userData["Image"];
      });

      setState(() {});
    } catch (e) {
      mySnackBar(context, e.toString());
    }
  }

  void changeImage() {
    newImage = showImagePickDialog(context);
    if (newImage != null) {}
  }

  void save() async {
    try {
      setState(() {
        isSaving = false;
      });
      if (isChangingName && !isChangingNumber) {
        if (nameController.text.length < 1) {
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
        Navigator.of(context).popAndPushNamed('/ownerDetails');

        return;
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
          Navigator.of(context).popAndPushNamed('/ownerDetails');

          return;
        }
      } else if (isChangingName && isChangingNumber) {
        if (nameController.text.length < 1) {
          mySnackBar(context, "Name should be atleast 1 characters long");
          setState(() {
            isSaving = false;
          });
          return;
        }
        if (numberController.text.length != 10) {
          mySnackBar(context, "Number should be 10 characters long");
          setState(() {
            isSaving = false;
          });
          return;
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
          Navigator.of(context).popAndPushNamed('/ownerDetails');
        }
      }
      setState(() {
        isSaving = false;
      });
    } catch (e) {
      mySnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Owner Details"),
      ),
      body: /*!isDataLoaded
          ? Center(
              child: CircularProgressIndicator(
                color: primaryDark,
              ),
            )
          :*/
          LayoutBuilder(
        builder: ((context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                photoUrl != ""
                    ? Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: width * 0.15,
                            backgroundImage: NetworkImage(photoUrl),
                            backgroundColor: primary2,
                          ),
                          Positioned(
                            right: -(width * 0.0015),
                            bottom: -(width * 0.0015),
                            child: IconButton.filledTonal(
                              onPressed: changeImage,
                              icon: Icon(
                                Icons.camera_alt_outlined,
                                size: 40,
                              ),
                              tooltip: "Change Photo",
                            ),
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(height: height * 0.05),
                Container(
                  width: width,
                  height: height * 0.075,
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
                              name,
                              style: TextStyle(
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
                              icon: Icon(Icons.edit),
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
                              phoneNo,
                              style: TextStyle(
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
                              icon: Icon(Icons.edit),
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
                        email,
                        style: TextStyle(
                          fontSize: email.length > 22 ? 16 : 18,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.05),
                isChangingName || isChangingNumber
                    ? Column(
                        children: [
                          MyButton(
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
            ),
          );
        }),
      ),
    );
  }
}
