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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String name = "";
  String address = "";
  String industry = "";
  String type = "";
  String membership = "";
  String photoUrl = "";
  Map<String, dynamic> businessData = {};
  bool isChangingName = false;
  bool isChangingAddress = false;
  bool isSaving = false;
  bool isDataLoaded = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> businessSnap =
          await FirebaseFirestore.instance
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();
      businessData = businessSnap.data()!;
      setState(() {
        name = businessData["Name"];
        address = businessData["Address"];
        industry = businessData["Industry"];
        type = businessData["Type"];
        membership = businessData["MembershipName"];
        photoUrl = businessData["Image"];
      });

      setState(() {});
    } catch (e) {
      mySnackBar(context, e.toString());
    }
  }

  void changeImage() async {
    Uint8List? im;
    Uint8List? image = await pickImage(ImageSource.camera);
    im = image;
    if (im != null) {
      print("AHHAHAHHAHA");
      Map<String, dynamic> updatedUserImage = {
        "Image": im,
      };
      print("Image updates in Map");
      String userPhotoUrl = await StorageMethods().uploadImageToStorage(
        'Profile/Shops',
        updatedUserImage["Image"]!,
        false,
      );
      print("Image updates in Storage");
      updatedUserImage = {
        "Image": userPhotoUrl,
      };
      print("Image updates in URL");
      await FirebaseFirestore.instance
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(updatedUserImage);
      print("Image updates in Firestore");
      Navigator.of(context).popAndPushNamed('/businessDetails');
    } else {
      mySnackBar(context, "Image not selected");
    }
  }

  void save() async {
    try {
      setState(() {
        isSaving = false;
      });
      if (isChangingName && !isChangingAddress) {
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
              .collection('Shops')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(updatedUserName);
        }
        setState(() {
          isSaving = false;
          isChangingName = false;
        });
        Navigator.of(context).popAndPushNamed('/businessDetails');

        return;
      } else if (isChangingAddress && !isChangingName) {
        if (addressController.text.length < 1) {
          mySnackBar(context, "Address should be atleast 1 characters long");
          return;
        } else {
          Map<String, dynamic> updatedUserAddress = {
            "Address": addressController.text.toString(),
          };
          await FirebaseFirestore.instance
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(updatedUserAddress);
        }
        setState(() {
          isSaving = false;
          isChangingName = false;
        });
        Navigator.of(context).popAndPushNamed('/businessDetails');
        return;
      } else if (isChangingAddress && isChangingName) {
        if (addressController.text.length < 1) {
          mySnackBar(context, "Address should be atleast 1 characters long");
          return;
        } else if (nameController.text.length < 1) {
          mySnackBar(context, "Name should be atleast 1 characters long");
        } else {
          Map<String, dynamic> updatedUserAddress = {
            "Address": addressController.text.toString(),
          };
          await FirebaseFirestore.instance
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(updatedUserAddress);
        }
        Map<String, dynamic> updatedUserName = {
          "Name": nameController.text.toString(),
        };
        await FirebaseFirestore.instance
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update(updatedUserName);

        setState(() {
          isSaving = false;
          isChangingName = false;
          isChangingAddress = false;
        });
        Navigator.of(context).popAndPushNamed('/businessDetails');
        return;
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
        title: Text("Business Details"),
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
                  child: isChangingAddress
                      ? TextField(
                          autofocus: true,
                          controller: addressController,
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
                              address,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Expanded(child: Container()),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isChangingAddress = true;
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
                        industry,
                        style: TextStyle(
                          fontSize: industry.length > 22 ? 16 : 18,
                        ),
                      ),
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
                        type,
                        style: TextStyle(
                          fontSize: industry.length > 22 ? 16 : 18,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),
                Container(
                  width: width,
                  height: height * 0.075,
                  decoration: BoxDecoration(
                    color: membership == "PREMIUM"
                        ? const Color.fromARGB(255, 202, 226, 238)
                        : membership == "GOLD"
                            ? const Color.fromARGB(255, 253, 243, 154)
                            : white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: width * 0.05),
                      Text(
                        membership,
                        style: TextStyle(
                          fontSize: industry.length > 22 ? 16 : 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.05),
                isChangingName || isChangingAddress
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
                                isChangingAddress = false;
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
