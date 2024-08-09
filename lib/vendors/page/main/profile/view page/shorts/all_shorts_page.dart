import 'package:Localsearch/vendors/page/main/profile/view%20page/shorts/shorts_page_view.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AllShortsPage extends StatefulWidget {
  const AllShortsPage({super.key});

  @override
  State<AllShortsPage> createState() => _AllShortsPageState();
}

class _AllShortsPageState extends State<AllShortsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  Map<String, List> allShorts = {};
  Map<String, List> currentShorts = {};
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getShorts();
    super.initState();
  }

  // GET SHORTS
  Future<void> getShorts() async {
    Map<String, List> myShorts = {};
    print(1);
    final shortsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Shorts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    print('length: ${shortsSnap.docs.length}');

    Future.forEach(shortsSnap.docs, (short) async {
      final shortsData = short.data();

      final shortsId = short.id;
      print('shortsId: $shortsId');
      final datetime = shortsData['datetime'];
      final productId = shortsData['productId'];
      final shortsUrl = shortsData['shortsURL'];
      final vendorId = auth.currentUser!.uid;

      final productSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(productId)
          .get();

      final productData = productSnap.data()!;

      final productName = productData['productName'];

      print('productName: $productName');

      Reference thumbnailRef = FirebaseStorage.instance
          .ref()
          .child('Data/Thumbnails')
          .child(productId);

      String thumbnailDownloadUrl = await thumbnailRef.getDownloadURL();

      myShorts[shortsId] = [
        shortsUrl,
        productId,
        productName,
        datetime,
        thumbnailDownloadUrl,
        vendorId,
      ];

      print('done');
    });

    myShorts = Map.fromEntries(myShorts.entries.toList()
      ..sort((a, b) => (b.value[3] as Timestamp).compareTo(a.value[3])));

    print('lalla: $myShorts');

    setState(() {
      allShorts = myShorts;
      currentShorts = myShorts;
      isData = true;
    });
  }

  // DELETE SHORT
  Future<void> deleteShort() async {}

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('ALL SHORTS'),
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            60,
          ),
          child: Padding(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width * 0.0125,
            ),
            child: SizedBox(
              width: width,
              child: TextField(
                controller: searchController,
                autocorrect: false,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  hintText: 'Search ...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      currentShorts = Map<String, List>.from(allShorts);
                    } else {
                      Map<String, List> filteredShorts =
                          Map<String, List>.from(allShorts);
                      List<String> keysToRemove = [];

                      filteredShorts.forEach((key, postData) {
                        if (!postData[2]
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase().trim())) {
                          keysToRemove.add(key);
                        }
                      });

                      for (var key in keysToRemove) {
                        filteredShorts.remove(key);
                      }

                      setState(() {
                        currentShorts = filteredShorts;
                      });
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ),
      body: !isData
          ? SafeArea(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: width * 0.5 / width * 1.6,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(
                      width * 0.02,
                    ),
                    child: GridViewSkeleton(
                      width: width,
                      isPrice: true,
                      isDelete: true,
                    ),
                  );
                },
              ),
            )
          : currentShorts.isEmpty
              ? const Center(
                  child: Text('No Shorts'),
                )
              : SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 9 / 15.66,
                        ),
                        itemCount: currentShorts.length,
                        itemBuilder: (context, index) {
                          final shortsId = currentShorts.keys.toList()[index];
                          // final shortsURL = currentShorts.values.toList()[index][0];
                          final shortsThumbnail =
                              currentShorts.values.toList()[index][4];

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ShortsPageView(
                                    shorts: currentShorts,
                                    shortsId: shortsId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryDark,
                              ),
                              padding: EdgeInsets.all(
                                width * 0.00306125,
                              ),
                              margin: EdgeInsets.all(width * 0.0036125),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    shortsThumbnail,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    width: width * 0.125,
                                    height: width * 0.125,
                                    decoration: BoxDecoration(
                                      color: white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(
                                        100,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: white,
                                      size: width * 0.1,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      FeatherIcons.trash,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
