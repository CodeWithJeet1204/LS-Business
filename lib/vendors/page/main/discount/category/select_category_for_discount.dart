import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/provider/discount_category_provider.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  String? searchedCategory;
  bool isGridView = true;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
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

    final categoryData = categoriesData['householdCategoryData'];

    for (var shopType in shopTypes) {
      final shopTypeCategories = categoryData[shopType]!;

      shopTypeCategories.forEach((categoryName, categoryImageUrl) {
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
    final width = MediaQuery.of(context).size.width;

    final selectCategoryProvider =
        Provider.of<SelectCategoryForDiscountProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Select Categories',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          MyTextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'DONE',
          ),
        ],
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
                      if (value.isEmpty) {
                        currentCategories =
                            Map<String, Map<String, dynamic>>.from(
                          allCategories,
                        );
                      } else {
                        Map<String, Map<String, dynamic>> filteredCategories =
                            Map<String, Map<String, dynamic>>.from(
                          allCategories,
                        );
                        List<String> keysToRemove = [];

                        filteredCategories.forEach((key, categoryData) {
                          if (!key
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase().trim())) {
                            keysToRemove.add(key);
                          }
                        });

                        for (var key in keysToRemove) {
                          filteredCategories.remove(key);
                        }

                        currentCategories = filteredCategories;
                      }
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
                      physics: ClampingScrollPhysics(),
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
                      physics: ClampingScrollPhysics(),
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
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(width * 0.0125),
                child: LayoutBuilder(
                  builder: ((context, constraints) {
                    final width = constraints.maxWidth;

                    return SafeArea(
                      child: isGridView
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: 0.7375,
                              ),
                              itemCount: currentCategories.length,
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
                                                categoryName,
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
                          : SizedBox(
                              width: width,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: currentCategories.length,
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
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        margin: EdgeInsets.all(
                                          width * 0.0125,
                                        ),
                                        child: ListTile(
                                          visualDensity: VisualDensity.standard,
                                          onTap: () {
                                            selectCategoryProvider
                                                .selectCategory(
                                              categoryName,
                                            );
                                          },
                                          leading: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            child: Image.network(
                                              categoryImageUrl,
                                              width: width * 0.15,
                                              height: width * 0.15,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          title: Text(
                                            categoryName,
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
                  }),
                ),
              ),
            ),
    );
  }
}
