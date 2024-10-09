import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ls_business/vendors/page/main/profile/view%20page/product/product_page.dart';
import 'package:ls_business/vendors/provider/change_category_provider.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class ChangeProductCategoryPage extends StatefulWidget {
  const ChangeProductCategoryPage({
    super.key,
    required this.productId,
    required this.shopTypes,
    required this.productName,
  });

  final String productId;
  final String productName;
  final List shopTypes;

  @override
  State<ChangeProductCategoryPage> createState() =>
      _ChangeProductCategoryPageState();
}

class _ChangeProductCategoryPageState extends State<ChangeProductCategoryPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  Map<String, dynamic> currentCategories = {};
  Map<String, dynamic> allCategories = {};
  bool isData = false;
  bool isGridView = true;
  bool isAdding = false;
  bool isDialog = false;

  // INIT STATE
  @override
  void initState() {
    getCategoriesData();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET CATEGORIES DATA
  Future<void> getCategoriesData() async {
    Map<String, dynamic> myCategories = {};

    final categoriesSnap = await store
        .collection('Shop Types And Category Data')
        .doc('Category Data')
        .get();

    final categoriesData = categoriesSnap.data()!;

    final householdCategoryData = categoriesData['householdCategoryData'];

    for (var shopType in widget.shopTypes) {
      final allShopTypesCategories = householdCategoryData[shopType]!;

      allShopTypesCategories.forEach((categoryName, categoryImageUrl) {
        myCategories[categoryName] = categoryImageUrl;
      });
    }

    setState(() {
      allCategories = myCategories;
      currentCategories = myCategories;
      isData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final changeCategoryProvider = Provider.of<ChangeCategoryProvider>(context);

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 0.5,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Select Category'),
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
                onPressed: () async {
                  setState(() {
                    isAdding = true;
                    isDialog = true;
                  });
                  if (changeCategoryProvider.selectedCategory.isEmpty) {
                    await store
                        .collection('Business')
                        .doc('Data')
                        .collection('Products')
                        .doc(widget.productId)
                        .update({
                      'categoryName': '0',
                    });
                  } else {
                    await store
                        .collection('Business')
                        .doc('Data')
                        .collection('Products')
                        .doc(widget.productId)
                        .update({
                      'categoryName': changeCategoryProvider.selectedCategory,
                    });
                    changeCategoryProvider.clear();
                  }
                  setState(() {
                    isAdding = false;
                    isDialog = false;
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductPage(
                          productId: widget.productId,
                          productName: widget.productId,
                        ),
                      ),
                    );
                  }
                  changeCategoryProvider.clear();
                },
                text: 'DONE',
                textColor: primaryDark2,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size(
                double.infinity,
                80,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: MediaQuery.sizeOf(context).width * 0.0225,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        autocorrect: false,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
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
          body: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;

            return !isData
                ? const Center(
                    child: CircularProgressIndicator(),
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
                        itemCount: currentCategories.length,
                        itemBuilder: (context, index) {
                          final id = currentCategories.keys.toList()[index];
                          final name = currentCategories.keys.toList()[index];
                          final imageUrl =
                              currentCategories.values.toList()[index];

                          return GestureDetector(
                            onTap: () {
                              changeCategoryProvider.changeCategory(
                                id,
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
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  margin: EdgeInsets.all(width * 0.00625),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // IMAGE
                                      Padding(
                                        padding: EdgeInsets.all(
                                          width * 0.00625,
                                        ),
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            child: Image.network(
                                              imageUrl.toString().trim(),
                                              height: width * 0.5,
                                              width: width * 0.5,
                                              fit: BoxFit.cover,
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
                                              fontSize: width * 0.06,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                changeCategoryProvider.selectedCategory == id
                                    ? Container(
                                        padding: EdgeInsets.all(
                                          width * 0.00625,
                                        ),
                                        margin: EdgeInsets.all(
                                          width * 0.01,
                                        ),
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
                          itemCount: currentCategories.length,
                          itemBuilder: ((context, index) {
                            final id = currentCategories.keys.toList()[index];
                            final name = currentCategories.keys.toList()[index];
                            final imageUrl =
                                currentCategories.values.toList()[index];

                            return GestureDetector(
                              onTap: () {
                                changeCategoryProvider.changeCategory(
                                  id,
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
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    ListTile(
                                      visualDensity: VisualDensity.standard,
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
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
                                    changeCategoryProvider.selectedCategory ==
                                            id
                                        ? Container(
                                            padding: EdgeInsets.all(
                                              width * 0.00625,
                                            ),
                                            margin: EdgeInsets.all(
                                              width * 0.01,
                                            ),
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
                              ),
                            );
                          }),
                        ),
                      );
          }),
        ),
      ),
    );
  }
}
