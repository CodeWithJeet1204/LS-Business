import 'package:ls_business/vendors/page/main/profile/view%20page/product/product_page.dart';
import 'package:ls_business/vendors/page/main/profile/view%20page/shorts/all_shorts_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ShortsTile extends StatefulWidget {
  const ShortsTile({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  State<ShortsTile> createState() => _ShortsTileState();
}

class _ShortsTileState extends State<ShortsTile> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  late FlickManager flickManager;
  bool isWishListed = false;
  bool isWishlistLocked = false;
  bool isVideoPlaying = true;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(
          widget.data['shortsURL'],
        ),
      ),
    );
    flickManager.flickVideoManager!.videoPlayerController?.addListener(() {
      if (flickManager
              .flickVideoManager!.videoPlayerController!.value.position ==
          flickManager
              .flickVideoManager!.videoPlayerController!.value.duration) {
        flickManager.flickControlManager!.seekTo(
          const Duration(
            seconds: 0,
          ),
        );
        flickManager.flickControlManager!.play();
      }
    });
    setState(() {
      isData = true;
    });
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  // PAUSE PLAY SHORT
  void pausePlayShort() {
    flickManager.flickControlManager?.togglePlay();

    setState(() {
      isVideoPlaying = !isVideoPlaying;
    });
  }

  // CONFIRM DELETE SHORT
  Future<void> confirmDeleteShort() async {
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : AlertDialog(
                title: const Text('Delete Short'),
                content:
                    const Text('Are you sure you want to delete this short?'),
                actions: [
                  MyTextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    text: 'NO',
                    textColor: Colors.green,
                  ),
                  MyTextButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await deleteShort();
                      setState(() {
                        isLoading = false;
                      });
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AllShortsPage(),
                          ),
                        );
                      }
                    },
                    text: 'YES',
                    textColor: Colors.red,
                  ),
                ],
              );
      },
    );
  }

  // DELETE SHORT
  Future<void> deleteShort() async {
    await store
        .collection('Business')
        .doc('Data')
        .collection('Shorts')
        .doc(widget.data['shortsId'])
        .delete();

    if (widget.data['productId'] != null) {
      await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(widget.data['productId'])
          .update({
        'shortsThumbnail': '',
        'shortsURL': '',
      });
    }

    await storage.ref('Vendor/Shorts/${widget.data['shortsId']}').delete();

    await storage.ref('Vendor/Thumbnails/${widget.data['shortsId']}').delete();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return isData
        ? Scaffold(
            body: Stack(
              children: [
                GestureDetector(
                  onTap: pausePlayShort,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FlickVideoPlayer(
                        flickManager: flickManager,
                        flickVideoWithControls: const FlickVideoWithControls(
                          videoFit: BoxFit.contain,
                          playerLoadingFallback: Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              color: white,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !isVideoPlaying,
                        child: IconButton(
                          onPressed: pausePlayShort,
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            size: 80,
                            color: white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(width * 0.025),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(
                                    FeatherIcons.arrowLeft,
                                    color: Colors.white,
                                  ),
                                  iconSize: width * 0.075,
                                  color: Colors.white,
                                  tooltip: 'Back',
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await confirmDeleteShort();
                                  },
                                  icon: const Icon(
                                    FeatherIcons.trash,
                                    color: Colors.red,
                                  ),
                                  iconSize: width * 0.1,
                                  color: Colors.red,
                                  tooltip: 'Delete Short',
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: width * 0.0125,
                                    ),
                                    child: GestureDetector(
                                      onTap: widget.data['productId'] == null
                                          ? null
                                          : () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductPage(
                                                    productId: widget
                                                        .data['productId'],
                                                    productName: widget
                                                        .data['productName'],
                                                  ),
                                                ),
                                              );
                                            },
                                      child: Text(
                                        widget.data['productName'] ??
                                            widget.data['caption'],
                                        style: TextStyle(
                                          color: white,
                                          fontSize: width * 0.05,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: width * 0.05),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      FeatherIcons.share2,
                                      size: width * 0.095,
                                      color: white,
                                    ),
                                    tooltip: 'SHARE',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Stack(
            children: [
              const Center(
                child: CircularProgressIndicator(
                  color: white,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(width * 0.025),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(
                              left: width * 0.0125,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(
                                        width * 0.006125,
                                      ),
                                      child: Container(),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(
                                    width * 0.006125,
                                  ),
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.05),
                          child: IconButton(
                            onPressed: () async {},
                            icon: Icon(
                              FeatherIcons.share2,
                              size: width * 0.095,
                              color: white,
                            ),
                            tooltip: 'SHARE',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
