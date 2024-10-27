import 'package:ls_business/vendors/page/main/add/shorts/add_shorts_page.dart';
import 'package:ls_business/vendors/page/main/profile/view%20page/shorts/shorts_page_view.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/shimmer_skeleton_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

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
  Map<String, Map<String, dynamic>> allShorts = {};
  Map<String, Map<String, dynamic>> currentShorts = {};
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
    Map<String, Map<String, dynamic>> myShorts = {};
    final shortsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Shorts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .limit(noOf)
        .get();

    await Future.wait(
      shortsSnap.docs.map((short) async {
        final shortsData = short.data();
        final shortsId = short.id;
        final shortsURL = shortsData['shortsURL'];
        final shortsThumbnail = shortsData['shortsThumbnail'];
        final String? productId = shortsData['productId'];
        final String? productName = shortsData['productName'];
        final String? caption = shortsData['caption'];
        final datetime = shortsData['datetime'];
        final vendorId = auth.currentUser!.uid;

        myShorts[shortsId] = {
          'shortsURL': shortsURL,
          'shortsId': shortsId,
          'shortsThumbnail': shortsThumbnail,
          'productId': productId,
          'productName': productName,
          'caption': caption,
          'datetime': datetime,
          'vendorId': vendorId,
        };
      }),
    );

    myShorts = Map.fromEntries(
      myShorts.entries.toList()
        ..sort(
          (a, b) => (b.value['datetime'] as Timestamp).compareTo(
            a.value['datetime'],
          ),
        ),
    );

    setState(() {
      allShorts = myShorts;
      currentShorts = myShorts;
      isData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Shorts'),
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
          IconButton(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddShortsPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.add,
            ),
            tooltip: 'Add Shorts',
          ),
        ],
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
                      currentShorts =
                          Map<String, Map<String, dynamic>>.from(allShorts);
                    } else {
                      Map<String, Map<String, dynamic>> filteredShorts =
                          Map<String, Map<String, dynamic>>.from(allShorts);

                      List<String> keysToRemove =
                          filteredShorts.keys.where((key) {
                        final shortsData = filteredShorts[key]!;
                        return !shortsData['productName']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase().trim()) &&
                            !shortsData['caption']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase().trim());
                      }).toList();

                      for (var key in keysToRemove) {
                        filteredShorts.remove(key);
                      }

                      currentShorts = filteredShorts;
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
                              currentShorts[shortsId]!['shortsThumbnail'];

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ShortsPageView(
                                    shorts: currentShorts,
                                    shortsId: shortsId,
                                    index: index,
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
                                    shortsThumbnail.toString().trim(),
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
