import 'package:Localsearch/vendors/page/main/add/product/add_product_page_3.dart';
import 'package:Localsearch/vendors/provider/add_product_provider.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class AddProductPage2 extends StatefulWidget {
  const AddProductPage2({super.key});

  @override
  State<AddProductPage2> createState() => _AddProductPage2State();
}

class _AddProductPage2State extends State<AddProductPage2> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  Map<String, dynamic> currentShopTypes = {};
  Map<String, dynamic> allShopTypes = {};
  String? selectedShopType;
  bool isShopTypeData = false;
  bool isGridView = true;

  // INIT STATE
  @override
  void initState() {
    getShopTypeData();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET SHOP TYPE DATA
  Future<void> getShopTypeData() async {
    Map<String, dynamic> myShopTypes = {};

    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final List shopType = vendorData['Type'];

    final shopTypeSnap = await store
        .collection('Shop Types And Category Data')
        .doc('Shop Types Data')
        .get();

    final shopTypesData = shopTypeSnap.data()!;

    final myAllShopTypes = shopTypesData['shopTypesData'];

    for (var type in shopType) {
      final shopTypeImageUrl = myAllShopTypes[type];

      myShopTypes[type] = shopTypeImageUrl;
    }

    setState(() {
      allShopTypes = myShopTypes;
      currentShopTypes = myShopTypes;
      isShopTypeData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Shop Type'),
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
          MyTextButton(
            onPressed: () {
              if (selectedShopType == null) {
                return mySnackBar(context, 'Select Shop Type');
              }
              final productProvider = Provider.of<AddProductProvider>(
                context,
                listen: false,
              );

              productProvider.add(
                {
                  'shopTypeName': selectedShopType,
                },
                true,
              );

              if (mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: ((context) => AddProductPage3(
                          shopType: selectedShopType!,
                        )),
                  ),
                );
              }
            },
            text: 'NEXT',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(width, 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                        currentShopTypes = Map<String, dynamic>.from(
                          allShopTypes,
                        );
                      } else {
                        Map<String, dynamic> filteredShopTypes =
                            Map<String, dynamic>.from(
                          allShopTypes,
                        );
                        List<String> keysToRemove = [];

                        filteredShopTypes.forEach((key, imageUrl) {
                          if (!key
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase())) {
                            keysToRemove.add(key);
                          }
                        });

                        for (var key in keysToRemove) {
                          filteredShopTypes.remove(key);
                        }

                        currentShopTypes = filteredShopTypes;
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return !isShopTypeData
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
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
              : currentShopTypes.isEmpty
                  ? const SizedBox(
                      height: 80,
                      child: Center(
                        child: Text('No Shop Types'),
                      ),
                    )
                  : isGridView
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: currentShopTypes.length,
                          itemBuilder: ((context, index) {
                            final shopTypeName =
                                currentShopTypes.keys.toList()[index];
                            final shopTypeImageUrl =
                                currentShopTypes.values.toList()[index];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedShopType != shopTypeName) {
                                    selectedShopType = shopTypeName;
                                  } else {
                                    selectedShopType = null;
                                  }
                                });
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
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    margin: EdgeInsets.all(
                                      width * 0.00625,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // CachedNetworkImage(
                                        //   imageUrl:
                                        //       shopTypeData[
                                        //           'imageUrl'],
                                        //   imageBuilder:
                                        //       (context,
                                        //           imageProvider) {
                                        //     return Center(
                                        //       child:
                                        //           ClipRRect(
                                        //         borderRadius:
                                        //             BorderRadius
                                        //                 .circular(
                                        //           12,
                                        //         ),
                                        //         child:
                                        //             Container(
                                        //           width: width *
                                        //               0.4,
                                        //           height: width *
                                        //               0.4,
                                        //           decoration:
                                        //               BoxDecoration(
                                        //             image:
                                        //                 DecorationImage(
                                        //               image:
                                        //                   imageProvider,
                                        //               fit:
                                        //                   BoxFit.cover,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     );
                                        //   },
                                        // ),
                                        Padding(
                                          padding: EdgeInsets.all(
                                            width * 0.0125,
                                          ),
                                          child: Center(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                2,
                                              ),
                                              child: Image.network(
                                                shopTypeImageUrl,
                                                width: width * 0.5,
                                                height: width * 0.5,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.02,
                                          ),
                                          child: Text(
                                            shopTypeName,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontWeight: FontWeight.w500,
                                              fontSize: width * 0.06,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  selectedShopType == shopTypeName
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            right: 4,
                                            top: 4,
                                          ),
                                          child: Container(
                                            width: width * 0.1125,
                                            height: width * 0.1125,
                                            decoration: const BoxDecoration(
                                              color: primaryDark,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              FeatherIcons.check,
                                              size: width * 0.08,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                            );
                          }),
                        )
                      : SizedBox(
                          width: width,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: currentShopTypes.length,
                            itemBuilder: ((context, index) {
                              final shopTypeName =
                                  currentShopTypes.keys.toList()[index];
                              final shopTypeImageUrl =
                                  currentShopTypes.values.toList()[index];

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selectedShopType != shopTypeName) {
                                      selectedShopType = shopTypeName;
                                    } else {
                                      selectedShopType = null;
                                    }
                                  });
                                },
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: white,
                                        border: Border.all(
                                          width: 0.5,
                                          color: primaryDark,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          2,
                                        ),
                                      ),
                                      margin: EdgeInsets.all(
                                        width * 0.0125,
                                      ),
                                      child: ListTile(
                                        visualDensity: VisualDensity.standard,
                                        // leading:
                                        //     CachedNetworkImage(
                                        //   imageUrl:
                                        //       shopTypeData[
                                        //           'imageUrl'],
                                        //   imageBuilder: (context,
                                        //       imageProvider) {
                                        //     return Padding(
                                        //       padding: EdgeInsets
                                        //           .symmetric(
                                        //         vertical:
                                        //             width *
                                        //                 0.0125,
                                        //       ),
                                        //       child:
                                        //           ClipRRect(
                                        //         borderRadius:
                                        //             BorderRadius
                                        //                 .circular(
                                        //           4,
                                        //         ),
                                        //         child:
                                        //             Container(
                                        //           width: width *
                                        //               0.133,
                                        //           height:
                                        //               width *
                                        //                   0.133,
                                        //           decoration:
                                        //               BoxDecoration(
                                        //             image:
                                        //                 DecorationImage(
                                        //               image:
                                        //                   imageProvider,
                                        //               fit: BoxFit
                                        //                   .cover,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     );
                                        //   },
                                        // ),
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          child: Image.network(
                                            shopTypeImageUrl,
                                            width: width * 0.15,
                                            height: width * 0.15,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        title: Text(
                                          shopTypeName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.05,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    selectedShopType == shopTypeName
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                              right: width * 0.033,
                                            ),
                                            child: Container(
                                              width: width * 0.125,
                                              height: width * 0.125,
                                              decoration: const BoxDecoration(
                                                color: primaryDark,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                size: width * 0.1,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              );
                            }),
                          ),
                        );
        },
      ),
    );
  }
}
