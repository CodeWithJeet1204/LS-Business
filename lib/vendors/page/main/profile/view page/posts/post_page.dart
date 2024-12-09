import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/vendors/page/main/profile/data/all_posts_page.dart';
import 'package:ls_business/vendors/page/main/profile/view%20page/product/image_view.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/info_color_box.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/image_pick_dialog.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ls_business/widgets/video_tutorial.dart';
import 'package:uuid/uuid.dart';

class PostPage extends StatefulWidget {
  const PostPage({
    super.key,
    required this.postId,
    required this.postText,
    required this.imageUrl,
  });

  final String postId;
  final String postText;
  final List? imageUrl;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final postTextKey = GlobalKey<FormState>();
  final textChangeController = TextEditingController();
  final searchController = TextEditingController();
  int _currentIndex = 0;
  bool isImageChanging = false;
  bool isChangingName = false;
  bool isChangingImage = false;
  bool isGridView = true;
  bool isDiscount = false;
  bool isDialog = false;

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ADD IMAGES
  Future<void> addPostImages(List images) async {
    final List<XFile> imageList = await showImagePickDialog(context, false);
    try {
      setState(() {
        isImageChanging = true;
        isDialog = true;
      });
      await Future.wait(
        imageList.map((im) async {
          final postImageId = const Uuid().v4();
          Reference ref = storage.ref().child('Vendor/Post').child(postImageId);

          await ref.putFile(File(im.path));
          final downloadUrl = await ref.getDownloadURL();

          if (!images.contains(downloadUrl)) {
            images.add(downloadUrl);
          }
        }),
      );

      await store
          .collection('Business')
          .doc('Data')
          .collection('Post')
          .doc(widget.postId)
          .update({
        'postImage': images,
      });

      setState(() {
        isImageChanging = false;
        isDialog = false;
      });

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostPage(
              postId: widget.postId,
              postText: widget.postText.toString().trim().isEmpty
                  ? 'No Post Name'
                  : widget.postText,
              imageUrl: widget.imageUrl,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isImageChanging = false;
        isDialog = false;
      });
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // CHANGE IMAGE
  // Future<void> changePostImage(String e, int index, List images) async {
  //   final XFile im = await showImagePickDialog(context);
  //   if (im != null) {
  //     try {
  //       setState(() {
  //         isImageChanging = true;
  //       });
  //       Reference ref = FirebaseStorage.instance.refFromURL(images[index]);
  //       await images.removeAt(index);
  //       await ref.putFile(File(im.path));
  //       setState(() {
  //         isImageChanging = false;
  //       });
  //     } catch (e) {
  //       setState(() {
  //         isImageChanging = false;
  //       });
  //       if (mounted) {
  //         mySnackBar(context, e.toString());
  //       }
  //     }
  //   }
  // }

  // REMOVE IMAGES
  Future<void> removePostImages(int index, List images) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirm REMOVE',
          ),
          content: const Text(
            'Are you sure you want to remove this image?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await storage.refFromURL(images[index]).delete();
                setState(() {
                  images.removeAt(index);
                });
                await store
                    .collection('Business')
                    .doc('Data')
                    .collection('Post')
                    .doc(widget.postId)
                    .update({
                  'postImage': images,
                });
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'YES',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // CHANGE POST TEXT
  Future<void> changePostText(var newText, bool isName) async {
    if (postTextKey.currentState!.validate()) {
      try {
        setState(() {
          isChangingName = true;
          isDialog = true;
        });
        if (isName) {
          await store
              .collection('Business')
              .doc('Data')
              .collection('Post')
              .doc(widget.postId)
              .update({
            'postText': newText,
          });
        } else {
          await store
              .collection('Business')
              .doc('Data')
              .collection('Post')
              .doc(widget.postId)
              .update({
            'postPrice': newText,
          });
        }
        setState(() {
          isChangingName = false;
          isDialog = false;
        });
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  // CHANGE TEXT
  Future<void> changeText(bool isName) async {
    bool isInitialized = false;
    await showDialog(
      context: context,
      builder: (context) {
        final propertyStream = store
            .collection('Business')
            .doc('Data')
            .collection('Post')
            .doc(widget.postId)
            .snapshots();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: SizedBox(
            height: 180,
            child: StreamBuilder(
              stream: propertyStream,
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
                  final postData = snapshot.data!;

                  if (!isInitialized) {
                    textChangeController.text =
                        postData[isName ? 'postText' : 'postPrice'].toString();
                    isInitialized = true;
                  }

                  return Form(
                    key: postTextKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextFormField(
                            controller: textChangeController,
                            autofocus: true,
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            keyboardType: isName
                                ? TextInputType.name
                                : TextInputType.number,
                            decoration: InputDecoration(
                              hintText: isName ? 'Name / Caption' : 'Price',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              } else {
                                return 'Enter Post ${isName ? 'Name' : 'Price'}';
                              }
                            },
                          ),
                          MyButton(
                            text: 'SAVE',
                            onTap: () async {
                              await changePostText(
                                  textChangeController.text, isName);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const Center(
                  child: LoadingIndicator(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // CONFIRM DELETE
  Future<void> confirmDelete() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirm DELETE',
          ),
          content: const Text(
            'Are you sure you want to delete this Post?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await delete();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'YES',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // DELETE POST
  Future<void> delete() async {
    setState(() {
      isDialog = true;
    });
    try {
      if (widget.imageUrl != null) {
        await Future.wait(
          widget.imageUrl!.map((image) async {
            await storage.refFromURL(image).delete();
          }),
        );
      }
      await store
          .collection('Business')
          .doc('Data')
          .collection('Post')
          .doc(widget.postId)
          .delete();

      setState(() {
        isDialog = false;
      });
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const allPostPage(),
          ),
        );
        mySnackBar(context, 'Post Deleted');
      }
    } catch (e) {
      setState(() {
        isDialog = false;
      });
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // POST STREAM
    final Stream<DocumentSnapshot<Map<String, dynamic>>> postStream = store
        .collection('Business')
        .doc('Data')
        .collection('Post')
        .doc(widget.postId)
        .snapshots();

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        progressIndicator: LoadingIndicator(),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
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
                IconButton(
                  onPressed: () async {
                    await confirmDelete();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const MainPage(),
                        ),
                        (route) => false,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const allPostPage(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    FeatherIcons.trash,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            body: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                child: LayoutBuilder(builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  return StreamBuilder(
                    stream: postStream,
                    builder: ((context, snapshot) {
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
                        final postData = snapshot.data!;

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.0225,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              postData['postImage'] != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CarouselSlider(
                                          items: (postData['postImage'] as List)
                                              .map(
                                                (e) => Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Stack(
                                                      alignment:
                                                          Alignment.topCenter,
                                                      children: [
                                                        Container(
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  primaryDark2,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              12,
                                                            ),
                                                          ),
                                                          child: isImageChanging
                                                              ? const LoadingIndicator()
                                                              : GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ImageView(
                                                                          imagesUrl:
                                                                              postData['postImage'],
                                                                          shortsThumbnail:
                                                                              '',
                                                                          shortsURL:
                                                                              '',
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                      10,
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              NetworkImage(
                                                                            e.trim(),
                                                                          ),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                        ),
                                                        isImageChanging
                                                            ? Container()
                                                            : Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  // e == shortsThumbnail
                                                                  //     ? SizedBox(
                                                                  //         width: 1,
                                                                  //         height: 1,
                                                                  //       )
                                                                  //     : Padding(
                                                                  //         padding:
                                                                  //             EdgeInsets.only(
                                                                  //           left: width *
                                                                  //               0.0125,
                                                                  //           top: width *
                                                                  //               0.0125,
                                                                  //         ),
                                                                  //         child: IconButton
                                                                  //             .filledTonal(
                                                                  //           onPressed:
                                                                  //               () async {
                                                                  //             await changePostImage(
                                                                  //               e,
                                                                  //               postData['postImage']
                                                                  //                   .indexOf(
                                                                  //                       e),
                                                                  //               postData['postImage'],
                                                                  //             );
                                                                  //           },
                                                                  //           icon: Icon(
                                                                  //             FeatherIcons
                                                                  //                 .camera,
                                                                  //             size:
                                                                  //                 width * 0.1,
                                                                  //           ),
                                                                  //           tooltip:
                                                                  //               'Change Image',
                                                                  //         ),
                                                                  //       ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      right: width *
                                                                          0.0125,
                                                                      top: width *
                                                                          0.0125,
                                                                    ),
                                                                    child: IconButton
                                                                        .filledTonal(
                                                                      onPressed: postData['postImage'].length <=
                                                                              2
                                                                          ? () {
                                                                              mySnackBar(
                                                                                context,
                                                                                'Minimum 2 images are required',
                                                                              );
                                                                            }
                                                                          : () async {
                                                                              await removePostImages(
                                                                                postData['postImage'].indexOf(
                                                                                  e,
                                                                                ),
                                                                                postData['postImage'],
                                                                              );
                                                                            },
                                                                      icon:
                                                                          Icon(
                                                                        FeatherIcons
                                                                            .x,
                                                                        size: width *
                                                                            0.1,
                                                                      ),
                                                                      tooltip:
                                                                          'Remove Image',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .toList() as List<Widget>,
                                          options: CarouselOptions(
                                            enableInfiniteScroll:
                                                postData['postImage'].length > 1
                                                    ? true
                                                    : false,
                                            aspectRatio: 1.2,
                                            enlargeCenterPage: true,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _currentIndex = index;
                                              });
                                            },
                                          ),
                                        ),

                                        // DOTS
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(),
                                            postData['postImage'].length > 1
                                                ? Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: width * 0.033,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: (postData[
                                                                  'postImage']
                                                              as List<dynamic>)
                                                          .map((e) {
                                                        int index = postData[
                                                                'postImage']
                                                            .indexOf(e);

                                                        return Container(
                                                          width:
                                                              _currentIndex ==
                                                                      index
                                                                  ? 12
                                                                  : 8,
                                                          height:
                                                              _currentIndex ==
                                                                      index
                                                                  ? 12
                                                                  : 8,
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color:
                                                                _currentIndex ==
                                                                        index
                                                                    ? primaryDark
                                                                    : primary2,
                                                          ),
                                                        );
                                                      }).toList() as List<
                                                          Widget>,
                                                    ),
                                                  )
                                                : const SizedBox(height: 40),
                                            GestureDetector(
                                              onTap: () async {
                                                await addPostImages(
                                                  postData['postImage'],
                                                );
                                              },
                                              child: Container(
                                                height: width * 0.1,
                                                decoration: BoxDecoration(
                                                  color: primary,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Add Image',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Icon(FeatherIcons.plus),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: MyTextButton(
                                        onTap: () async {
                                          await addPostImages(
                                            postData['postImage'],
                                          );
                                        },
                                        text: 'Add Image',
                                        textColor: primaryDark2,
                                      ),
                                    ),

                              // NAME
                              Container(
                                width: width,
                                padding: EdgeInsets.symmetric(
                                  vertical: width * 0.025,
                                  horizontal: width * 0.0,
                                ),
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: width * 0.8,
                                      child: Text(
                                        postData['postText']
                                                .toString()
                                                .trim()
                                                .isEmpty
                                            ? 'No Post Name'
                                            : postData['postText']
                                                .toString()
                                                .trim(),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: primaryDark,
                                          fontSize: width * 0.05,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await changeText(true);
                                      },
                                      icon: Icon(
                                        FeatherIcons.edit,
                                        size: width * 0.0725,
                                        color: primaryDark,
                                      ),
                                      tooltip: 'Change Name',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),

                              // PRICE
                              Container(
                                width: width,
                                padding: EdgeInsets.symmetric(
                                  vertical: width * 0.025,
                                  horizontal: width * 0.0,
                                ),
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: width * 0.8,
                                      child: Text(
                                        postData['postPrice'] == ''
                                            ? 'Price: N/A'
                                            : 'Rs. ${postData['postPrice'].toString().trim()}',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: primaryDark,
                                          fontSize: width * 0.05,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await changeText(false);
                                      },
                                      icon: Icon(
                                        FeatherIcons.edit,
                                        size: width * 0.0725,
                                        color: primaryDark,
                                      ),
                                      tooltip: 'Change Price',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InfoColorBox(
                                    width: width,
                                    property:
                                        postData['postViewsTimestamp'].length,
                                    color: Colors.green.shade200,
                                    text: 'VIEWS',
                                    isHalf: true,
                                  ),
                                  InfoColorBox(
                                    width: width,
                                    property: postData['postWishlistTimestamp']
                                        .length,
                                    color: Colors.pink.shade200,
                                    text: 'WISHLIST',
                                    isHalf: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }

                      return const Center(
                        child: LoadingIndicator(),
                      );
                    }),
                  );
                }),
              );
            })),
      ),
    );
  }
}
