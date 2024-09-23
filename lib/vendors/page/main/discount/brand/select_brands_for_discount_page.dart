import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/provider/discount_brand_provider.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class SelectBrandForDiscountPage extends StatefulWidget {
  const SelectBrandForDiscountPage({super.key});

  @override
  State<SelectBrandForDiscountPage> createState() =>
      _SelectBrandForDiscountPageState();
}

class _SelectBrandForDiscountPageState
    extends State<SelectBrandForDiscountPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  Map<String, Map<String, dynamic>> currentBrands = {};
  Map<String, Map<String, dynamic>> allBrands = {};
  int? total;
  int noOfGridView = 8;
  bool isLoadMoreGridView = false;
  final scrollControllerGridView = ScrollController();
  int noOfListView = 20;
  bool isLoadMoreListView = false;
  final scrollControllerListView = ScrollController();
  bool isGridView = true;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getTotal();
    getBrandData();
    scrollControllerGridView.addListener(scrollListenerGridView);
    scrollControllerListView.addListener(scrollListenerListView);
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    scrollControllerGridView.dispose();
    scrollControllerListView.dispose();
    super.dispose();
  }

  // SCROLL LISTENER GRID VIEW
  Future<void> scrollListenerGridView() async {
    if (total != null && noOfGridView < total!) {
      if (scrollControllerGridView.position.pixels ==
          scrollControllerGridView.position.maxScrollExtent) {
        setState(() {
          isLoadMoreGridView = true;
        });
        noOfGridView = noOfGridView + 8;
        await getBrandData();
        setState(() {
          isLoadMoreGridView = false;
        });
      }
    }
  }

  // SCROLL LISTENER LIST VIEW
  Future<void> scrollListenerListView() async {
    if (total != null && noOfListView < total!) {
      if (scrollControllerListView.position.pixels ==
          scrollControllerListView.position.maxScrollExtent) {
        setState(() {
          isLoadMoreListView = true;
        });
        noOfListView = noOfListView + 12;
        await getBrandData();
        setState(() {
          isLoadMoreListView = false;
        });
      }
    }
  }

  // GET TOTAL
  Future<void> getTotal() async {
    final brandSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    final brandLength = brandSnap.docs.length;

    setState(() {
      total = brandLength;
    });
  }

  // GET BRAND DATA
  Future<void> getBrandData() async {
    Map<String, Map<String, dynamic>> myBrands = {};

    final brandSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .limit(isGridView ? noOfGridView : noOfListView)
        .get();

    for (var brand in brandSnap.docs) {
      final brandId = brand.id;

      final brandData = brand.data();

      myBrands[brandId] = brandData;
    }

    setState(() {
      currentBrands = myBrands;
      allBrands = myBrands;
      isData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final selectBrandProvider =
        Provider.of<SelectBrandForDiscountProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Select Brands',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
                  subject: 'Localsearch Feedback',
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
          MyTextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'DONE',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(width, 80),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.0166,
              vertical: width * 0.0225,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // SEARCH
                Expanded(
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
                          currentBrands =
                              Map<String, Map<String, dynamic>>.from(
                            allBrands,
                          );
                        } else {
                          Map<String, Map<String, dynamic>> filteredBrands =
                              Map<String, Map<String, dynamic>>.from(
                            allBrands,
                          );
                          List<String> keysToRemove = [];

                          filteredBrands.forEach((key, brandData) {
                            if (!brandData['brandName']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase().trim())) {
                              keysToRemove.add(key);
                            }
                          });

                          for (var key in keysToRemove) {
                            filteredBrands.remove(key);
                          }

                          currentBrands = filteredBrands;
                        }
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isGridView = !isGridView;
                    });
                  },
                  icon: Icon(
                    isGridView ? FeatherIcons.list : FeatherIcons.grid,
                  ),
                  tooltip: isGridView ? 'List View' : 'Grid View',
                ),
              ],
            ),
          ),
        ),
      ),
      body: !isData
          ? SafeArea(
              child: isGridView
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
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
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: 4,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(
                            width * 0.02,
                          ),
                          child: ListViewSkeleton(
                            width: width,
                            isPrice: false,
                            height: 30,
                          ),
                        );
                      },
                    ),
            )
          : currentBrands.isEmpty
              ? SizedBox(
                  height: 80,
                  child: const Center(
                    child: Text('No Brands'),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.006125),
                    child: LayoutBuilder(
                      builder: ((context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxHeight;

                        return SafeArea(
                          child: isGridView
                              ? GridView.builder(
                                  controller: scrollControllerGridView,
                                  cacheExtent: height * 1.5,
                                  addAutomaticKeepAlives: true,
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.775,
                                  ),
                                  itemCount: noOfGridView > currentBrands.length
                                      ? currentBrands.length
                                      : noOfGridView,
                                  itemBuilder: (context, index) {
                                    final brandData = currentBrands[
                                        currentBrands.keys.toList()[index]]!;

                                    // CARD
                                    return GestureDetector(
                                      onTap: () {
                                        selectBrandProvider.selectBrands(
                                          brandData['brandId'],
                                        );
                                      },
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: white,
                                              border: Border.all(
                                                width: 0.25,
                                                color: primaryDark,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            margin:
                                                EdgeInsets.all(width * 0.00625),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                brandData['imageUrl'] != null
                                                    ? Padding(
                                                        padding: EdgeInsets.all(
                                                          width * 0.006125,
                                                        ),
                                                        child: Center(
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              2,
                                                            ),
                                                            child:
                                                                Image.network(
                                                              brandData[
                                                                  'imageUrl'],
                                                              width:
                                                                  width * 0.5,
                                                              height:
                                                                  width * 0.5,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: width * 0.5125,
                                                        child: const Center(
                                                          child: Text(
                                                            'No Image',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color:
                                                                  primaryDark2,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    width * 0.0125,
                                                    0,
                                                    width * 0.0125,
                                                    0,
                                                  ),
                                                  child: Text(
                                                    brandData['brandName'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.055,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          selectBrandProvider.selectedBrands
                                                  .contains(
                                            brandData['brandId'],
                                          )
                                              ? Container(
                                                  margin: EdgeInsets.all(
                                                    width * 0.01,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: primaryDark2,
                                                  ),
                                                  child: Icon(
                                                    FeatherIcons.check,
                                                    color: Colors.white,
                                                    size: width * 0.1,
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    );
                                  })
                              : ListView.builder(
                                  controller: scrollControllerListView,
                                  cacheExtent: height * 1.5,
                                  addAutomaticKeepAlives: true,
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: noOfListView > currentBrands.length
                                      ? currentBrands.length
                                      : noOfListView,
                                  itemBuilder: (context, index) {
                                    final brandData = currentBrands[
                                        currentBrands.keys.toList()[index]]!;

                                    return Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: white,
                                            border: Border.all(
                                              width: 0.5,
                                              color: primaryDark,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                          margin: EdgeInsets.all(
                                            width * 0.0125,
                                          ),
                                          child: ListTile(
                                            visualDensity:
                                                VisualDensity.standard,
                                            onTap: () {
                                              selectBrandProvider.selectBrands(
                                                brandData['brandId'],
                                              );
                                            },
                                            // leading: CachedNetworkImage(
                                            //   imageUrl: brandData['imageUrl'],
                                            //   imageBuilder:
                                            //       (context, imageProvider) {
                                            //     return ClipRRect(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //         4,
                                            //       ),
                                            //       child: Container(
                                            //         width: width * 0.155,
                                            //         height: width * 0.175,
                                            //         decoration: BoxDecoration(
                                            //           image: DecorationImage(
                                            //             image: imageProvider,
                                            //             fit: BoxFit.cover,
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     );
                                            //   },
                                            // ),
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                2,
                                              ),
                                              child: Image.network(
                                                brandData['imageUrl'],
                                                width: width * 0.15,
                                                height: width * 0.15,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            title: Text(
                                              brandData['brandName'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: width * 0.05,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        selectBrandProvider.selectedBrands
                                                .contains(
                                          brandData['brandId'],
                                        )
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                  right: width * 0.025,
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: primaryDark2,
                                                  ),
                                                  child: Icon(
                                                    FeatherIcons.check,
                                                    color: Colors.white,
                                                    size: width * 0.1,
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    );
                                  }),
                        );
                      }),
                    ),
                  ),
                ),
    );
  }
}
