import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventsWorkImagesPage extends StatefulWidget {
  const EventsWorkImagesPage({super.key});

  @override
  State<EventsWorkImagesPage> createState() => _EventsWorkImagesPageState();
}

class _EventsWorkImagesPageState extends State<EventsWorkImagesPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  List workImages = [];
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    final eventSnap =
        await store.collection('Organizers').doc(auth.currentUser!.uid).get();

    final eventData = eventSnap.data()!;

    final myWorkImages = eventData['workImages'];

    setState(() {
      workImages = myWorkImages;
      isData = true;
    });
  }

  // SHOW IMAGE
  Future<void> showImage(String imageUrl) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: ((context) {
        return Dialog(
          elevation: 20,
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Images'),
      ),
      body: !isData
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : workImages.isEmpty
              ? const Center(
                  child: Text('No Images'),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(
                      width * 0.006125,
                    ),
                    child: SizedBox(
                      width: width,
                      height: MediaQuery.of(context).size.height,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                        ),
                        itemCount: workImages.length,
                        itemBuilder: ((context, index) {
                          final imageUrl = workImages[index];

                          return GestureDetector(
                            onTap: () async {
                              await showImage(imageUrl);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.25,
                                  color: primaryDark,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              margin: EdgeInsets.all(width * 0.0125),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
    );
  }
}
