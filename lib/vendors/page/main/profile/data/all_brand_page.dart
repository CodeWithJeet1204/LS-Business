import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/profile/view%20page/brand/brand_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
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
  Map<String, Map<String, dynamic>> allBrands = {};
  Map<String, Map<String, dynamic>> currentBrands = {};
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

  // CONFIRM DELETE
  Future<void> confirmDelete(String brandId, String? imageUrl) async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            'Confirm DELETE',
          ),
          content: const Text(
            'Are you sure you want to delete this Brand\nProducts in this brand will be set as \'No Brand\'',
          ),
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
                await delete(brandId, imageUrl);
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
            'productBrand': 'No Brand',
            'productBrandId': '0',
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'All Brands',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
                            isDelete: true,
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
                            isDelete: true,
                          ),
                        );
                      },
                    ),
            )
          : currentBrands.isEmpty
              ? const Center(
                  child: Text('No Brands'),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.006125),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxHeight;

                        return isGridView
                            ? GridView.builder(
                                controller: scrollControllerGridView,
                                cacheExtent: height * 1.5,
                                addAutomaticKeepAlives: true,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.725,
                                ),
                                itemCount: noOfGridView > currentBrands.length
                                    ? currentBrands.length
                                    : noOfGridView,
                                itemBuilder: ((context, index) {
                                  final brandData = currentBrands[
                                      currentBrands.keys.toList()[index]]!;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: ((context) => BrandPage(
                                                brandId: brandData['brandId'],
                                                brandName:
                                                    brandData['brandName'],
                                                imageUrl: brandData['imageUrl'],
                                              )),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: white,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        width * 0.006125,
                                                    vertical:
                                                        width * 0.00306125,
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
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                              brandData[
                                                                  'imageUrl'],
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: width * 0.5,
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
                                          Divider(
                                            height:
                                                brandData['imageUrl'] != null
                                                    ? 0
                                                    : 10,
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
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryDark,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: width * 0.06,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  await confirmDelete(
                                                    brandData['brandId'],
                                                    brandData['imageUrl'],
                                                  );
                                                  if (context.mounted) {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const AllBrandPage()),
                                                    );
                                                  }
                                                },
                                                icon: Icon(
                                                  FeatherIcons.trash,
                                                  color: Colors.red,
                                                  size: width * 0.08,
                                                ),
                                                tooltip: 'DELETE',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              )
                            : ListView.builder(
                                controller: scrollControllerListView,
                                cacheExtent: height * 1.5,
                                addAutomaticKeepAlives: true,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: noOfListView > currentBrands.length
                                    ? currentBrands.length
                                    : noOfListView,
                                itemBuilder: ((context, index) {
                                  final brandData = currentBrands[
                                      currentBrands.keys.toList()[index]]!;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: ((context) => BrandPage(
                                                brandId: brandData['brandId'],
                                                brandName:
                                                    brandData['brandName'],
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
                                          brandData['brandName'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.06,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          onPressed: () async {
                                            await confirmDelete(
                                              brandData['brandId'],
                                              brandData['imageUrl'],
                                            );
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const AllBrandPage()),
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            FeatherIcons.trash,
                                            color: Colors.red,
                                            size: width * 0.075,
                                          ),
                                          tooltip: 'DELETE',
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                      },
                    ),
                  ),
                ),
    );
  }
}
