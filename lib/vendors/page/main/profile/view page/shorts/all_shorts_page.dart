import 'package:Localsearch/vendors/page/main/profile/view%20page/shorts/shorts_page_view.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  int? total;
  int noOf = 20;
  bool isLoadMore = false;
  final scrollController = ScrollController();
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getTotal();
    getShortsData();
    scrollController.addListener(scrollListener);
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // SCROLL LISTENER
  Future<void> scrollListener() async {
    if (total != null && noOf < total!) {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          isLoadMore = true;
        });
        noOf = noOf + 12;
        await getShortsData();
        setState(() {
          isLoadMore = false;
        });
      }
    }
  }

  // GET TOTAL
  Future<void> getTotal() async {
    final shortsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Shorts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    final shortsLength = shortsSnap.docs.length;

    setState(() {
      total = shortsLength;
    });
  }

  // GET SHORTS DATA
  Future<void> getShortsData() async {
    Map<String, List> myShorts = {};
    final shortsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Shorts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .limit(noOf)
        .get();

    await Future.forEach(
      shortsSnap.docs,
      (short) async {
        final shortsData = short.data();

        final shortsId = short.id;
        final datetime = shortsData['datetime'];
        final shortsURL = shortsData['shortsURL'];
        final vendorId = auth.currentUser!.uid;

        final productSnap = await store
            .collection('Business')
            .doc('Data')
            .collection('Products')
            .doc(shortsId)
            .get();

        final productData = productSnap.data()!;

        final productName = productData['productName'];

        Reference thumbnailRef = FirebaseStorage.instance
            .ref()
            .child('Vendor/Thumbnails')
            .child(shortsId);

        String thumbnailDownloadUrl = await thumbnailRef.getDownloadURL();

        myShorts[shortsId] = [
          shortsURL,
          shortsId,
          productName,
          datetime,
          thumbnailDownloadUrl,
          vendorId,
        ];
      },
    );

    myShorts = Map.fromEntries(myShorts.entries.toList()
      ..sort((a, b) => (b.value[3] as Timestamp).compareTo(a.value[3])));

    setState(() {
      allShorts = myShorts;
      currentShorts = myShorts;
      isData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Shorts'),
        bottom: PreferredSize(
          preferredSize: Size(width, 60),
          child: Padding(
            padding: EdgeInsets.all(
              width * 0.0125,
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

                      filteredShorts.forEach((key, shortsData) {
                        if (!shortsData[2]
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
                physics: const ClampingScrollPhysics(),
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
                      isPrice: false,
                      isDelete: false,
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
                      final height = constraints.maxHeight;

                      return GridView.builder(
                        controller: scrollController,
                        cacheExtent: height * 1.5,
                        addAutomaticKeepAlives: true,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 9 / 15.66,
                        ),
                        itemCount: noOf > currentShorts.length
                            ? currentShorts.length
                            : noOf,
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
                              decoration: const BoxDecoration(
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
                                  // IconButton(
                                  //   onPressed: () {},
                                  //   icon: Icon(
                                  //     FeatherIcons.trash,
                                  //     color: Colors.red,
                                  //   ),
                                  //   tooltip: 'Delete',
                                  // ),
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
