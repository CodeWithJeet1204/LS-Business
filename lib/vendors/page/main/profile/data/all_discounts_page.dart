import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/profile/view%20page/discount/discount_page.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/shimmer_skeleton_container.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AllDiscountPage extends StatefulWidget {
  const AllDiscountPage({super.key});

  @override
  State<AllDiscountPage> createState() => _AllDiscountPageState();
}

class _AllDiscountPageState extends State<AllDiscountPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  Map<String, Map<String, dynamic>> allDiscounts = {};
  Map<String, Map<String, dynamic>> currentDiscounts = {};
  final searchController = TextEditingController();
  bool isGridView = true;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET DATA
  Future<void> getData() async {
    Map<String, Map<String, dynamic>> myDiscounts = {};
    final discountSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (var discount in discountSnap.docs) {
      final discountData = discount.data();

      final discountId = discount.id;

      myDiscounts[discountId] = discountData;
    }

    setState(() {
      currentDiscounts = myDiscounts;
      allDiscounts = myDiscounts;
      isData = true;
    });
  }

  // CONFIRMING DELETE
  Future<void> confirmDelete(String discountId, String? imageUrl) async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            'Confirm DELETE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          content: const Text(
            'Are you sure you want to delete this Discount\nDiscount will be removed from all the products/categories with this discount',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'NO',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await delete(discountId, imageUrl);
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AllDiscountPage()),
                  );
                }
              },
              child: const Text(
                'YES',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // DELETE DISCOUNT
  Future<void> delete(String discountId, String? imageUrl) async {
    try {
      if (imageUrl != null) {
        await storage.refFromURL(imageUrl).delete();
      }

      await store
          .collection('Business')
          .doc('Data')
          .collection('Discounts')
          .doc(discountId)
          .delete();
    } catch (e) {
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ALL DISCOUNTS',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: Size(
            width,
            width * 0.2,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.0166,
              vertical: width * 0.0225,
            ),
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
                          currentDiscounts =
                              Map<String, Map<String, dynamic>>.from(
                            allDiscounts,
                          );
                        } else {
                          Map<String, Map<String, dynamic>> filteredDiscounts =
                              Map<String, Map<String, dynamic>>.from(
                            allDiscounts,
                          );
                          List<String> keysToRemove = [];

                          filteredDiscounts.forEach((key, discountData) {
                            if (!discountData['discountName']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase().trim())) {
                              keysToRemove.add(key);
                            }
                          });

                          for (var key in keysToRemove) {
                            filteredDiscounts.remove(key);
                          }

                          currentDiscounts = filteredDiscounts;
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                        childAspectRatio: 14 / 9,
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
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(
                            width * 0.02,
                          ),
                          child: ListViewSkeleton(
                            width: width,
                            height: 30,
                            isPrice: true,
                            isDelete: true,
                          ),
                        );
                      },
                    ),
            )
          : currentDiscounts.isEmpty
              ? const Center(
                  child: Text('No Discounts'),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.006125),
                    child: LayoutBuilder(
                      builder: ((context, constraints) {
                        double width = constraints.maxWidth;

                        return isGridView
                            ? GridView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 16 / 10,
                                ),
                                itemCount: currentDiscounts.length,
                                itemBuilder: ((context, index) {
                                  final discountData = currentDiscounts[
                                      currentDiscounts.keys.toList()[index]]!;

                                  // DISCOUNT CONTAINER
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: ((context) => DiscountPage(
                                                discountId:
                                                    discountData['discountId'],
                                                discountImageUrl: discountData[
                                                    'discountImageUrl'],
                                              )),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: primary2.withOpacity(0.125),
                                        border: Border.all(
                                          width: 0.25,
                                          color: primaryDark,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      margin: EdgeInsets.all(width * 0.00625),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // IMAGE
                                          discountData['discountImageUrl'] !=
                                                  null
                                              // ? CachedNetworkImage(
                                              //     imageUrl: discountData[
                                              //         'discountImageUrl'],
                                              //     imageBuilder:
                                              //         (context, imageProvider) {
                                              //       return Center(
                                              //         child: ClipRRect(
                                              //           borderRadius:
                                              //               BorderRadius.circular(
                                              //             12,
                                              //           ),
                                              //           child: Container(
                                              //             width: width,
                                              //             height: width * 0.4,
                                              //             decoration: BoxDecoration(
                                              //               image: DecorationImage(
                                              //                 image: imageProvider,
                                              //                 fit: BoxFit.cover,
                                              //               ),
                                              //             ),
                                              //           ),
                                              //         ),
                                              //       );
                                              //     },
                                              //   )
                                              ? Padding(
                                                  padding: EdgeInsets.all(
                                                    width * 0.00625,
                                                  ),
                                                  child: Center(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      child: Image.network(
                                                        discountData[
                                                            'discountImageUrl'],
                                                        width: width,
                                                        height: width * 0.4125,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                )

                                              // NO IMAGE
                                              : Column(
                                                  children: [
                                                    SizedBox(
                                                      width: width,
                                                      height: width * 0.375,
                                                      child: const Center(
                                                        child: Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          'No Image',
                                                          style: TextStyle(
                                                            color: primaryDark2,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Divider(),
                                                  ],
                                                ),

                                          // INFO & OPTIONS
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // NAME & DISCOUNT + TIME
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // NAME
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      left: width * 0.01,
                                                      top: width * 0.01,
                                                    ),
                                                    child: Text(
                                                      discountData[
                                                          'discountName'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: primaryDark,
                                                        fontSize: width * 0.06,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),

                                                  // DISCOUNT & TIME
                                                  Row(
                                                    children: [
                                                      // DISCOUNT
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: width * 0.01,
                                                          top: width * 0.01,
                                                        ),
                                                        child: Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          discountData[
                                                                  'isPercent']
                                                              ? '${discountData['discountAmount']}% off'
                                                              : 'Rs. ${discountData['discountAmount']} off',
                                                          style: TextStyle(
                                                            color: const Color
                                                                .fromRGBO(
                                                              0,
                                                              72,
                                                              2,
                                                              1,
                                                            ),
                                                            fontSize:
                                                                width * 0.045,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),

                                                      // DIVIDER
                                                      const Text(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        '  ●  ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w100,
                                                        ),
                                                      ),

                                                      // TIME
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: width * 0.01,
                                                          top: width * 0.01,
                                                        ),
                                                        child: Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          (discountData['discountStartDateTime']
                                                                      as Timestamp)
                                                                  .toDate()
                                                                  .isAfter(
                                                                      DateTime
                                                                          .now())
                                                              ? (discountData['discountStartDateTime']
                                                                              as Timestamp)
                                                                          .toDate()
                                                                          .difference(DateTime
                                                                              .now())
                                                                          .inHours <
                                                                      24
                                                                  ? 'After ${(discountData['discountStartDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours'
                                                                  : 'After ${(discountData['discountStartDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days'
                                                              : (discountData['discountEndDateTime']
                                                                          as Timestamp)
                                                                      .toDate()
                                                                      .isAfter(
                                                                          DateTime
                                                                              .now())
                                                                  ? (discountData['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours <
                                                                          24
                                                                      ? '${(discountData['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours left'
                                                                      : '${(discountData['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days left'
                                                                  : DateTime.now()
                                                                              .difference((discountData['discountEndDateTime'] as Timestamp).toDate())
                                                                              .inHours <
                                                                          24
                                                                      ? 'Expired ${DateTime.now().difference((discountData['discountEndDateTime'] as Timestamp).toDate()).inHours} Hours Ago'
                                                                      : 'Expired ${DateTime.now().difference((discountData['discountEndDateTime'] as Timestamp).toDate()).inDays} Days Ago',
                                                          style: TextStyle(
                                                            color: const Color
                                                                .fromRGBO(
                                                              211,
                                                              80,
                                                              71,
                                                              1,
                                                            ),
                                                            fontSize:
                                                                width * 0.045,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  confirmDelete(
                                                    discountData['discountId'],
                                                    discountData[
                                                        'discountImageUrl'],
                                                  );
                                                },
                                                icon: Icon(
                                                  FeatherIcons.trash,
                                                  color: Colors.red,
                                                  size: width * 0.1,
                                                ),
                                                tooltip: 'End Discount',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              )
                            : SizedBox(
                                width: width,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: currentDiscounts.length,
                                  itemBuilder: ((context, index) {
                                    final discountData = currentDiscounts[
                                        currentDiscounts.keys.toList()[index]]!;

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: ((context) => DiscountPage(
                                                  discountId: discountData[
                                                      'discountId'],
                                                  discountImageUrl:
                                                      discountData[
                                                          'discountImageUrl'],
                                                )),
                                          ),
                                        );
                                      },
                                      child: Container(
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
                                          leading: discountData[
                                                      'discountImageUrl'] !=
                                                  null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    2,
                                                  ),
                                                  child: Image.network(
                                                    discountData[
                                                        'discountImageUrl'],
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      'No Image',
                                                      style: TextStyle(
                                                        color: primaryDark2,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                          // NAME
                                          title: Text(
                                            discountData['discountName'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: width * 0.05,
                                            ),
                                          ),

                                          // DISCOUNT &  TIME
                                          subtitle: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // DISCOUNT
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.01,
                                                  top: width * 0.01,
                                                ),
                                                child: Text(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  discountData['isPercent']
                                                      ? '${discountData['discountAmount']}% off'
                                                      : 'Rs. ${discountData['discountAmount']} off',
                                                  style: TextStyle(
                                                    color: const Color.fromRGBO(
                                                      0,
                                                      72,
                                                      2,
                                                      1,
                                                    ),
                                                    fontSize: width * 0.035,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),

                                              // DIVIDER
                                              const Text(
                                                ' ● ',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: primaryDark2,
                                                  fontWeight: FontWeight.w100,
                                                ),
                                              ),

                                              // TIME
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.01,
                                                  top: width * 0.01,
                                                ),
                                                child: Text(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  (discountData['discountStartDateTime']
                                                              as Timestamp)
                                                          .toDate()
                                                          .isAfter(
                                                              DateTime.now())
                                                      ? (discountData['discountStartDateTime']
                                                                      as Timestamp)
                                                                  .toDate()
                                                                  .difference(
                                                                      DateTime
                                                                          .now())
                                                                  .inHours <
                                                              24
                                                          ? 'After ${(discountData['discountStartDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours'
                                                          : 'After ${(discountData['discountStartDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days'
                                                      : (discountData['discountEndDateTime']
                                                                  as Timestamp)
                                                              .toDate()
                                                              .isAfter(DateTime
                                                                  .now())
                                                          ? (discountData['discountEndDateTime']
                                                                          as Timestamp)
                                                                      .toDate()
                                                                      .difference(
                                                                          DateTime.now())
                                                                      .inHours <
                                                                  24
                                                              ? '${(discountData['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours left'
                                                              : '${(discountData['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days left'
                                                          : DateTime.now().difference((discountData['discountEndDateTime'] as Timestamp).toDate()).inHours < 24
                                                              ? 'Expired ${DateTime.now().difference((discountData['discountEndDateTime'] as Timestamp).toDate()).inHours} Hours Ago'
                                                              : 'Expired ${DateTime.now().difference((discountData['discountEndDateTime'] as Timestamp).toDate()).inDays} Days Ago',
                                                  style: TextStyle(
                                                    color: const Color.fromRGBO(
                                                      211,
                                                      80,
                                                      71,
                                                      1,
                                                    ),
                                                    fontSize: width * 0.035,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // DELETE
                                          trailing: IconButton(
                                            onPressed: () async {
                                              await confirmDelete(
                                                discountData['discountId'],
                                                discountData[
                                                    'discountImageUrl'],
                                              );
                                            },
                                            icon: Icon(
                                              FeatherIcons.trash,
                                              color: Colors.red,
                                              size: width * 0.075,
                                            ),
                                            tooltip: 'Delete Discount',
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                      }),
                    ),
                  ),
                ),
    );
  }
}
