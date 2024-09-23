import 'package:cached_network_image/cached_network_image.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class ImageView extends StatefulWidget {
  const ImageView({
    super.key,
    required this.imagesUrl,
    this.shortsURL,
    this.shortsThumbnail,
  });

  final List imagesUrl;
  final String? shortsURL;
  final String? shortsThumbnail;

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  final carouselController = CarouselSliderController();
  late FlickManager flickManager;
  int currentIndex = 0;

  // INIT STATE
  @override
  void initState() {
    super.initState();

    if (widget.shortsURL != null) {
      flickManager = FlickManager(
        autoPlay: false,
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(
            widget.shortsURL!,
          ),
        ),
      );
    }
  }

  // DISPOSE
  @override
  void dispose() {
    if (widget.shortsURL != null) {
      flickManager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  subject: 'LS Business Feedback',
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          if (widget.shortsURL == '' || widget.shortsURL == null) {
            if (widget.imagesUrl.contains(widget.shortsURL)) {
              widget.imagesUrl.remove(widget.shortsURL);
            }
            if (widget.imagesUrl.contains(widget.shortsThumbnail)) {
              widget.imagesUrl.remove(widget.shortsThumbnail);
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: width,
                  height: height * 0.85,
                  child: CarouselSlider(
                    carouselController: carouselController,
                    items: widget.imagesUrl
                        .map((e) => e == widget.shortsURL
                            ? FlickVideoPlayer(
                                flickManager: flickManager,
                              )
                            : SizedBox(
                                height: height * 0.85,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: InteractiveViewer(
                                    child: CachedNetworkImage(
                                      imageUrl: e,
                                      imageBuilder: (context, imageProvider) {
                                        return Center(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ))
                        .toList(),
                    options: CarouselOptions(
                      enableInfiniteScroll: false,
                      aspectRatio: 0.6125,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          carouselController.animateToPage(index);
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.0125,
                  ),
                  child: SizedBox(
                    width: width,
                    height: height * 0.1,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: widget.imagesUrl.length,
                      itemBuilder: ((context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                carouselController.jumpToPage(index);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: primaryDark,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  widget.imagesUrl[index] == widget.shortsURL
                                      ? widget.shortsThumbnail
                                      : widget.imagesUrl[index],
                                  height: width * 0.175,
                                  width: width * 0.175,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
