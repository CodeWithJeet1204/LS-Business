import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/page/register/membership_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/image_pick_dialog.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class AddStatusPage extends StatefulWidget {
  const AddStatusPage({
    super.key,
  });

  @override
  State<AddStatusPage> createState() => _AddStatusPageState();
}

class _AddStatusPageState extends State<AddStatusPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final statusKey = GlobalKey<FormState>();
  final captionController = TextEditingController();
  List<File> image = [];
  int currentImageIndex = 0;
  bool? isStatus;
  bool isPosting = false;
  bool isDialog = false;
  // int imagePostRemaining = 0;

  @override
  initState() {
    getStatus();
    super.initState();
  }

  // GET STATUS
  Future<void> getStatus() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final membershipName = vendorData['MembershipName'];

    final membershipSnap =
        await store.collection('Membership').doc(membershipName).get();

    final membershipData = membershipSnap.data()!;

    final status = membershipData['status'];

    setState(() {
      isStatus = status;
    });
  }

  // // GET NO OF POSTS
  // Future<void> getNoOfPosts() async {
  //   final productData = await store
  //       .collection('Business')
  //       .doc('Owners')
  //       .collection('Shops')
  //       .doc(auth.currentUser!.uid)
  //       .get();
  //   setState(() {
  //     imagePostRemaining = productData['noOfImagePosts'];
  //   });
  // }

  // ADD STATUS IMAGE
  Future<void> addStatusImages() async {
    final images = await showImagePickDialog(context, false);
    for (XFile im in images) {
      setState(() {
        image.add(File(im.path));
        currentImageIndex = image.length - 1;
      });
    }
  }

  // REMOVE STATUS IMAGE
  void removeStatusImages(int index) {
    setState(() {
      image.removeAt(index);
      if (currentImageIndex == (image.length)) {
        currentImageIndex = image.length - 1;
      }
    });
  }

  // POST
  Future<void> post() async {
    if (statusKey.currentState!.validate()) {
      setState(() {
        isPosting = true;
        isDialog = true;
      });

      try {
        List imageDownloadUrl = [];

        try {
          await Future.wait(
            image.map((img) async {
              Reference ref = FirebaseStorage.instance
                  .ref()
                  .child('Vendor/Status')
                  .child(const Uuid().v4());
              await ref.putFile(img);
              String downloadUrl = await ref.getDownloadURL();
              if (mounted) {
                setState(() {
                  imageDownloadUrl.add(downloadUrl);
                });
              }
            }),
          );
        } catch (e) {
          if (mounted) {
            mySnackBar(context, e.toString());
          }
        }

        final String statusId = const Uuid().v4();
        Map<String, dynamic> statusInfo = {
          'statusId': statusId,
          'statusText': captionController.text.toString().trim(),
          'statusImage': imageDownloadUrl,
          'statusVendorId': auth.currentUser!.uid,
          'statusViews': [],
          'statusDateTime': Timestamp.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch,
          ),
          // 'statusLikes': 0,
          // 'statusDeleteDateTime': Timestamp.fromMillisecondsSinceEpoch(
          //   DateTime.now()
          //       .add(
          //         Duration(
          //           hours: 23,
          //           minutes: 50,
          //         ),
          //       )
          //       .millisecondsSinceEpoch,
          // ),
        };

        // await store
        //     .collection('Business')
        //     .doc('Owners')
        //     .collection('Shops')
        //     .doc(auth.currentUser!.uid)
        //     .update({
        //   'noOfImagePosts': imagePostRemaining - 1,
        // });

        await store
            .collection('Business')
            .doc('Data')
            .collection('Status')
            .doc(statusId)
            .set(statusInfo);

        setState(() {
          isPosting = false;
          isDialog = false;
        });

        if (mounted) {
          mySnackBar(context, 'Posted');
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          isPosting = false;
          isDialog = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  // SHOW CHANGE MEMBERSHIP DIALOG
  Future<void> showChangeMembershipDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Membership'),
          content: const Text(
            'It will cancel this membership, and you have to get a new Membership by paying',
          ),
          actions: [
            MyTextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'NO',
              textColor: primaryDark2,
            ),
            MyTextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SelectMembershipPage(
                      hasAvailedLaunchOffer: true,
                    ),
                  ),
                );
              },
              text: 'YES',
              textColor: primaryDark2,
            ),
          ],
        );
      },
    );
  }

  // SHARE
  Future<void> shareImages() async {
    if (image.isEmpty) {
      return mySnackBar(context, 'Select an image');
    }

    List<String> imagePaths = image.map((file) => file.path).toList();

    for (String path in imagePaths) {
      if (!await File(path).exists()) {
        imagePaths.remove(path);
      }
    }

    await Share.shareXFiles(
      imagePaths.map((path) => XFile(path)).toList(),
      text: captionController.text.isNotEmpty
          ? captionController.text
          : 'This products are also available on Localsearch',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 0.5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add Status'),
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
          body: SafeArea(
            child: isStatus == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : !isStatus!
                    ? Center(
                        child: SizedBox(
                          height: 160,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Your current membership doesn\'t support Status',
                                textAlign: TextAlign.center,
                              ),
                              MyTextButton(
                                onPressed: () async {
                                  await showChangeMembershipDialog();
                                },
                                text: 'CHANGE MEMBERSHIP',
                                textColor: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;

                          return SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(width * 0.0225),
                              child: Column(
                                children: [
                                  // Text(
                                  //   'Remaining Image Post - $imagePostRemaining',
                                  //   maxLines: 2,
                                  //   overflow: TextOverflow.ellipsis,
                                  //   style: TextStyle(
                                  //     color: primaryDark,
                                  //     fontWeight: FontWeight.w500,
                                  //     fontSize: width * 0.05,
                                  //   ),
                                  // ),
                                  // SizedBox(height: 8),
                                  image.isEmpty
                                      ? SizedOverflowBox(
                                          size: Size(width, width),
                                          child: InkWell(
                                            onTap: () async {
                                              await addStatusImages();
                                            },
                                            customBorder:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                            child: Container(
                                              width: width,
                                              height: width,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 3,
                                                  color: primaryDark,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    FeatherIcons.upload,
                                                    size: width * 0.4,
                                                  ),
                                                  SizedBox(
                                                      height: width * 0.09),
                                                  Text(
                                                    'Select Image',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.09,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  Container(
                                                    height: width,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        12,
                                                      ),
                                                      border: Border.all(
                                                        color: primaryDark,
                                                        width: 3,
                                                      ),
                                                      image: DecorationImage(
                                                        image: FileImage(
                                                          image[
                                                              currentImageIndex],
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: width * 0.015,
                                                      right: width * 0.015,
                                                    ),
                                                    child:
                                                        IconButton.filledTonal(
                                                      onPressed: () {
                                                        removeStatusImages(
                                                          currentImageIndex,
                                                        );
                                                      },
                                                      icon: Icon(
                                                        FeatherIcons.x,
                                                        size: width * 0.1,
                                                      ),
                                                      tooltip: 'Remove Image',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Container(
                                                  width: width * 0.75,
                                                  height: width * 0.225,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: primaryDark,
                                                      width: 3,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12,
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.all(
                                                    width * 0.0125,
                                                  ),
                                                  // TODO: CHANGE MEDIAQUERY.SIZE.WIDTH TO MEDIAQUERY.SIZEOF(WIDTH)
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const ClampingScrollPhysics(),
                                                    itemCount: image.length,
                                                    itemBuilder:
                                                        ((context, index) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            currentImageIndex =
                                                                index;
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2),
                                                          child: Container(
                                                            height:
                                                                width * 0.18,
                                                            width: width * 0.18,
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                width: 0.3,
                                                                color:
                                                                    primaryDark,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    FileImage(
                                                                  image[index],
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ),
                                                SizedBox(width: width * 0.02),
                                                Container(
                                                  width: width * 0.175,
                                                  height: width * 0.175,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: primaryDark,
                                                      width: 3,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () async {
                                                      await addStatusImages();
                                                    },
                                                    icon: Icon(
                                                      FeatherIcons.plus,
                                                      size: width * 0.1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  const SizedBox(height: 8),
                                  Form(
                                    key: statusKey,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: width,
                                          child: TextFormField(
                                            autofocus: false,
                                            controller: captionController,
                                            minLines: 1,
                                            maxLines: 10,
                                            maxLength: 100,
                                            onTapOutside: (event) =>
                                                FocusScope.of(context)
                                                    .unfocus(),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                borderSide: BorderSide(
                                                  color: Colors.cyan.shade700,
                                                ),
                                              ),
                                              hintText: 'Caption',
                                            ),
                                            validator: (value) {
                                              if (value != null) {
                                                if (value.isNotEmpty) {
                                                  return null;
                                                } else {
                                                  return 'Pls enter Caption';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await shareImages();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade300,
                                                border: Border.all(
                                                  color: Colors.green,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding: EdgeInsets.all(
                                                width * 0.0225,
                                              ),
                                              margin: EdgeInsets.symmetric(
                                                horizontal: width * 0.0125,
                                              ),
                                              child: Text(
                                                'Share To Whatsapp',
                                                style: TextStyle(
                                                  color: Colors.green.shade900,
                                                  fontSize: width * 0.033,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        // DONE
                                        MyButton(
                                          text: 'DONE',
                                          onTap: () async {
                                            await post();
                                          },
                                          horizontalPadding: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
