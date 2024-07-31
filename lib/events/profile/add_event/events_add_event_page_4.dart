import 'dart:io';

import 'package:Localsearch/events/events_main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:Localsearch/widgets/text_form_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class EventsAddEventPage4 extends StatefulWidget {
  const EventsAddEventPage4({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  State<EventsAddEventPage4> createState() => _EventsAddEventPage4State();
}

class _EventsAddEventPage4State extends State<EventsAddEventPage4> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final descriptionController = TextEditingController();
  final helpContactNumberController = TextEditingController();
  bool isDone = false;

  // DONE
  Future<void> done() async {
    final organizerSnap =
        await store.collection('Organizers').doc(auth.currentUser!.uid).get();

    final organizerData = organizerSnap.data()!;

    final name = organizerData['Name'];

    setState(() {
      isDone = true;
    });
    Map<String, dynamic> data = {
      'eventDescription': descriptionController.text,
      'organizerName': name,
      'organizerId': auth.currentUser!.uid,
      'contactHelp': helpContactNumberController.text,
      'wishlists': [],
      'workImages': [],
    };

    data.addAll(widget.data);

    List<File> image = data['imageUrl'];

    List<String> downloadUrls = [];

    final String eventId = const Uuid().v4();

    data.addAll({
      'eventId': eventId,
    });

    await Future.forEach(image, (File img) async {
      final String imageId = const Uuid().v4();

      Reference ref = FirebaseStorage.instance
          .ref()
          .child('Events/$eventId')
          .child(imageId);

      await ref.putFile(File(img.path)).then((TaskSnapshot snapshot) async {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }).catchError((error) {
        mySnackBar(context, error.toString());
      });
    });

    data['imageUrl'] = downloadUrls;

    await store.collection('Events').doc(eventId).set(data);

    setState(() {
      isDone = false;
    });
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const EventsMainPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          MyTextButton(
            onPressed: () async {
              await done();
            },
            text: 'DONE',
            textColor: primaryDark2,
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              isDone ? const Size(double.infinity, 10) : const Size(0, 0),
          child: isDone ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width * 0.0125,
          ),
          child: LayoutBuilder(
            builder: ((context, constraints) {
              final width = constraints.maxWidth;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DESCRIPTION
                    TextFormField(
                      controller: descriptionController,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      minLines: 5,
                      maxLines: 20,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.cyan.shade700,
                          ),
                        ),
                        hintText: 'Description',
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Divider(),

                    const SizedBox(height: 8),

                    // CONTACT HELP
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.025),
                      child: const Text(
                        'Contact No. for Help',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // CONTACT HELP
                    MyTextFormField(
                      hintText: 'Contact No. for Help',
                      controller: helpContactNumberController,
                      keyboardType: TextInputType.number,
                      borderRadius: 8,
                      horizontalPadding: 0,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
