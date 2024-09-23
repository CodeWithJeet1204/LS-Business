import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/provider/select_brand_for_product_provider.dart';
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

class SelectBrandForBulkProductsPage extends StatefulWidget {
  const SelectBrandForBulkProductsPage({super.key});

  @override
  State<SelectBrandForBulkProductsPage> createState() =>
      _SelectBrandForBulkProductsPageState();
}

class _SelectBrandForBulkProductsPageState
    extends State<SelectBrandForBulkProductsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isGridView = true;
  String? searchedBrand;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final selectBrandProvider =
        Provider.of<SelectBrandForProductProvider>(context);

    final Stream<QuerySnapshot> allBrandStream = store
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .where(
          'vendorId',
          isEqualTo: auth.currentUser!.uid,
        )
        .snapshots();

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
              Navigator.of(context).pop([
                selectBrandProvider.selectedBrandId,
                selectBrandProvider.selectedBrandName,
              ]);
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
                    autocorrect: false,
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    decoration: const InputDecoration(
                      hintText: 'Search ...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      searchedBrand = value;
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
      body: LayoutBuilder(
        builder: ((context, constraints) {
          final width = constraints.maxWidth;

          return Column(
            children: [
              StreamBuilder(
                stream: allBrandStream,
                builder: ((context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Something went wrong',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }

                  if (snapshot.hasData) {
                    final brandLength = snapshot.data!.docs.length;

                    if (brandLength == 0) {
                      return const SizedBox(
                        height: 80,
                        child: Center(
                          child: Text('No Brands'),
                        ),
                      );
                    }

                    return SafeArea(
                      child: isGridView
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final brandData = snapshot.data!.docs[index];
                                final brandDataMap =
                                    brandData.data() as Map<String, dynamic>;

                                return GestureDetector(
                                  onTap: () {
                                    selectBrandProvider.selectBrand(
                                      brandDataMap['brandName'],
                                      brandDataMap['brandId'],
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
                                        margin: EdgeInsets.all(width * 0.00625),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            brandData['imageUrl'] != null
                                                ? Padding(
                                                    padding: EdgeInsets.all(
                                                      width * 0.0125,
                                                    ),
                                                    child: Center(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          2,
                                                        ),
                                                        child: Image.network(
                                                          brandData['imageUrl'],
                                                          width: width * 0.5,
                                                          height: width * 0.5,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Column(
                                                    children: [
                                                      SizedBox(
                                                        width: width,
                                                        height: width * 0.375,
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
                                                      const Divider(),
                                                    ],
                                                  ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                width * 0.0125,
                                                width * 0.0125,
                                                width * 0.0125,
                                                0,
                                              ),
                                              child: SizedBox(
                                                width: width * 0.5,
                                                child: Text(
                                                  brandData['brandName'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: width * 0.06,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      selectBrandProvider.selectedBrandId ==
                                              brandDataMap['brandId']
                                          ? Container(
                                              margin: EdgeInsets.all(
                                                width * 0.01,
                                              ),
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
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
                          : SizedBox(
                              width: width,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: ((context, index) {
                                  final brandSnap = snapshot.data!.docs[index];
                                  final brandData =
                                      brandSnap.data() as Map<String, dynamic>;

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
                                          visualDensity: VisualDensity.standard,
                                          onTap: () {
                                            selectBrandProvider.selectBrand(
                                              brandData['brandName'],
                                              brandData['brandId'],
                                            );
                                          },
                                          leading: brandSnap['imageUrl'] != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    2,
                                                  ),
                                                  child: Image.network(
                                                    brandSnap['imageUrl'],
                                                    width: width * 0.15,
                                                    height: width * 0.15,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: width * 0.15,
                                                  height: width * 0.15,
                                                  child: const Center(
                                                    child: Text(
                                                      'No Image',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: primaryDark2,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          title: Text(
                                            brandSnap['brandName'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: width * 0.06,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      selectBrandProvider.selectedBrandId ==
                                              brandData['brandId']
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                right: width * 0.025,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
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
                              ),
                            ),
                    );
                  }

                  return SafeArea(
                    child: isGridView
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                            physics: const ClampingScrollPhysics(),
                            itemCount: 4,
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
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
