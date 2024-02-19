import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/view%20page/discount/discount_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/snack_bar.dart';
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
  final searchController = TextEditingController();
  bool isGridView = true;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // CONFIRMING TO DELETE
  void confirmDelete(String discountId, String? imageUrl) {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text("Confirm DELETE"),
          content: const Text(
              "Are you sure you want to delete this Discount\nDiscount will be removed from all the products/categories with this discount"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                delete(discountId, imageUrl);
              },
              child: const Text(
                'YES',
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
  void delete(String discountId, String? imageUrl) async {
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
      if (context.mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final discountStream = store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALL DISCOUNTS'),
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            80,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: "Case - Sensitive",
                      hintText: "Search ...",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {});
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
                    isGridView ? Icons.list : Icons.grid_view_rounded,
                  ),
                  tooltip: isGridView ? "List View" : "Grid View",
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;

            return StreamBuilder(
                stream: discountStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }

                  if (snapshot.hasData) {
                    return isGridView
                        ? GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 16 / 10,
                              mainAxisSpacing: 4,
                            ),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: ((context, index) {
                              final discountSnap = snapshot.data!.docs[index];
                              final discountData = discountSnap.data();

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
                                    color: primary2,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.0125,
                                      vertical: width * 0.0125,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // IMAGE
                                        discountData['discountImageUrl'] != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  discountData[
                                                      'discountImageUrl'],
                                                  width: width,
                                                  height: width * 0.4,
                                                  fit: BoxFit.cover,
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
                                                        "No Image Available",
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
                                                      padding: EdgeInsets.only(
                                                        left: width * 0.01,
                                                        top: width * 0.01,
                                                      ),
                                                      child: Text(
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
                                                      "  ●  ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w100,
                                                      ),
                                                    ),

                                                    // TIME
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left: width * 0.01,
                                                        top: width * 0.01,
                                                      ),
                                                      child: Text(
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
                                                                ? (discountData['discountEndDateTime']
                                                                                as Timestamp)
                                                                            .toDate()
                                                                            .difference(DateTime.now())
                                                                            .inHours <
                                                                        24
                                                                    ? '${(discountData['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours left'
                                                                    : '${(discountData['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days left'
                                                                : DateTime.now().difference((discountData['discountEndDateTime'] as Timestamp).toDate()).inHours < 24
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
                                                Icons.delete_forever_outlined,
                                                color: Colors.red,
                                                size: width * 0.1,
                                              ),
                                              tooltip: "End Discount",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: ((context, index) {
                              final discountSnap = snapshot.data!.docs[index];
                              final discountData = discountSnap.data();

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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  width: width,
                                  decoration: BoxDecoration(
                                    color: primary2,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    // IMAGE
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        discountData['discountImageUrl'],
                                        width: width / 5,
                                        height: width / 8.8875,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    // NAME
                                    title: Text(
                                      discountData['discountName'],
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontSize: width * 0.055,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    // DISCOUNT &  TIME
                                    subtitle: Row(
                                      children: [
                                        // DISCOUNT
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.01,
                                            top: width * 0.01,
                                          ),
                                          child: Text(
                                            discountData['isPercent']
                                                ? '${discountData['discountAmount']}% off'
                                                : 'Rs. ${discountData['discountAmount']} off',
                                            style: TextStyle(
                                              color: const Color.fromRGBO(
                                                  0, 72, 2, 1),
                                              fontSize: width * 0.035,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                        // DIVIDER
                                        const Text(
                                          "  ●  ",
                                          style: TextStyle(
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
                                            (discountData['discountStartDateTime']
                                                        as Timestamp)
                                                    .toDate()
                                                    .isAfter(DateTime.now())
                                                ? (discountData['discountStartDateTime']
                                                                as Timestamp)
                                                            .toDate()
                                                            .difference(
                                                                DateTime.now())
                                                            .inHours <
                                                        24
                                                    ? 'After ${(discountData['discountStartDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours'
                                                    : 'After ${(discountData['discountStartDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days'
                                                : (discountData['discountEndDateTime']
                                                            as Timestamp)
                                                        .toDate()
                                                        .isAfter(DateTime.now())
                                                    ? (discountData['discountEndDateTime']
                                                                    as Timestamp)
                                                                .toDate()
                                                                .difference(
                                                                    DateTime
                                                                        .now())
                                                                .inHours <
                                                            24
                                                        ? '${(discountData['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours left'
                                                        : '${(discountData['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days left'
                                                    : DateTime.now()
                                                                .difference(
                                                                    (discountData['discountEndDateTime']
                                                                            as Timestamp)
                                                                        .toDate())
                                                                .inHours <
                                                            24
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
                                      onPressed: () {
                                        confirmDelete(
                                          discountData['discountId'],
                                          discountData['discountImageUrl'],
                                        );
                                      },
                                      icon: Icon(
                                        Icons.delete_forever_outlined,
                                        color: Colors.red,
                                        size: width * 0.1,
                                      ),
                                      tooltip: "End Discount",
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
          }),
        ),
      ),
    );
  }
}
