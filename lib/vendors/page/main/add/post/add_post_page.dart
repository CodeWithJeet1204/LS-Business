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
import 'package:ls_business/widgets/text_form_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:uuid/uuid.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({
    super.key,
  });

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final postKey = GlobalKey<FormState>();
  final nameCaptionController = TextEditingController();
  final priceController = TextEditingController();
  int currentImageIndex = 0;
  int? remainingPost;
  List<File> image = [];
  bool isPosting = false;
  bool isDialog = false;
  // int imagePostRemaining = 0;

  // INIT STATE
  @override
  void initState() {
    getNoOfPost();
    super.initState();
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

  // ADD POST IMAGE
  Future<void> addPostImages() async {
    final images = await showImagePickDialog(context, false);
    for (XFile im in images) {
      setState(() {
        image.add(File(im.path));
        currentImageIndex = image.length - 1;
      });
    }
  }

  // REMOVE POST IMAGE
  void removePostImages(int index) {
    setState(() {
      image.removeAt(index);
      if (currentImageIndex == (image.length)) {
        currentImageIndex = image.length - 1;
      }
    });
  }

  // GET NO OF POST
  Future<void> getNoOfPost() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final noOfPost = vendorData['noOfPost'];

    print('noOfPost: $noOfPost');
    print('noOfPost: ${auth.currentUser!.uid}');

    if (noOfPost < 1000000000000) {
      final postSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Post')
          .where('vendorId', isEqualTo: auth.currentUser!.uid)
          .get();

      final currentPostLength = postSnap.docs.length;

      int difference = noOfPost - currentPostLength;

      setState(() {
        remainingPost = difference;
      });
    }
  }

  // POST
  Future<void> done() async {
    if (postKey.currentState!.validate()) {
      setState(() {
        isPosting = true;
        isDialog = true;
      });

      try {
        List imageDownloadUrl = [];

        for (File img in image) {
          try {
            Reference ref =
                storage.ref().child('Vendor/Post').child(const Uuid().v4());
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

        final postId = const Uuid().v4();

        await store
            .collection('Business')
            .doc('Data')
            .collection('Post')
            .doc(postId)
            .set({
          'postId': postId,
          'postText': nameCaptionController.text.trim(),
          'postPrice': priceController.text.isEmpty
              ? ''
              : double.parse(priceController.text.trim()),
          'postImage': imageDownloadUrl,
          'postVendorId': auth.currentUser!.uid,
          'postViews': [],
          'postDateTime': DateTime.now(),
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
        });

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
    final width = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 0.5,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              remainingPost != null && remainingPost! < 1
                  ? 'Post Limit Full'
                  : 'Add Post',
            ),
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
            child: Padding(
              padding: EdgeInsets.all(width * 0.0225),
              child: remainingPost != null && remainingPost! < 1
                  ? const Center(
                      child: Text(
                        'Your Post Limit has reached\nDelete older posts or renew your membership to increase limit',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;

                        return SingleChildScrollView(
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
                                          await addPostImages();
                                        },
                                        customBorder: RoundedRectangleBorder(
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
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: primaryDark,
                                                    width: 3,
                                                  ),
                                                  image: DecorationImage(
                                                    image: FileImage(
                                                      image[currentImageIndex],
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
                                                child: IconButton.filledTonal(
                                                  onPressed: () {
                                                    removePostImages(
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
                                              padding: EdgeInsets.all(
                                                  width * 0.0125),
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                physics:
                                                    const ClampingScrollPhysics(),
                                                itemCount: image.length,
                                                itemBuilder: ((context, index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        currentImageIndex =
                                                            index;
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        2,
                                                      ),
                                                      child: Container(
                                                        height: width * 0.18,
                                                        width: width * 0.18,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            width: 0.3,
                                                            color: primaryDark,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            4,
                                                          ),
                                                          image:
                                                              DecorationImage(
                                                            image: FileImage(
                                                              image[index],
                                                            ),
                                                            fit: BoxFit.cover,
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
                                                  await addPostImages();
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
                                child: SizedBox(
                                  width: width,
                                  child: MyTextFormField(
                                    controller: nameCaptionController,
                                    hintText: 'Name / Caption*',
                                    maxLines: 10,
                                    borderRadius: 12,
                                    horizontalPadding: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // PRICE
                              SizedBox(
                                width: width,
                                child: MyTextFormField(
                                  controller: priceController,
                                  hintText: 'Price',
                                  maxLines: 10,
                                  borderRadius: 12,
                                  horizontalPadding: 0,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // DONE
                              remainingPost != null && remainingPost! < 1
                                  ? Container()
                                  : MyButton(
                                      text: 'DONE',
                                      onTap: () async {
                                        await done();
                                      },
                                      horizontalPadding: 0,
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
