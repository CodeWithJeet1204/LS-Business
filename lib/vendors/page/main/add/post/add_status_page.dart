import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/image_pick_dialog.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:uuid/uuid.dart';

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
  final postKey = GlobalKey<FormState>();
  final postController = TextEditingController();
  List<File> image = [];
  int currentImageIndex = 0;
  bool isPosting = false;
  bool isDialog = false;
  // int imagePostRemaining = 0;

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
    if (postKey.currentState!.validate()) {
      setState(() {
        isPosting = true;
        isDialog = true;
      });

      try {
        List imageDownloadUrl = [];

        for (File img in image) {
          try {
            Reference ref = FirebaseStorage.instance
                .ref()
                .child('Vendor/Posts')
                .child(const Uuid().v4());
            await ref.putFile(img).whenComplete(() async {
              await ref.getDownloadURL().then((value) {
                setState(() {
                  imageDownloadUrl.add(value);
                });
              });
            });
          } catch (e) {
            if (mounted) {
              mySnackBar(context, e.toString());
            }
          }
        }

        for (String imgUrl in imageDownloadUrl) {
          final String postId = const Uuid().v4();
          Map<String, dynamic> postInfo = {
            'postId': postId,
            'postText': postController.text,
            'postImage': imgUrl,
            'postVendorId': auth.currentUser!.uid,
            'postViews': [],
            'postDateTime': Timestamp.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch,
            ),
            // 'postLikes': 0,
            // 'postDeleteDateTime': Timestamp.fromMillisecondsSinceEpoch(
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
              .collection('Posts')
              .doc(postId)
              .set(postInfo);
        }

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
          ),
          body: SafeArea(
            child: LayoutBuilder(
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
                                  customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
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
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FeatherIcons.upload,
                                          size: width * 0.4,
                                        ),
                                        SizedBox(height: width * 0.09),
                                        Text(
                                          'Select Image',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.09,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          height: width,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: primaryDark,
                                              width: 3,
                                            ),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                image[currentImageIndex],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: width * 0.015,
                                            right: width * 0.015,
                                          ),
                                          child: IconButton.filledTonal(
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
                                              BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.all(width * 0.0125),
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          itemCount: image.length,
                                          itemBuilder: ((context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  currentImageIndex = index;
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: Container(
                                                  height: width * 0.18,
                                                  width: width * 0.18,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 0.3,
                                                      color: primaryDark,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: FileImage(
                                                        image[index],
                                                      ),
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
                                              BorderRadius.circular(12),
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
                          key: postKey,
                          child: Column(
                            children: [
                              SizedBox(
                                width: width,
                                child: TextFormField(
                                  autofocus: false,
                                  controller: postController,
                                  minLines: 1,
                                  maxLines: 10,
                                  maxLength: 100,
                                  onTapOutside: (event) =>
                                      FocusScope.of(context).unfocus(),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
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
                                        return 'Pls enter something';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 8),

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
