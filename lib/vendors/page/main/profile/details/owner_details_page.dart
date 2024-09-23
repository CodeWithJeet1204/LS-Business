import 'dart:io';
import 'package:Localsearch/widgets/show_loading_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/my_button.dart';
import 'package:Localsearch/widgets/image_pick_dialog.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class OwnerDetailsPage extends StatefulWidget {
  const OwnerDetailsPage({super.key});

  @override
  State<OwnerDetailsPage> createState() => _OwnerDetailsPageState();
}

class _OwnerDetailsPageState extends State<OwnerDetailsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  bool isChangingName = false;
  bool isChangingNumber = false;
  bool isChangingImage = false;
  bool isSaving = false;
  bool isDataLoaded = false;
  bool allowCall = true;
  bool allowChat = true;

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    super.dispose();
  }

  // CHANGE IMAGE
  Future<void> changeImage(String previousUrl) async {
    final images = await showImagePickDialog(context, true);
    String? userPhotoUrl;
    if (images.isNotEmpty) {
      final im = images[0];
      try {
        setState(() {
          isChangingImage = true;
        });
        await storage.refFromURL(previousUrl).delete();

        Map<String, dynamic> updatedUserImage = {
          'Image': im.path,
        };
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('Vendor/Owners')
            .child(auth.currentUser!.uid);
        await ref
            .putFile(File(updatedUserImage['Image']!))
            .whenComplete(() async {
          await ref.getDownloadURL().then((value) {
            userPhotoUrl = value;
          });
        });
        updatedUserImage = {
          'Image': userPhotoUrl,
        };
        await store
            .collection('Business')
            .doc('Owners')
            .collection('Users')
            .doc(auth.currentUser!.uid)
            .update(updatedUserImage);
        setState(() {
          isChangingImage = false;
        });
      } catch (e) {
        setState(() {
          isChangingImage = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      if (mounted) {
        mySnackBar(context, 'Image not selected');
      }
    }
  }

  // SAVE
  Future<void> save() async {
    try {
      setState(() {
        isSaving = true;
      });
      if (isChangingName && !isChangingNumber) {
        if (nameController.text.isEmpty) {
          mySnackBar(context, 'Name should be atleast 1 characters long');
          setState(() {
            isSaving = false;
          });
          return;
        } else {
          Map<String, dynamic> updatedUserName = {
            'Name': nameController.text.toString(),
          };
          await store
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(auth.currentUser!.uid)
              .update(updatedUserName);
        }
        setState(() {
          isSaving = false;
          isChangingName = false;
          isChangingNumber = false;
        });
      } else if (!isChangingName && isChangingNumber) {
        if (numberController.text.length != 10) {
          mySnackBar(context, 'Number should be 10 characters long');
          setState(() {
            isSaving = false;
          });
          return;
        } else {
          Map<String, dynamic> updatedUserNumber = {
            'Phone Number': numberController.text.toString(),
          };
          await store
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(auth.currentUser!.uid)
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
            'Name should be atleast 1 characters long',
          );
        }
        if (numberController.text.length != 10) {
          setState(() {
            isSaving = false;
          });
          return mySnackBar(context, 'Number should be 10 characters long');
        } else {
          // NAME
          Map<String, dynamic> updatedUserName = {
            'Name': nameController.text.toString(),
          };
          await store
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(auth.currentUser!.uid)
              .update(updatedUserName);

          // NUMBER
          Map<String, dynamic> updatedUserNumber = {
            'Phone Number': numberController.text.toString(),
          };
          await store
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(auth.currentUser!.uid)
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
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // SHOW IMAGE
  Future<void> showImage(String imageUrl) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: ((context) {
        return Dialog(
          elevation: 20,
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
            ),
          ),
        );
      }),
    );
  }

  // TOGGLE ALLOW CALL
  Future<void> toggleAllowCall() async {
    setState(() {
      allowCall = !allowCall;
    });

    await store
        .collection('Business')
        .doc('Owners')
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .update({
      'allowCalls': allowCall,
    });
  }

  // TOGGLE ALLOW CHAT
  Future<void> toggleAllowChat() async {
    setState(() {
      allowChat = !allowChat;
    });

    await store
        .collection('Business')
        .doc('Owners')
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .update({
      'allowChats': allowChat,
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final userStream = store
        .collection('Business')
        .doc('Owners')
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Owner Details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      bottomSheet: isChangingName || isChangingNumber
          ? SizedBox(
              width: width,
              height: 80,
              child: isSaving
                  ? Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: buttonColor,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: white,
                        ),
                      ),
                    )
                  : MyButton(
                      text: 'SAVE',
                      onTap: () async {
                        await showLoadingDialog(
                          context,
                          () async {
                            await save();
                          },
                        );
                      },
                      horizontalPadding: 0,
                    ),
            )
          : Container(
              width: 0,
              height: 0,
            ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;

            return StreamBuilder(
                stream: userStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Something went wrong',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }

                  if (snapshot.hasData) {
                    final userData = snapshot.data!;

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: width * 0.1111125),
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
                                      onTap: () async {
                                        await showImage(
                                          userData['Image'] ??
                                              'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: width * 0.15,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          userData['Image'] ??
                                              'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                        ),
                                        backgroundColor: primary2,
                                      ),
                                    ),
                                    Positioned(
                                      right: -(width * 0.0015),
                                      bottom: -(width * 0.0015),
                                      child: IconButton.filledTonal(
                                        onPressed: () async {
                                          await changeImage(userData['Image']);
                                        },
                                        icon: Icon(
                                          FeatherIcons.camera,
                                          size: width * 0.1,
                                        ),
                                        tooltip: 'Change Photo',
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 14),

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
                                    controller: nameController,
                                    autofocus: true,
                                    onTapOutside: (event) =>
                                        FocusScope.of(context).unfocus(),
                                    decoration: InputDecoration(
                                      hintText: 'Change Name',
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
                                            userData['Name'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: width * 0.06,
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
                                              isChangingName = true;
                                            });
                                          },
                                          icon: const Icon(FeatherIcons.edit),
                                          tooltip: 'Edit Name',
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 14),

                          // PHONE NUMBER
                          Container(
                            width: width,
                            height: isChangingNumber
                                ? width * 0.2775
                                : width * 0.175,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isChangingNumber
                                ? TextField(
                                    controller: numberController,
                                    autofocus: true,
                                    onTapOutside: (event) =>
                                        FocusScope.of(context).unfocus(),
                                    decoration: InputDecoration(
                                      hintText: 'Change Number',
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
                                            userData['Phone Number'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                                              isChangingNumber = true;
                                            });
                                          },
                                          icon: const Icon(FeatherIcons.edit),
                                          tooltip: 'Edit Phone Number',
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 14),

                          // EMAIL ADDRESS
                          Container(
                            width: width,
                            height: width * 0.16,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: width * 0.055,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.725,
                                    child: AutoSizeText(
                                      userData['Email'] == ''
                                          ? auth.currentUser!.email
                                          : userData['Email'] ?? 'N/A',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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

                          // ALLOW CALLS
                          InkWell(
                            onTap: () async {
                              await toggleAllowCall();
                            },
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(width * 0.0125),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: width * 0.025),
                                    child: Text(
                                      'Allow Calls from Users',
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontSize: width * 0.04,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: allowCall,
                                    onChanged: (value) async {
                                      await toggleAllowCall();
                                    },
                                    activeColor: primary2,
                                    activeTrackColor: primaryDark,
                                    inactiveThumbColor: primaryDark,
                                    inactiveTrackColor: primary2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ALLOW CHATS
                          InkWell(
                            onTap: () async {
                              await toggleAllowChat();
                            },
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(width * 0.0125),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: width * 0.025),
                                    child: SizedBox(
                                      width: width * 0.75,
                                      child: Text(
                                        'Allow Chats from Users on Whatsapp',
                                        style: TextStyle(
                                          color: primaryDark,
                                          fontSize: width * 0.04,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: allowChat,
                                    onChanged: (value) async {
                                      await toggleAllowChat();
                                    },
                                    activeColor: primary2,
                                    activeTrackColor: primaryDark,
                                    inactiveThumbColor: primaryDark,
                                    inactiveTrackColor: primary2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isChangingName || isChangingNumber
                              ? const SizedBox(height: 18)
                              : Container(),
                        ],
                      ),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
          }),
        ),
      ),
    );
  }
}
