import 'dart:io';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/services.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/page/main/add/shorts/select_product_for_shorts_page.dart';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:ls_business/widgets/video_tutorial.dart';
import 'package:video_player/video_player.dart';

class ConfirmShortsPage extends StatefulWidget {
  const ConfirmShortsPage({
    super.key,
    required this.videoFile,
    required this.videoPath,
    required this.isShared,
  });

  final File videoFile;
  final String videoPath;
  final bool isShared;

  @override
  State<ConfirmShortsPage> createState() => _ConfirmShortsPageState();
}

class _ConfirmShortsPageState extends State<ConfirmShortsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final captionController = TextEditingController();
  late FlickManager flickManager;
  String? sharedVideo;
  Map<String, dynamic>? data;
  bool isDialog = false;
  bool isDone = false;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    if (widget.isShared) {
      handleReceivedVideo(widget.videoPath);
    }
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
    // flickManager.dispose();
    super.dispose();
  }

  // CHECK AND SAVE VIDEO
  Future<String?> checkAndSaveVideo(String contentUri) async {
    const platform = MethodChannel('com.ls_business.share');

    if (await Permission.videos.request().isGranted) {
      try {
        final dir = await getExternalStorageDirectory();
        final filePath = await platform.invokeMethod(
          'copyVideoFromUri',
          {
            "uri": contentUri,
            "destinationPath": '${dir!.path}/shared_video.mp4'
          },
        );

        if (filePath != null) {
          return filePath;
        }
      } catch (e) {}
    }
    return null;
  }

  // HANDLE RECEIVED VIDEO
  Future<void> handleReceivedVideo(String videoPath) async {
    String? localFilePath = await checkAndSaveVideo(
      videoPath,
    );

    if (localFilePath != null) {
      setState(() {
        sharedVideo = localFilePath;
      });
    }

    setState(() {
      isData = true;
    });
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

  // UPLOAD SHORT
  Future<void> uploadShort(
    String? productId,
    String? productName,
    String videoPath,
  ) async {
    setState(() {
      isDone = true;
      isDialog = true;
    });

    final shortsId = const Uuid().v4();

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
      'shortsViewsTimestamp': [],
      'productId': productId,
      'productName': productName,
      'caption':
          productId != null ? null : captionController.text.toString().trim(),
      'datetime': DateTime.now(),
    });

    setState(() {
      isDone = false;
      isDialog = false;
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        progressIndicator: LoadingIndicator(),
        child: Scaffold(
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
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    FlickVideoPlayer(
                      flickManager: flickManager,
                    ),
                    const SizedBox(height: 20),
                    MyTextFormField(
                      hintText: 'Caption',
                      controller: captionController,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 15),
                    Text('OR'),
                    const SizedBox(height: 15),
                    MyButton(
                      text: data != null
                          ? data!['productName']!
                          : 'Select Product',
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
                    ),
                    Divider(height: 30),
                    MyButton(
                      text: 'DONE',
                      onTap: () async {
                        await uploadShort(
                          data?['productId'],
                          data?['productName'],
                          widget.videoPath,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
