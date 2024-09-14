import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ShortsTile extends StatefulWidget {
  const ShortsTile({
    super.key,
    required this.data,
    required this.snappedPageIndex,
    required this.currentIndex,
  });

  final Map<String, dynamic> data;
  final int snappedPageIndex;
  final int currentIndex;

  @override
  State<ShortsTile> createState() => _ShortsTileState();
}

class _ShortsTileState extends State<ShortsTile> {
  late FlickManager flickManager;
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
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
          widget.data.values.toList()[0][0],
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

  // GET VENDOR INFO
  Future<String> getVendorInfo(String vendorId) async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(vendorId)
        .get();

    final vendorData = vendorSnap.data()!;

    final vendorName = vendorData['Name'] as String;

    return vendorName;
  }

  // GET PRODUCT NAME
  Future<String> getProductName(String productId) async {
    final productSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .doc(productId)
        .get();

    final productData = productSnap.data()!;

    final productName = productData['productName'] as String;

    return productName;
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            FutureBuilder(
                                              future: getVendorInfo(
                                                widget.data.values.toList()[0]
                                                    [5],
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasError) {
                                                  return Container();
                                                }

                                                if (snapshot.hasData) {
                                                  return Padding(
                                                    padding: EdgeInsets.all(
                                                      width * 0.006125,
                                                    ),
                                                    child: Text(
                                                      snapshot.data!,
                                                      style: TextStyle(
                                                        color: white,
                                                        fontSize: width * 0.05,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  );
                                                }

                                                return Container();
                                              },
                                            ),
                                          ],
                                        ),
                                        Text(
                                          widget.data.values.toList()[0][2],
                                          style: TextStyle(
                                            color: white,
                                            fontSize: width * 0.05,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
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
          );
  }
}
