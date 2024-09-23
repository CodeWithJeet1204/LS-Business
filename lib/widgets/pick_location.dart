import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

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
      body: OpenStreetMapSearchAndPick(
        buttonColor: primaryDark,
        buttonText: 'Set Location',
        buttonHeight: 50,
        buttonWidth: MediaQuery.of(context).size.width * 0.8,
        buttonTextColor: white,
        onPicked: (pickedData) async {
          Navigator.of(context)
              .pop([pickedData.addressName, pickedData.latLong]);
        },
      ),
    );
  }
}
