import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/image_pick_dialog.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EventsAddWorkImagesPage extends StatefulWidget {
  const EventsAddWorkImagesPage({
    super.key,
    this.selectedSubCategory,
  });

  final String? selectedSubCategory;

  @override
  State<EventsAddWorkImagesPage> createState() =>
      _EventsAddWorkImagesPageState();
}

class _EventsAddWorkImagesPageState extends State<EventsAddWorkImagesPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final List<File> _image = [];
  int currentImageIndex = 0;
  bool isFit = false;
  bool isDone = false;

  // ADD IMAGE
  Future<void> addImage() async {
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

  // REMOVE IMAGE
  void removeImage(int index) {
    setState(() {
      _image.removeAt(index);
    });
  }

  // CHANGE FIT
  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  // DONE
  Future<void> done() async {
    if (_image.isEmpty) {
      return mySnackBar(context, 'Add Atleast 1 Image');
    }

    setState(() {
      isDone = true;
    });

    final List<String> imageDownloadUrl = [];

    for (File img in _image) {
      try {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('Events/WorkImages')
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

    final eventSnap =
        await store.collection('Organizers').doc(auth.currentUser!.uid).get();

    final eventData = eventSnap.data()!;

    List workImages = eventData['workImages'];

    for (var downloadUrl in imageDownloadUrl) {
      workImages.insert(0, downloadUrl);
    }

    await store.collection('Organizers').doc(auth.currentUser!.uid).update({
      'workImages': workImages,
    });

    setState(() {
      isDone = false;
    });
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Work Images'),
        actions: [
          MyTextButton(
            onPressed: () async {
              await done();
            },
            text: 'DONE',
            textColor: primaryDark,
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              isDone ? const Size(double.infinity, 10) : const Size(0, 0),
          child: isDone ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width * 0.006125,
          ),
          child: LayoutBuilder(
            builder: ((context, constraints) {
              final width = constraints.maxWidth;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // IMAGE
                    _image.isNotEmpty
                        ? Column(
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
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                        onPressed: currentImageIndex !=
                                                _image.length - 1
                                            ? () {
                                                removeImage(
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
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: primaryDark,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    height: width * 0.225,
                                    width: width * 0.79,
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
                                                borderRadius:
                                                    BorderRadius.circular(4),
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
                                  SizedBox(width: width * 0.0275),
                                  Container(
                                    height: width * 0.19,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: primaryDark,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      splashRadius: width * 0.095,
                                      onPressed: () async {
                                        await addImage();
                                      },
                                      icon: Icon(
                                        FeatherIcons.plus,
                                        size: width * 0.115,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : SizedOverflowBox(
                            size: Size(width, width),
                            child: InkWell(
                              onTap: () async {
                                await addImage();
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
                                    color: primaryDark,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                          ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
