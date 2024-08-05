import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/button.dart';
import 'package:Localsearch/widgets/image_pick_dialog.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:uuid/uuid.dart';

class AddImagePostPage extends StatefulWidget {
  const AddImagePostPage({
    super.key,
    required this.imagePostRemaining,
    required this.selectedImage,
  });

  final int imagePostRemaining;
  final File selectedImage;

  @override
  State<AddImagePostPage> createState() => _AddImagePostPageState();
}

class _AddImagePostPageState extends State<AddImagePostPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final postKey = GlobalKey<FormState>();
  final postController = TextEditingController();
  List<File> _image = [];
  int currentImageIndex = 0;
  bool isFit = false;
  bool isPosting = false;

  // INIT STATE
  @override
  void initState() {
    setState(() {
      _image.add(widget.selectedImage);
    });
    super.initState();
  }

  // ADD PRODUCT IMAGE
  Future<void> addProductImages() async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      setState(() {
        _image.add(File(im.path));
        currentImageIndex = _image.length - 1;
      });
    } else {
      if (mounted) {
        mySnackBar(context, 'Select an Image');
      }
    }
  }

  // REMOVE PRODUCT IMAGE
  void removeProductImages(int index) {
    setState(() {
      _image.removeAt(index);
    });
  }

  // POST
  Future<void> post() async {
    if (postKey.currentState!.validate()) {
      setState(() {
        isPosting = true;
      });

      try {
        final String postId = const Uuid().v4();
        List imageDownloadUrl = [];

        for (File img in _image) {
          try {
            Reference ref = FirebaseStorage.instance
                .ref()
                .child('Data/Posts')
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

        Map<String, dynamic> postInfo = {
          'postProductId': null,
          'postProductName': null,
          'postProductPrice': null,
          'postCategoryName': null,
          'postProductDescription': null,
          'postProductBrand': null,
          'postImages': imageDownloadUrl,
          'post': postController.text,
          'postId': postId,
          'postVendorId': auth.currentUser!.uid,
          'postViews': 0,
          'postLikes': 0,
          'postComments': {},
          'postDateTime': Timestamp.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch,
          ),
          'isTextPost': false,
          'isLinked': false,
        };

        await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid)
            .update({
          'noOfImagePosts': widget.imagePostRemaining - 1,
        });

        await store
            .collection('Business')
            .doc('Data')
            .collection('Posts')
            .doc(postId)
            .set(postInfo);

        setState(() {
          isPosting = false;
        });

        if (mounted) {
          mySnackBar(context, 'Posted');
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          isPosting = false;
        });
        mySnackBar(context, e.toString());
      }
    }
  }

  // CHANGE FIT
  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Image Post'),
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
                    Center(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          GestureDetector(
                            onTap: changeFit,
                            child: Container(
                              height: width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryDark,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  fit: isFit ? null : BoxFit.cover,
                                  image: FileImage(
                                    _image[currentImageIndex],
                                  ),
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
                              onPressed: currentImageIndex != _image.length - 1
                                  ? () {
                                      removeProductImages(
                                        currentImageIndex,
                                      );
                                    }
                                  : null,
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(width * 0.0125),
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: _image.length,
                            itemBuilder: ((context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentImageIndex = index;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                    height: width * 0.18,
                                    width: width * 0.18,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0.3,
                                        color: primaryDark,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                          _image[index],
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () async {
                              await addProductImages();
                            },
                            icon: Icon(
                              FeatherIcons.plus,
                              size: width * 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
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
                              maxLength: 1000,
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: Colors.cyan.shade700,
                                  ),
                                ),
                                hintText: 'Post...',
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

                          SizedBox(height: 8),

                          // DONE
                          MyButton(
                            text: 'DONE',
                            onTap: () async {
                              await post();
                            },
                            isLoading: isPosting,
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
    );
  }
}
