import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/vendors/page/main/profile/view%20page/brand/brand_page.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/shimmer_skeleton_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AllBrandPage extends StatefulWidget {
  const AllBrandPage({super.key});

  @override
  State<AllBrandPage> createState() => _AllBrandPageState();
}

class _AllBrandPageState extends State<AllBrandPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  bool isGridView = true;

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // DELETE
  Future<void> delete(String brandId, String? imageUrl) async {
    try {
      final productSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .where('vendorId', isEqualTo: auth.currentUser!.uid)
          .where('productBrandId', isEqualTo: brandId)
          .get();

      for (final doc in productSnap.docs) {
        await doc.reference.update(
          {
            'productBrand': "No Brand",
            "productBrandId": "0",
          },
        );
      }

      if (imageUrl != null) {
        await storage.refFromURL(imageUrl).delete();
      }

      await store
          .collection('Business')
          .doc('Data')
          .collection('Brands')
          .doc(brandId)
          .delete();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // CONFIRM DELETE
  confirmDelete(String brandId, String? imageUrl) {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            overflow: TextOverflow.ellipsis,
            "Confirm DELETE",
          ),
          content: const Text(
            overflow: TextOverflow.ellipsis,
            "Are you sure you want to delete this Brand\nProducts in this brand will be set as 'No Brand",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                overflow: TextOverflow.ellipsis,
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await delete(brandId, imageUrl);
              },
              child: const Text(
                overflow: TextOverflow.ellipsis,
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

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> brandStream = store
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .orderBy('brandName')
        .where('brandName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('brandName', isLessThan: '${searchController.text}\uf8ff')
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          "ALL BRANDS",
        ),
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            80,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.0166,
              vertical: MediaQuery.of(context).size.width * 0.0225,
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
                    isGridView ? FeatherIcons.list : FeatherIcons.grid,
                  ),
                  tooltip: isGridView ? "List View" : "Grid View",
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.0225,
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double width = constraints.maxWidth;

            return StreamBuilder(
              stream: brandStream,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      'Something went wrong',
                    ),
                  );
                }

                if (snapshot.hasData) {
                  return isGridView
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.725,
                          ),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            final brandSnap = snapshot.data!.docs[index];
                            final Map<String, dynamic> brandData =
                                brandSnap.data();

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: ((context) => BrandPage(
                                          brandId: brandData['brandId'],
                                          brandName: brandData['brandName'],
                                          imageUrl: brandData['imageUrl'],
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    brandData['imageUrl'] != null
                                        // ? CachedNetworkImage(
                                        //     imageUrl: brandData['imageUrl'],
                                        //     imageBuilder:
                                        //         (context, imageProvider) {
                                        //       return Center(
                                        //         child: ClipRRect(
                                        //           borderRadius:
                                        //               BorderRadius.circular(
                                        //             12,
                                        //           ),
                                        //           child: Container(
                                        //             width: width * 0.4,
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
                                              width * 0.0125,
                                            ),
                                            child: Center(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  2,
                                                ),
                                                child: Container(
                                                  width: width * 0.5,
                                                  height: width * 0.5,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        brandData['imageUrl'],
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    "No Image",
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.02,
                                          ),
                                          child: SizedBox(
                                            width: width * 0.275,
                                            child: Text(
                                              brandData['brandName'],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: primaryDark,
                                                fontWeight: FontWeight.w500,
                                                fontSize: width * 0.06,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            confirmDelete(
                                              brandData['brandId'],
                                              brandData['imageUrl'],
                                            );
                                          },
                                          icon: Icon(
                                            FeatherIcons.trash,
                                            color: Colors.red,
                                            size: width * 0.08,
                                          ),
                                          tooltip: "DELETE",
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
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: ((context, index) {
                              final brandData = snapshot.data!.docs[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: ((context) => BrandPage(
                                            brandId: brandData['brandId'],
                                            brandName: brandData['brandName'],
                                            imageUrl: brandData['imageUrl'],
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
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  margin: EdgeInsets.all(
                                    width * 0.0125,
                                  ),
                                  child: ListTile(
                                    visualDensity: VisualDensity.standard,
                                    leading: brandData['imageUrl'] != null
                                        // ? CachedNetworkImage(
                                        //     imageUrl: brandData['imageUrl'],
                                        //     imageBuilder:
                                        //         (context, imageProvider) {
                                        //       return ClipRRect(
                                        //         borderRadius:
                                        //             BorderRadius.circular(
                                        //           4,
                                        //         ),
                                        //         child: Container(
                                        //           width: width * 0.133,
                                        //           height: width * 0.133,
                                        //           decoration: BoxDecoration(
                                        //             image: DecorationImage(
                                        //               image: imageProvider,
                                        //               fit: BoxFit.cover,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       );
                                        //     },
                                        //   )
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            child: Image.network(
                                              brandData['imageUrl'],
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
                                                overflow: TextOverflow.ellipsis,
                                                'No Image',
                                                style: TextStyle(
                                                  color: primaryDark2,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                    title: Text(
                                      brandData['brandName'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: width * 0.06,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        confirmDelete(
                                          brandData['brandId'],
                                          brandData['imageUrl'],
                                        );
                                      },
                                      icon: Icon(
                                        FeatherIcons.trash,
                                        color: Colors.red,
                                        size: width * 0.075,
                                      ),
                                      tooltip: "DELETE",
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                }

                return SafeArea(
                  child: isGridView
                      ? GridView.builder(
                          shrinkWrap: true,
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
                                isPrice: false,
                                height: 30,
                                isDelete: true,
                              ),
                            );
                          },
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
