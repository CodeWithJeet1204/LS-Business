import 'package:ls_business/vendors/utils/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

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
                                    child: Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(e),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
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
