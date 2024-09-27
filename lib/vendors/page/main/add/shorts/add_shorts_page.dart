import 'dart:async';
import 'dart:io';
import 'package:ls_business/vendors/page/main/add/shorts/confirm_shorts_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class AddShortsPage extends StatefulWidget {
  const AddShortsPage({super.key});

  @override
  AddShortsPageState createState() => AddShortsPageState();
}

class AddShortsPageState extends State<AddShortsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  int? noOfShorts;

  // INIT STATE
  @override
  void initState() {
    getNoOfShorts();
    super.initState();
  }

  // GET NO OF SHORTS
  Future<void> getNoOfShorts() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final shortsQuota = vendorData['noOfShorts'];

    final shortsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Shorts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    final currentShortsLength = shortsSnap.docs.length;

    final remainingShorts = shortsQuota - currentShortsLength;

    setState(() {
      noOfShorts = remainingShorts;
    });
  }

  // SHOW OPTIONS DIALOG
  Future<void> showOptionsDialog(BuildContext context, double width) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  await pickVideo(ImageSource.camera, context);
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primaryDark2,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(27),
                      topRight: Radius.circular(27),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      'Choose Camera',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await pickVideo(ImageSource.gallery, context);
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primaryDark2,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(27),
                      bottomRight: Radius.circular(27),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      'Choose from Gallery',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // PICK AND TRIM VIDEO
  // Future<void> pickAndTrimVideo(ImageSource src, BuildContext context) async {
  //   final Trimmer _trimmer = Trimmer();
  //   final video = await ImagePicker().pickVideo(source: src);
  //   if (video != null) {
  //     try {
  //       await _trimmer.loadVideo(videoFile: File(video.path));
  //       await _trimmer.saveTrimmedVideo(
  //         startValue: 0.0,
  //         endValue:
  //             _trimmer.videoPlayerController!.value.duration.inSeconds > 30
  //                 ? 30.0
  //                 : _trimmer.videoPlayerController!.value.duration.inSeconds
  //                     .toDouble(),
  //         onSave: (String? outputPath) {
  //           if (outputPath != null) {
  //             if (context.mounted) {
  //               Navigator.of(context).push(
  //                 MaterialPageRoute(
  //                   builder: (context) => ConfirmShortsPage(
  //                     videoFile: File(outputPath),
  //                     videoPath: outputPath,
  //                   ),
  //                 ),
  //               );
  //             }
  //           } else {
  //             if (context.mounted) {
  //               return mySnackBar(context, 'Error trimming video');
  //             }
  //           }
  //         },
  //       );
  //     } catch (e) {
  //       print('error: ${e.toString()}');
  //       mySnackBar(context, 'Some error occured');
  //     }
  //   } else {
  //     if (context.mounted) {
  //       return mySnackBar(context, 'Select Video');
  //     }
  //   }
  // }

  // PICK VIDEO
  Future<void> pickVideo(ImageSource src, BuildContext context) async {
    final video = await ImagePicker().pickVideo(source: src);

    if (video != null) {
      final videoFile = File(video.path);
      final controller = VideoPlayerController.file(videoFile);

      await controller.initialize();
      final duration = controller.value.duration;

      if (duration <= const Duration(seconds: 30)) {
        if (context.mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ConfirmShortsPage(
                videoFile: videoFile,
                videoPath: video.path,
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          Navigator.of(context).pop();
          return mySnackBar(
            context,
            'Video too long, please select a video of less than 30 seconds',
          );
        }
      }

      controller.dispose();
    } else {
      if (context.mounted) {
        return mySnackBar(context, 'Select Video');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Shorts'),
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
      body: noOfShorts == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(
                width * 0.006125,
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return noOfShorts == 0
                    ? const Center(
                        child: Text(
                          'Your Shorts Quota has exhausted\nDelete existing shorts or renew your membership to increase limit',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Remaining Shorts Quota: $noOfShorts'),
                          SizedBox(height: height * 0.025),
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                await showOptionsDialog(context, width);
                              },
                              child: Container(
                                width: 190,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: primary2,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Add Video',
                                  style: TextStyle(
                                    color: black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: width * 0.055,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
              }),
            ),
    );
  }
}
