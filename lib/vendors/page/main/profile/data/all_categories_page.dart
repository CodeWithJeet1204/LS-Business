import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/profile/view%20page/category/category_page.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/shimmer_skeleton_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({
    super.key,
    required this.shopType,
  });

  final String shopType;

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  bool isGridView = true;
  Map<String, dynamic> currentCategories = {};
  Map<String, dynamic> allCategories = {};
  bool getData = false;

  // INIT STATE
  @override
  void initState() {
    getCommonCategories();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET COMMON CATEGORIES
  Future<void> getCommonCategories() async {
    Map<String, dynamic> myCategory = {};

    final specialSnapshot = await store
        .collection('Business')
        .doc('Special Categories')
        .collection(widget.shopType)
        .get();

    for (var specialCategory in specialSnapshot.docs) {
      final specialCategoryData = specialCategory.data();

      final name = specialCategoryData['specialCategoryName'];
      final imageUrl = specialCategoryData['specialCategoryImageUrl'];

      myCategory[name] = imageUrl;
    }

    setState(() {
      currentCategories = myCategory;
      allCategories = myCategory;
      getData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'ALL CATEGORIES',
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
                      labelText: 'Case - Sensitive',
                      hintText: 'Search ...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          currentCategories = Map<String, dynamic>.from(
                            allCategories,
                          );
                        } else {
                          print(111);
                          Map<String, dynamic> filteredCategories =
                              Map<String, dynamic>.from(
                            allCategories,
                          );
                          print(222);
                          List<String> keysToRemove = [];

                          filteredCategories.forEach((key, imageUrl) {
                            if (!key
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                              keysToRemove.add(key);
                            }
                          });
                          print(333);

                          keysToRemove.forEach((key) {
                            filteredCategories.remove(key);
                          });
                          print(555);

                          currentCategories = filteredCategories;
                        }
                        print(666);

                        print("All Posts: $allCategories");
                        print("Current Posts: $currentCategories");
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
      body: getData
          ? currentCategories.isEmpty
              ? SizedBox(
                  height: 60,
                  child: Center(
                    child: Text('No Categories'),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.0125,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double width = constraints.maxWidth;

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            isGridView
                                ? SizedBox(
                                    width: width,
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.75,
                                      ),
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: currentCategories.length,
                                      itemBuilder: ((context, index) {
                                        final name = currentCategories.keys
                                            .toList()[index];
                                        final imageUrl = currentCategories
                                            .values
                                            .toList()[index];

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: ((context) =>
                                                    CategoryPage(
                                                      categoryName: name,
                                                    )),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  primary2.withOpacity(0.125),
                                              border: Border.all(
                                                width: 0.25,
                                                color: primaryDark,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                2,
                                              ),
                                            ),
                                            margin:
                                                EdgeInsets.all(width * 0.00625),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // CachedNetworkImage(
                                                //   imageUrl: imageUrl,
                                                //   imageBuilder:
                                                //       (context, imageProvider) {
                                                //     return Center(
                                                //       child: ClipRRect(
                                                //         borderRadius:
                                                //             BorderRadius.circular(
                                                //           12,
                                                //         ),
                                                //         child: Container(
                                                //           width: width * 0.4,
                                                //           height: width * 0.4,
                                                //           decoration:
                                                //               BoxDecoration(
                                                //             image:
                                                //                 DecorationImage(
                                                //               image:
                                                //                   imageProvider,
                                                //               fit: BoxFit.cover,
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
                                                      child: Container(
                                                        width: width * 0.5,
                                                        height: width * 0.5,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                              imageUrl,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: width * 0.0125,
                                                  ),
                                                  child: SizedBox(
                                                    width: width * 0.5,
                                                    child: Text(
                                                      name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: width * 0.06,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  )
                                : getData
                                    ? SizedBox(
                                        width: width,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: currentCategories.length,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          itemBuilder: ((context, index) {
                                            final name = currentCategories.keys
                                                .toList()[index];
                                            final imageUrl = currentCategories
                                                .values
                                                .toList()[index];

                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: ((context) =>
                                                        CategoryPage(
                                                          categoryName: name,
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
                                                  visualDensity:
                                                      VisualDensity.standard,
                                                  // leading: CachedNetworkImage(
                                                  //   imageUrl: imageUrl,
                                                  //   imageBuilder:
                                                  //       (context, imageProvider) {
                                                  //     return Padding(
                                                  //       padding:
                                                  //           EdgeInsets.symmetric(
                                                  //         vertical:
                                                  //             width * 0.0125,
                                                  //       ),
                                                  //       child: ClipRRect(
                                                  //         borderRadius:
                                                  //             BorderRadius
                                                  //                 .circular(4),
                                                  //         child: Container(
                                                  //           width: width * 0.133,
                                                  //           height: width * 0.133,
                                                  //           decoration:
                                                  //               BoxDecoration(
                                                  //             image:
                                                  //                 DecorationImage(
                                                  //               image:
                                                  //                   imageProvider,
                                                  //               fit: BoxFit.cover,
                                                  //             ),
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
                                                      imageUrl,
                                                      width: width * 0.15,
                                                      height: width * 0.15,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.05,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      )
                                    : SafeArea(
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
                                      ),
                          ],
                        ),
                      );
                    },
                  ),
                )
          : SafeArea(
              child: isGridView
                  ? GridView.builder(
                      shrinkWrap: true,
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
            ),
    );
  }
}
