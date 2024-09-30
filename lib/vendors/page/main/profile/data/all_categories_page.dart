import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/page/main/profile/view%20page/category/category_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/shimmer_skeleton_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({
    super.key,
    required this.shopType,
  });

  final List shopType;

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  Map<String, dynamic> currentCategories = {};
  Map<String, dynamic> allCategories = {};
  Map<String, dynamic> everyCategories = {};
  int? total;
  int noOfGridView = 12;
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
    getCategoryData();
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
        await getCategoryData();
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
        await getCategoryData();
        setState(() {
          isLoadMoreListView = false;
        });
      }
    }
  }

  // GET CATEGORY DATA
  Future<void> getCategoryData() async {
    if (everyCategories.isEmpty) {
      Map<String, dynamic> myCategories = {};

      final categoriesSnap = await store
          .collection('Shop Types And Category Data')
          .doc('Category Data')
          .get();

      final categoriesData = categoriesSnap.data()!;

      final householdCategoryData = categoriesData['householdCategoryData'];

      int addedCount = 0;
      total = 0;
      for (var shopType in widget.shopType) {
        final categories = householdCategoryData[shopType]!;
        setState(() {
          total = total! + (categories.length as int);
          everyCategories.addAll(categories);
        });

        (categories as Map).forEach((categoryName, categoryImageUrl) {
          if (addedCount < (isGridView ? noOfGridView : noOfListView)) {
            myCategories[categoryName] = categoryImageUrl;
            addedCount++;
          } else {
            return;
          }
        });
      }

      addedCount = 0;
      for (var categoryName in myCategories.keys) {
        if (addedCount < (isGridView ? noOfGridView : noOfListView)) {
          currentCategories[categoryName] = myCategories[categoryName];
          allCategories[categoryName] = myCategories[categoryName];
          addedCount++;
        } else {
          break;
        }
      }

      setState(() {
        isData = true;
      });
    } else {
      int addedCount = 0;
      for (var categoryName in everyCategories.keys) {
        if (addedCount >= (isGridView ? noOfGridView : noOfListView)) {
          break;
        }
        if (!allCategories.containsKey(categoryName)) {
          currentCategories[categoryName] = everyCategories[categoryName];
          allCategories[categoryName] = everyCategories[categoryName];
          addedCount++;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('All Categories'),
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
        ],
        bottom: PreferredSize(
          preferredSize: Size(width, width * 0.2),
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
                          currentCategories = Map<String, dynamic>.from(
                            allCategories,
                          );
                        } else {
                          Map<String, dynamic> filteredCategories =
                              Map<String, dynamic>.from(
                            allCategories,
                          );
                          List<String> keysToRemove = [];

                          filteredCategories.forEach((key, imageUrl) {
                            if (!key
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                              keysToRemove.add(key);
                            }
                          });

                          for (var key in keysToRemove) {
                            filteredCategories.remove(key);
                          }

                          currentCategories = filteredCategories;
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
          : currentCategories.isEmpty
              ? const Center(
                  child: Text('No Categories'),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.0125,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxWidth;

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
                                  childAspectRatio: 0.75,
                                ),
                                itemCount:
                                    noOfGridView > currentCategories.length
                                        ? currentCategories.length
                                        : noOfGridView,
                                itemBuilder: ((context, index) {
                                  final name =
                                      currentCategories.keys.toList()[index];
                                  final imageUrl =
                                      currentCategories.values.toList()[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => CategoryPage(
                                            categoryName: name,
                                          ),
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
                                        borderRadius: BorderRadius.circular(
                                          2,
                                        ),
                                      ),
                                      margin: EdgeInsets.all(width * 0.00625),
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
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
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
                                                name.toString().trim(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: width * 0.05,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
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
                                itemCount:
                                    noOfListView > currentCategories.length
                                        ? currentCategories.length
                                        : noOfListView,
                                physics: const ClampingScrollPhysics(),
                                itemBuilder: ((context, index) {
                                  final name =
                                      currentCategories.keys.toList()[index];
                                  final imageUrl =
                                      currentCategories.values.toList()[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => CategoryPage(
                                            categoryName: name,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          child: Image.network(
                                            imageUrl.toString().trim(),
                                            width: width * 0.15,
                                            height: width * 0.15,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        title: Text(
                                          name.toString().trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.05,
                                            fontWeight: FontWeight.w500,
                                          ),
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
