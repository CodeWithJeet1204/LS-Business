import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/vendors/page/main/add/shorts/select_product_for_shorts_page.dart';
import 'package:find_easy/vendors/page/main/main_page.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  final nameController = TextEditingController();
  late VideoPlayerController controller;
  bool isDone = false;
  List? data;

  // INIT STATE
  @override
  void initState() {
    super.initState();
    setState(() {
      controller = VideoPlayerController.file(widget.videoFile);
    });
    controller.initialize();
    controller.play();
    controller.setVolume(1);
    controller.setLooping(true);
  }

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    controller.dispose();
    super.dispose();
  }

  // UPLOAD VIDEO
  Future<void> uploadVideo(
    String productName,
    String productId,
    String videoPath,
  ) async {
    setState(() {
      isDone = true;
    });

    Reference shortsRef =
        await storage.ref().child('Data/Shorts').child(productId);

    UploadTask uploadShortsTask = shortsRef.putFile(
      await compressVideo(videoPath),
    );

    TaskSnapshot shortsSnao = await uploadShortsTask;
    String shortsDownloadUrl = await shortsSnao.ref.getDownloadURL();

    Reference thumbnailRef =
        await storage.ref().child('Data/Thumbnails').child(productId);

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

    setState(() {
      isDone = false;
    });

    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: ((context) => MainPage()),
      ),
      (route) => false,
    );
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
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            SizedBox(
              width: width,
              height: height / 1.5,
              child: VideoPlayer(controller),
            ),
            SizedBox(height: 30),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(
                    text: data != null ? data![1]! : 'Select Product',
                    onTap: () async {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: ((context) => SelectProductForShortsPage(
                                selectedProduct: data?[0],
                              )),
                        ),
                      )
                          .then((value) {
                        setState(() {
                          data = value;
                        });
                      });
                    },
                    isLoading: false,
                    horizontalPadding: width * 0.025,
                  ),
                  SizedBox(height: 10),
                  data == null
                      ? Container()
                      : MyButton(
                          text: 'DONE',
                          onTap: () async {
                            await uploadVideo(
                                data![0], data![0], widget.videoPath);
                          },
                          isLoading: isDone,
                          horizontalPadding: width * 0.025,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
