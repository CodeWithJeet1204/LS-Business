import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/models/common_categories.dart';
import 'package:find_easy/page/main/profile/view%20page/category/category_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/shimmer_skeleton_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({super.key});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  bool isGridView = true;
  String type = '';

  // INIT STATE
  @override
  void initState() {
    getShopType();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET SHOP TYOE
  void getShopType() async {
    final shopSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final shopData = shopSnap.data()!;

    setState(() {
      type = shopData['Type'];
    });
  }

  // DELETE
  void delete(String categoryId, String imageUrl) async {
    try {
      final postSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      for (final doc in postSnap.docs) {
        await doc.reference.update(
          {
            'categoryName': "No Category Selected",
            "categoryId": "0",
          },
        );
      }

      await storage.refFromURL(imageUrl).delete();

      await store
          .collection('Business')
          .doc('Data')
          .collection('Category')
          .doc(categoryId)
          .delete();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // CONFIRM DELETE
  confirmDelete(String categoryId, String imageUrl) {
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
            "Are you sure you want to delete this Category\nProducts will not be deleted",
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
                delete(categoryId, imageUrl);
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

  // DISPLAY COMMON CATEGORIES
  Future<Map<String, dynamic>?>? displayCommonCategories(int index) async {
    if (type != '') {
      final String subCategoryName = commonCategories[type]![index][0];

      // Get the document snapshot
      final DocumentSnapshot subSnapshot = await store
          .collection('Business')
          .doc('Data')
          .collection('Category')
          .doc(type)
          .collection(subCategoryName)
          .doc(auth.currentUser!.uid)
          .get();

      if (!subSnapshot.exists || subSnapshot.data() == null) {
        throw Exception('No data available for $subCategoryName');
      }

      return subSnapshot.data() as Map<String, dynamic>?;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> customCategoryStream = store
        .collection('Business')
        .doc('Data')
        .collection('Category')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .orderBy('categoryName')
        .where('categoryName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('categoryName', isLessThan: '${searchController.text}\uf8ff')
        .orderBy('datetime', descending: true)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          "ALL CATEGORIES",
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
      body: type != ''
          ? Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.0225,
              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double width = constraints.maxWidth;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        isGridView
                            ? GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                                itemBuilder: ((context, index) {
                                  return FutureBuilder(
                                    future: displayCommonCategories(index),
                                    builder: ((context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Text("Some error occured"),
                                        );
                                      }

                                      if (snapshot.hasData) {
                                        final categoryData = snapshot.data;

                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.01125,
                                            vertical: width * 0.0166,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: ((context) =>
                                                      CategoryPage(
                                                        categoryId:
                                                            categoryData[
                                                                'categoryId'],
                                                        categoryName: categoryData[
                                                            'subCategoryName'],
                                                      )),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    primary2.withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.0125,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Container(),
                                                    ),
                                                    CachedNetworkImage(
                                                      imageUrl: categoryData![
                                                          'imageUrl'],
                                                      imageBuilder: (context,
                                                          imageProvider) {
                                                        return Center(
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              12,
                                                            ),
                                                            child: Container(
                                                              width:
                                                                  width * 0.4,
                                                              height:
                                                                  width * 0.4,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image:
                                                                      imageProvider,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: width * 0.02,
                                                          ),
                                                          child: SizedBox(
                                                            width:
                                                                width * 0.275,
                                                            child: Text(
                                                              categoryData[
                                                                  'subCategoryName'],
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                color:
                                                                    primaryDark,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    width *
                                                                        0.06,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            confirmDelete(
                                                              categoryData[
                                                                  'categoryId'],
                                                              categoryData[
                                                                  'imageUrl'],
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
                                                    Expanded(
                                                      flex: 4,
                                                      child: Container(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
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
                                                  childAspectRatio:
                                                      width * 0.5 / width * 1.6,
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
                                    }),
                                  );
                                }),
                              )
                            : SizedBox(
                                width: width,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemBuilder: ((context, index) {
                                    return FutureBuilder(
                                      future: displayCommonCategories(index),
                                      builder: ((context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Center(
                                            child: Text("Some error occured"),
                                          );
                                        }

                                        if (snapshot.hasData) {
                                          final categoryData = snapshot.data!;

                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: width * 0.01,
                                              vertical: width * 0.025,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: ((context) =>
                                                        CategoryPage(
                                                          categoryId:
                                                              categoryData[
                                                                  'categoryId'],
                                                          categoryName:
                                                              categoryData[
                                                                  'categoryName'],
                                                        )),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      primary2.withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: ListTile(
                                                  leading: CachedNetworkImage(
                                                    imageUrl: categoryData[
                                                        'imageUrl'],
                                                    imageBuilder: (context,
                                                        imageProvider) {
                                                      return Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          vertical:
                                                              width * 0.0125,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          child: Container(
                                                            width:
                                                                width * 0.133,
                                                            height:
                                                                width * 0.133,
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  title: Text(
                                                    categoryData[
                                                        'categoryName'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.06,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                                                    childAspectRatio: width *
                                                        0.5 /
                                                        width *
                                                        1.6,
                                                  ),
                                                  itemCount: 4,
                                                  itemBuilder:
                                                      (context, index) {
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
                                                  itemBuilder:
                                                      (context, index) {
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
                                      }),
                                    );
                                  }),
                                ),
                              ),
                        StreamBuilder(
                          stream: customCategoryStream,
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
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
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 0,
                                        mainAxisSpacing: 0,
                                        childAspectRatio:
                                            width * 0.5 / width * 1.6,
                                      ),
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: ((context, index) {
                                        final categorySnap =
                                            snapshot.data!.docs[index];
                                        final Map<String, dynamic>
                                            categoryData = categorySnap.data();

                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.01125,
                                            vertical: width * 0.0166,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: ((context) =>
                                                      CategoryPage(
                                                        categoryId:
                                                            categoryData[
                                                                'categoryId'],
                                                        categoryName:
                                                            categoryData[
                                                                'categoryName'],
                                                      )),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    primary2.withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.0125,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Container(),
                                                    ),
                                                    CachedNetworkImage(
                                                      imageUrl: categoryData[
                                                          'imageUrl'],
                                                      imageBuilder: (context,
                                                          imageProvider) {
                                                        return Center(
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            child: Container(
                                                              width:
                                                                  width * 0.4,
                                                              height:
                                                                  width * 0.4,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image:
                                                                      imageProvider,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: width * 0.02,
                                                          ),
                                                          child: SizedBox(
                                                            width: width * 0.25,
                                                            child: Text(
                                                              categoryData[
                                                                  'categoryName'],
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                color:
                                                                    primaryDark,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    width *
                                                                        0.06,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            confirmDelete(
                                                              categoryData[
                                                                  'categoryId'],
                                                              categoryData[
                                                                  'imageUrl'],
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
                                                    Expanded(
                                                      flex: 4,
                                                      child: Container(),
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                                          final categoryData =
                                              snapshot.data!.docs[index];

                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: width * 0.01,
                                              vertical: width * 0.025,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: ((context) =>
                                                        CategoryPage(
                                                          categoryId:
                                                              categoryData[
                                                                  'categoryId'],
                                                          categoryName:
                                                              categoryData[
                                                                  'categoryName'],
                                                        )),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      primary2.withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: ListTile(
                                                  leading: CachedNetworkImage(
                                                    imageUrl: categoryData[
                                                        'imageUrl'],
                                                    imageBuilder: (context,
                                                        imageProvider) {
                                                      return Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          vertical:
                                                              width * 0.0125,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          child: Container(
                                                            width:
                                                                width * 0.133,
                                                            height:
                                                                width * 0.133,
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  title: Text(
                                                    categoryData[
                                                        'categoryName'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.06,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
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
                                        childAspectRatio:
                                            width * 0.5 / width * 1.6,
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
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
