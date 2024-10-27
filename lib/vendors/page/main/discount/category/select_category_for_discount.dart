import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/provider/discount_category_provider.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/shimmer_skeleton_container.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class SelectCategoryForDiscountPage extends StatefulWidget {
  const SelectCategoryForDiscountPage({super.key});

  @override
  State<SelectCategoryForDiscountPage> createState() =>
      _SelectCategoryForDiscountPageState();
}

class _SelectCategoryForDiscountPageState
    extends State<SelectCategoryForDiscountPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Map<String, dynamic> allCategories = {};
  Map<String, dynamic> currentCategories = {};
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

      final vendorSnap = await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .get();

      final vendorData = vendorSnap.data()!;

      final List shopTypes = vendorData['Type'];

      final categoriesSnap = await store
          .collection('Shop Types And Category Data')
          .doc('Category Data')
          .get();

      final categoriesData = categoriesSnap.data()!;

      final householdCategoryData = categoriesData['householdCategoryData'];

      int addedCount = 0;
      total = 0;
      for (var shopType in shopTypes) {
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
    final width = MediaQuery.sizeOf(context).width;
    final selectCategoryProvider =
        Provider.of<SelectCategoryForDiscountProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Select Categories'),
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
                    autocorrect: false,
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    decoration: const InputDecoration(
                      hintText: 'Search ...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() async {
                        if (value.isEmpty) {
                          currentCategories =
                              Map<String, Map<String, dynamic>>.from(
                                  allCategories);
                        } else {
                          Map<String, Map<String, dynamic>> filteredCategories =
                              Map<String, Map<String, dynamic>>.from(
                                  allCategories);
                          List<String> keysToRemove = await Future.wait(
                            filteredCategories.entries.map((entry) async {
                              return !entry.key
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase().trim())
                                  ? entry.key
                                  : null;
                            }),
                          ).then(
                              (result) => result.whereType<String>().toList());

                          keysToRemove.forEach(filteredCategories.remove);
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
            )
          : currentCategories.isEmpty
              ? const SizedBox(
                  height: 80,
                  child: Center(
                    child: Text('No Categories'),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
                    child: LayoutBuilder(builder: (context, constraints) {
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
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: 0.7375,
                              ),
                              itemCount: noOfGridView > currentCategories.length
                                  ? currentCategories.length
                                  : noOfGridView,
                              itemBuilder: (context, index) {
                                final categoryName =
                                    currentCategories.keys.toList()[index];
                                final categoryImageUrl =
                                    currentCategories.values.toList()[index];

                                return GestureDetector(
                                  onTap: () {
                                    selectCategoryProvider.selectCategory(
                                      categoryName,
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
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(width * 0.00625),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
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
                                                          categoryImageUrl,
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
                                              child: Text(
                                                categoryName.toString().trim(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: width * 0.06,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      selectCategoryProvider.selectedCategories
                                              .contains(
                                        categoryName,
                                      )
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
                                                Icons.check,
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
                              physics: const ClampingScrollPhysics(),
                              itemCount: noOfListView > currentCategories.length
                                  ? currentCategories.length
                                  : noOfListView,
                              itemBuilder: ((context, index) {
                                final categoryName =
                                    currentCategories.keys.toList()[index];
                                final categoryImageUrl =
                                    currentCategories.values.toList()[index];

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
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      margin: EdgeInsets.all(
                                        width * 0.0125,
                                      ),
                                      child: ListTile(
                                        visualDensity: VisualDensity.standard,
                                        onTap: () {
                                          selectCategoryProvider.selectCategory(
                                            categoryName,
                                          );
                                        },
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          child: Image.network(
                                            categoryImageUrl.toString().trim(),
                                            width: width * 0.15,
                                            height: width * 0.15,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        title: Text(
                                          categoryName.toString().trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.05,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    selectCategoryProvider.selectedCategories
                                            .contains(
                                      categoryName,
                                    )
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                              right: width * 0.025,
                                            ),
                                            child: Container(
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
    );
  }
}
