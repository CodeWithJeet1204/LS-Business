import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/image_pick_dialog.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    specialNoteController.dispose();
    super.dispose();
  }

  // CHANGE BUSINESS IMAGE
  Future<void> changeImage(String previousUrl) async {
    XFile? im = await showImagePickDialog(context);
    String? businessPhotoUrl;
    if (im != null) {
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
            .child('VendorShops')
            .child(auth.currentUser!.uid);
        await ref
            .putFile(File(updatedUserImage['Image']!))
            .whenComplete(() async {
          await ref.getDownloadURL().then((value) {
            businessPhotoUrl = value;
          });
        });
        updatedUserImage = {
          'Image': businessPhotoUrl,
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
      if (mounted) {
        mySnackBar(context, 'Image not selected');
      }
    }
  }

  // SAVE
  Future<void> save(
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
        return mySnackBar(context, 'Enter $propertyName');
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
        if (mounted) {
          Navigator.of(context).popAndPushNamed('/businessDetails');
        }
      }
    } catch (e) {
      setState(() {
        isSaving = false;
        isChanging = false;
      });
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
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'Business Details',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.025,
        ),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;

            return StreamBuilder(
                stream: shopStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Something went wrong',
                        overflow: TextOverflow.ellipsis,
                      ),
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
                                      onTap: isSaving
                                          ? null
                                          : () async {
                                              await showImage(
                                                shopData['Image'] ??
                                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                              );
                                            },
                                      child: CircleAvatar(
                                        radius: width * 0.15,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          shopData['Image'] ??
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
                                          await changeImage(shopData['Image']);
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
                                    controller: nameController,
                                    maxLength: 32,
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
                                        padding: EdgeInsets.only(
                                          left: width * 0.055,
                                        ),
                                        child: SizedBox(
                                          width: width * 0.725,
                                          child: AutoSizeText(
                                            shopData['Name'] ?? 'N/A',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
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
                                              isChangingAddress = false;
                                              isChangingSpecialNote = false;
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
                                    controller: addressController,
                                    maxLength: 32,
                                    autofocus: true,
                                    onTapOutside: (event) =>
                                        FocusScope.of(context).unfocus(),
                                    decoration: InputDecoration(
                                      hintText: 'Change Address',
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
                                            shopData['Address'] ?? 'N/A',
                                            overflow: TextOverflow.ellipsis,
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
                                          icon: const Icon(FeatherIcons.edit),
                                          tooltip: 'Edit Addess',
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
                                    controller: specialNoteController,
                                    maxLength: 32,
                                    autofocus: true,
                                    onTapOutside: (event) =>
                                        FocusScope.of(context).unfocus(),
                                    decoration: InputDecoration(
                                      hintText: 'Change Description',
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
                                            shopData['Description'] ?? 'N/A',
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
                                              isChangingName = false;
                                              isChangingAddress = false;
                                              isChangingSpecialNote = true;
                                            });
                                          },
                                          icon: const Icon(FeatherIcons.edit),
                                          tooltip: 'Edit Description',
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
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: width * 0.055,
                              ),
                              child: SizedBox(
                                width: width * 0.875,
                                child: AutoSizeText(
                                  shopData['Type'] ?? 'N/A',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.055,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // GST
                          Container(
                            width: width,
                            height: width * 0.16,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: width * 0.055,
                              ),
                              child: SizedBox(
                                width: width * 0.875,
                                child: AutoSizeText(
                                  shopData['GSTNumber'] ?? 'N/A',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // INDUSTRY
                          Container(
                            width: width,
                            height: width * 0.16,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: width * 0.055,
                              ),
                              child: SizedBox(
                                width: width * 0.725,
                                child: Text(
                                  shopData['Industry'] ?? 'N/A',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.055,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // MEMBERSHIP
                          Container(
                            width: width,
                            height: width * 0.16,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: shopData['MembershipName'] == 'PREMIUM'
                                  ? const Color.fromRGBO(202, 226, 238, 1)
                                  : shopData['MembershipName'] == 'GOLD'
                                      ? const Color.fromRGBO(253, 243, 154, 1)
                                      : const Color.fromRGBO(167, 167, 167, 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: width * 0.05),
                              child: SizedBox(
                                width: width * 0.725,
                                child: AutoSizeText(
                                  shopData['MembershipName'] ?? 'N/A',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.055,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // MEMBERSHIP END DATETIME
                          Container(
                            width: width,
                            height: width * 0.2,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 130, 121),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: width * 0.055,
                              ),
                              child: SizedBox(
                                width: width * 0.875,
                                child: Text(
                                  'Membership Expiry Date - ${DateFormat('dd/M/yy').format((shopData['MembershipEndDateTime'] as Timestamp).toDate())}',
                                  style: TextStyle(
                                    fontSize: width * 0.055,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
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
                                              text: 'SAVE',
                                              onTap: () async {
                                                if (isChangingName) {
                                                  await save(
                                                    nameController,
                                                    'Name',
                                                    isChangingName,
                                                  );
                                                } else if (isChangingAddress) {
                                                  await save(
                                                    addressController,
                                                    'Address',
                                                    isChangingAddress,
                                                  );
                                                } else if (isChangingSpecialNote) {
                                                  await save(
                                                    specialNoteController,
                                                    'Description',
                                                    isChangingSpecialNote,
                                                  );
                                                }
                                              },
                                              isLoading: false,
                                              horizontalPadding: 0,
                                            ),
                                      const SizedBox(height: 12),
                                      MyButton(
                                        text: 'CANCEL',
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
