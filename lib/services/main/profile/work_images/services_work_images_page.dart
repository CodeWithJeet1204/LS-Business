import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesWorkImagesPage extends StatefulWidget {
  const ServicesWorkImagesPage({super.key});

  @override
  State<ServicesWorkImagesPage> createState() => _ServicesWorkImagesPageState();
}

class _ServicesWorkImagesPageState extends State<ServicesWorkImagesPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  List workSubCategories = [];
  List workSubCategoriesImages = [];
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    final serviceSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    final workImages = serviceData['workImages'] as Map<String, dynamic>;
    final List myWorkSubCategories = workImages.keys.toList();
    final List myWorkSubCategoriesImages = workImages.values.toList();

    setState(() {
      workSubCategories = myWorkSubCategories;
      workSubCategoriesImages = myWorkSubCategoriesImages;
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
        title: const Text('Your Work Images'),
      ),
      body: !isData
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : workSubCategories.isEmpty
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
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: workSubCategories.length,
                        itemBuilder: ((context, index) {
                          final subCategory = workSubCategories[index];
                          final images = workSubCategoriesImages[index];

                          return Container(
                            width: width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.5,
                                color: primaryDark,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.0225,
                              vertical: width * 0.033,
                            ),
                            margin: EdgeInsets.all(width * 0.0125),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subCategory,
                                  style: TextStyle(
                                    fontSize: width * 0.045,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: width,
                                  height: width * 0.33,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: images.length,
                                    itemBuilder: ((context, index) {
                                      final imageUrl = images[index];

                                      return GestureDetector(
                                        onTap: () async {
                                          await showImage(imageUrl);
                                        },
                                        child: Container(
                                          width: width * 0.33,
                                          height: width * 0.33,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            image: DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          margin:
                                              EdgeInsets.all(width * 0.0125),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
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
