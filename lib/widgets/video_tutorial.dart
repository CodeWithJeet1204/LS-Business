import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// SHOW YOUTUBE PLAYER DIALOG
Future<void> showYouTubePlayerDialog(BuildContext context, String? code) async {
  final store = FirebaseFirestore.instance;

  final tutorialSnap = await store.collection('Tutorial').doc('Tutorial').get();

  final tutorialData = tutorialSnap.data()!;

  final url = tutorialData[code];

  if (url != null) {
    String? videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null) {
      if (videoId.isNotEmpty) {
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return YouTubePlayerDialog(
                videoId: videoId,
              );
            },
          );
        }
      } else {
        if (context.mounted) {
          mySnackBar(context, 'Some error occured');
        }
      }
    } else {
      if (context.mounted) {
        mySnackBar(context, 'Some error occured');
      }
    }
  } else {
    if (context.mounted) {
      mySnackBar(context, 'Some error occured');
    }
  }
}

// GET YOUTUBE VIDEO ID
String? getYoutubeVideoId(String url) {
  return YoutubePlayer.convertUrlToId(url);
}

class YouTubePlayerDialog extends StatefulWidget {
  const YouTubePlayerDialog({
    super.key,
    required this.videoId,
  });

  final String videoId;

  @override
  YouTubePlayerDialogState createState() => YouTubePlayerDialogState();
}

class YouTubePlayerDialogState extends State<YouTubePlayerDialog> {
  late YoutubePlayerController controller;

  // INIT STATE
  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        showLiveFullscreenButton: false,
      ),
    );
  }

  // DISPOSE
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          YoutubePlayer(
            controller: controller,
            aspectRatio: 9 / 16,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            bottomActions: const [
              CurrentPosition(),
              ProgressBar(
                isExpanded: true,
                colors: ProgressBarColors(
                  playedColor: primary2,
                  handleColor: darkGrey,
                ),
              ),
            ],
            onEnded: (metaData) {
              controller.seekTo(const Duration(seconds: 0));
              controller.play();
            },
          ),
        ],
      ),
    );
  }
}
