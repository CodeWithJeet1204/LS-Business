import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class PickLocationPage extends StatefulWidget {
  const PickLocationPage({
    super.key,
    this.eventId,
  });

  final String? eventId;

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  final store = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
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
      body: OpenStreetMapSearchAndPick(
        buttonColor: primaryDark,
        buttonText: 'Set Location',
        buttonHeight: 50,
        buttonWidth: MediaQuery.sizeOf(context).width * 0.8,
        buttonTextColor: white,
        onPicked: (pickedData) async {
          Navigator.of(context)
              .pop([pickedData.addressName, pickedData.latLong]);
        },
      ),
    );
  }
}
