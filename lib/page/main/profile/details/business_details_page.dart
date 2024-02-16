import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/image_pick_dialog.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BusinessDetailsPage extends StatefulWidget {
  const BusinessDetailsPage({super.key});

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final specialNoteController = TextEditingController();
  bool isChangingName = false;
  bool isChangingAddress = false;
  bool isChangingSpecialNote = false;
  bool isChangingImage = false;
  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    specialNoteController.dispose();
    super.dispose();
  }

  // CHANGE BUSINESS IMAGE
  void changeImage(String previousUrl) async {
    XFile? im = await showImagePickDialog(context);
    String? businessPhotoUrl;
    if (im != null) {
      try {
        setState(() {
          isChangingImage = true;
        });

        await storage.refFromURL(previousUrl).delete();

        Map<String, dynamic> updatedUserImage = {
          "Image": im.path,
        };

        Reference ref = FirebaseStorage.instance
            .ref()
            .child('Profile/Shops')
            .child(auth.currentUser!.uid);
        await ref
            .putFile(File(updatedUserImage['Image']!))
            .whenComplete(() async {
          await ref.getDownloadURL().then((value) {
            businessPhotoUrl = value;
          });
        });
        updatedUserImage = {
          "Image": businessPhotoUrl,
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

  // SAVE
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
          isChanging = false;
        });
        return mySnackBar(context, "Enter $propertyName");
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
        if (context.mounted) {
          Navigator.of(context).popAndPushNamed('/businessDetails');
        }
      }
    } catch (e) {
      setState(() {
        isSaving = false;
        isChanging = false;
      });
      if (context.mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // SHOW IMAGE
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

            return StreamBuilder(
                stream: shopStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something Went Wrong'),
                    );
                  }

                  if (snapshot.hasData) {
                    final shopData = snapshot.data!;

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
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
                                        onPressed: () {
                                          changeImage(shopData['Image']);
                                        },
                                        icon: Icon(
                                          Icons.camera_alt_outlined,
                                          size: width * 0.1,
                                        ),
                                        tooltip: "Change Photo",
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 32),

                          // NAME
                          Container(
                            width: width,
                            height:
                                isChangingName ? width * 0.2775 : width * 0.175,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isChangingName
                                ? TextField(
                                    maxLength: 32,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: width * 0.055,
                                        ),
                                        child: SizedBox(
                                          width: width * 0.725,
                                          child: AutoSizeText(
                                            shopData['Name'],
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: width * 0.06,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: width * 0.03,
                                        ),
                                        child: IconButton(
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
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 14),

                          // ADDRESS
                          Container(
                            width: width,
                            height: isChangingAddress
                                ? width * 0.2775
                                : width * 0.175,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: width * 0.05),
                                        child: SizedBox(
                                          width: width * 0.725,
                                          child: AutoSizeText(
                                            shopData['Address'],
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: width * 0.055,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: width * 0.03,
                                        ),
                                        child: IconButton(
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
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 14),

                          // SPECIAL NOTE
                          Container(
                            width: width,
                            height: isChangingSpecialNote
                                ? width * 0.2775
                                : width * 0.175,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: width * 0.055,
                                        ),
                                        child: SizedBox(
                                          width: width * 0.725,
                                          child: AutoSizeText(
                                            shopData['Special Note'],
                                            style: TextStyle(
                                              fontSize: width * 0.055,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: width * 0.03,
                                        ),
                                        child: IconButton(
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
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 14),

                          // TYPE
                          Container(
                            width: width,
                            height: width * 0.16,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: width * 0.055,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.875,
                                    child: AutoSizeText(
                                      shopData['Type'] ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: width * 0.055,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // GST
                          Container(
                            width: width,
                            height: width * 0.16,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: width * 0.055,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.875,
                                    child: AutoSizeText(
                                      shopData['GSTNumber'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // INDUSTRY
                          Container(
                            width: width,
                            height: width * 0.16,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: width * 0.055,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.725,
                                    child: Text(
                                      shopData['Industry'],
                                      style: TextStyle(
                                        fontSize: width * 0.055,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // MEMBERSHIP
                          Container(
                            width: width,
                            height: width * 0.16,
                            decoration: BoxDecoration(
                              color: shopData['MembershipName'] == "PREMIUM"
                                  ? const Color.fromRGBO(202, 226, 238, 1)
                                  : shopData['MembershipName'] == "GOLD"
                                      ? const Color.fromRGBO(253, 243, 154, 1)
                                      : const Color.fromRGBO(167, 167, 167, 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: width * 0.05),
                                  child: SizedBox(
                                    width: width * 0.725,
                                    child: AutoSizeText(
                                      shopData['MembershipName'] ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: width * 0.055,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // SAVE & CANCEL BUTTON
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: isChangingName ||
                                    isChangingAddress ||
                                    isChangingSpecialNote
                                ? Column(
                                    children: [
                                      isSaving
                                          ? Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 0,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              alignment: Alignment.center,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: buttonColor,
                                              ),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
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
                                      const SizedBox(height: 12),
                                      MyButton(
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
                                    ],
                                  )
                                : Container(),
                          ),
                        ],
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
        ),
      ),
    );
  }
}
