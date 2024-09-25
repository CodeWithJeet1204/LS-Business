import 'dart:io';
import 'package:ls_business/widgets/show_loading_dialog.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/page/main/add/shorts/select_product_for_shorts_page.dart';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

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
  final captionController = TextEditingController();
  late FlickManager flickManager;
  bool isDone = false;
  Map<String, dynamic>? data;

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
    captionController.dispose();
    flickManager.dispose();
    super.dispose();
  }

  // UPLOAD VIDEO
  Future<void> uploadVideo(
    String? productId,
    String? productName,
    String videoPath,
  ) async {
    setState(() {
      isDone = true;
    });

    final shortsId = Uuid().v4();

    Reference shortsRef = storage.ref().child('Vendor/Shorts').child(shortsId);

    UploadTask uploadShortsTask = shortsRef.putFile(
      await compressVideo(videoPath),
    );

    TaskSnapshot shortsSnap = await uploadShortsTask;
    String shortsDownloadUrl = await shortsSnap.ref.getDownloadURL();

    Reference thumbnailRef =
        storage.ref().child('Vendor/Thumbnails').child(shortsId);

    UploadTask uploadThumbnailTask = thumbnailRef.putFile(
      await getThumbnail(videoPath),
    );

    TaskSnapshot thumbnailSnap = await uploadThumbnailTask;
    String thumbnailDownloadUrl = await thumbnailSnap.ref.getDownloadURL();

    if (productId != null) {
      await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(productId)
          .update({
        'shortsURL': shortsDownloadUrl,
        'shortsThumbnail': thumbnailDownloadUrl,
      });
    }

    await store
        .collection('Business')
        .doc('Data')
        .collection('Shorts')
        .doc(shortsId)
        .set({
      'vendorId': auth.currentUser!.uid,
      'shortsURL': shortsDownloadUrl,
      'shortsThumbnail': thumbnailDownloadUrl,
      'productId': productId,
      'productName': productName,
      'caption': productId != null ? null : captionController.text,
      'datetime': DateTime.now(),
    });

    setState(() {
      isDone = false;
    });

    if (mounted) {
      mySnackBar(context, 'Shorts Added');
      Navigator.of(context).pop();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainPage(),
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
      appBar: AppBar(),
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
                SizedBox(height: 20),
                MyTextFormField(
                  hintText: 'Caption',
                  controller: captionController,
                  borderRadius: 12,
                  horizontalPadding: 0,
                ),
                const SizedBox(height: 15),
                MyButton(
                  text: data != null ? data!['productName']! : 'Select Product',
                  onTap: () async {
                    if (flickManager.flickVideoManager!.isPlaying) {
                      flickManager.flickControlManager!.togglePlay();
                    }
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => SelectProductForShortsPage(
                          selectedProduct: data?['productId'],
                        ),
                      ),
                    )
                        .then((value) {
                      setState(() {
                        data = value;
                      });
                    });
                  },
                  horizontalPadding: 0,
                ),
                const SizedBox(height: 15),
                MyButton(
                  text: 'DONE',
                  onTap: () async {
                    await showLoadingDialog(
                      context,
                      () async {
                        await uploadVideo(
                          data?['productId'],
                          data?['productName'],
                          widget.videoPath,
                        );
                      },
                    );
                  },
                  horizontalPadding: 0,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
