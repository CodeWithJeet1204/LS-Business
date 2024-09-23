import 'dart:io';
import 'package:Localsearch/widgets/show_loading_dialog.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Localsearch/vendors/page/main/add/shorts/select_product_for_shorts_page.dart';
import 'package:Localsearch/vendors/page/main/main_page.dart';
import 'package:Localsearch/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class ConfirmShortsPage extends StatefulWidget {
  const ConfirmShortsPage({
    super.key,
    required this.videoFile,
    required this.videoPath,
  });

  final File videoFile;
  final String videoPath;

  @override
  State<ConfirmShortsPage> createState() => _ConfirmShortsPageState();
}

class _ConfirmShortsPageState extends State<ConfirmShortsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final nameController = TextEditingController();
  late FlickManager flickManager;
  bool isDone = false;
  List? data;

  // INIT STATE
  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.file(
          widget.videoFile.path,
        ),
      ),
    );
  }

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    flickManager.dispose();
    super.dispose();
  }

  // UPLOAD VIDEO
  Future<void> uploadVideo(
    String productId,
    String videoPath,
  ) async {
    setState(() {
      isDone = true;
    });

    Reference shortsRef = storage.ref().child('Vendor/Shorts').child(productId);

    UploadTask uploadShortsTask = shortsRef.putFile(
      await compressVideo(videoPath),
    );

    TaskSnapshot shortsSnap = await uploadShortsTask;
    String shortsDownloadUrl = await shortsSnap.ref.getDownloadURL();

    Reference thumbnailRef =
        storage.ref().child('Vendor/Thumbnails').child(productId);

    UploadTask uploadThumbnailTask = thumbnailRef.putFile(
      await getThumbnail(videoPath),
    );

    TaskSnapshot thumbnailSnap = await uploadThumbnailTask;
    String thumbnailDownloadUrl = await thumbnailSnap.ref.getDownloadURL();

    await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .doc(productId)
        .update({
      'shortsURL': shortsDownloadUrl,
      'shortsThumbnail': thumbnailDownloadUrl,
    });

    await store
        .collection('Business')
        .doc('Data')
        .collection('Shorts')
        .doc(productId)
        .set({
      'datetime': DateTime.now(),
      'vendorId': auth.currentUser!.uid,
      'shortsURL': shortsDownloadUrl,
    });

    setState(() {
      isDone = false;
    });

    mySnackBar(context, 'Shorts Added');
    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: ((context) => const MainPage()),
        ),
        (route) => false,
      );
    }
  }

  // COMPRESS VIDEO
  Future<File> compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );

    return compressedVideo!.file!;
  }

  // GET THUMBNAIL
  Future<File> getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);

    return thumbnail;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              BetterFeedback.of(context).show((feedback) async {
                Future<String> writeImageToStorage(
                    Uint8List feedbackScreenshot) async {
                  final Directory output = await getTemporaryDirectory();
                  final String screenshotFilePath =
                      '${output.path}/feedback.png';
                  final File screenshotFile = File(screenshotFilePath);
                  await screenshotFile.writeAsBytes(feedbackScreenshot);
                  return screenshotFilePath;
                }

                final screenshotFilePath =
                    await writeImageToStorage(feedback.screenshot);

                final Email email = Email(
                  body: feedback.text,
                  subject: 'Localsearch Feedback',
                  recipients: ['infinitylab1204@gmail.com'],
                  attachmentPaths: [screenshotFilePath],
                  isHTML: false,
                );
                await FlutterEmailSender.send(email);
              });
            },
            icon: const Icon(
              Icons.bug_report_outlined,
            ),
            tooltip: 'Report Problem',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              children: [
                const SizedBox(height: 4),
                FlickVideoPlayer(
                  flickManager: flickManager,
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: data != null ? data![1]! : 'Select Product',
                  onTap: () async {
                    if (flickManager.flickVideoManager!.isPlaying) {
                      flickManager.flickControlManager!.togglePlay();
                    }
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => SelectProductForShortsPage(
                          selectedProduct: data?[0],
                        ),
                      ),
                    )
                        .then((value) {
                      setState(() {
                        data = value;
                      });
                    });
                  },
                  horizontalPadding: width * 0.025,
                ),
                const SizedBox(height: 15),
                if (data != null)
                  MyButton(
                    text: 'DONE',
                    onTap: () async {
                      await showLoadingDialog(
                        context,
                        () async {
                          await uploadVideo(data![0], widget.videoPath);
                        },
                      );
                    },
                    horizontalPadding: width * 0.025,
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
