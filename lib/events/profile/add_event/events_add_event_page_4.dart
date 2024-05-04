import 'dart:io';

import 'package:find_easy/events/events_main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:find_easy/widgets/text_form_field.dart';
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
  final organizationNameController = TextEditingController();
  final helpContactNumberController = TextEditingController();
  bool isDone = false;

  // DONE
  Future<void> done() async {
    setState(() {
      isDone = true;
    });
    Map<String, dynamic> data = {
      'eventDescription': descriptionController.text,
      'organizerName': organizationNameController.text,
      'organizerId': auth.currentUser!.uid,
      'contactHelp': helpContactNumberController.text,
    };

    data.addAll(widget.data);

    List<File> _image = data['imageUrl'];

    List<String> downloadUrls = [];

    final String eventId = Uuid().v4();

    data.addAll({
      'eventId': eventId,
    });

    await Future.forEach(_image, (File img) async {
      final String imageId = Uuid().v4();

      Reference ref = FirebaseStorage.instance
          .ref()
          .child('Events/Event/$eventId')
          .child(imageId);

      await ref.putFile(File(img.path)).then((TaskSnapshot snapshot) async {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }).catchError((error) {
        print('Error uploading image: $error');
      });
    });

    data['imageUrl'] = downloadUrls;

    await store.collection('Event').doc(eventId).set(data);

    setState(() {
      isDone = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => EventsMainPage()),
      (route) => false,
    );
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
            text: "DONE",
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

                    SizedBox(height: 8),

                    Divider(),

                    SizedBox(height: 8),

                    // ORGANIZER NAME
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.025),
                      child: Text(
                        'Organizer Person Name',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    // ORGANIZER NAME
                    MyTextFormField(
                      hintText: 'Organizer Person Name',
                      controller: organizationNameController,
                      borderRadius: 8,
                      horizontalPadding: 0,
                    ),

                    SizedBox(height: 8),

                    Divider(),

                    SizedBox(height: 8),

                    // CONTACT HELP
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.025),
                      child: Text(
                        'Help Contact Number',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    // CONTACT HELP
                    MyTextFormField(
                      hintText: 'Help Contact Number',
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
