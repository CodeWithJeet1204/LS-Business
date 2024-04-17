import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/vendors/provider/discount_category_provider.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/shimmer_skeleton_container.dart';
import 'package:find_easy/widgets/text_button.dart';
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
  bool isGridView = true;
  String? searchedCategory;

  @override
  Widget build(BuildContext context) {
    final selectCategoryProvider =
        Provider.of<SelectCategoryForDiscountProvider>(context);

    final Stream<QuerySnapshot> allCategoryStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Category')
        .where(
          'vendorId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .orderBy('datetime', descending: true)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          "SELECT CATEGORIES",
        ),
        actions: [
          MyTextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: "DONE",
            textColor: primaryDark,
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
                    decoration: const InputDecoration(
                      hintText: "Search ...",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      searchedCategory = value;
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
      body: LayoutBuilder(
        builder: ((context, constraints) {
          final double width = constraints.maxWidth;

          return StreamBuilder(
            stream: allCategoryStream,
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    "Something went wrong",
                  ),
                );
              }

              if (snapshot.hasData) {
                return SafeArea(
                  child: isGridView
                      ? GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                            childAspectRatio: width * 0.5 / width * 1.725,
                          ),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final categoryData = snapshot.data!.docs[index];
                            final categoryDataMap =
                                categoryData.data() as Map<String, dynamic>;

                            // CARD
                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: GestureDetector(
                                onTap: () {
                                  selectCategoryProvider.selectCategory(
                                    categoryDataMap['categoryId'],
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: primary2.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 2),
                                            CachedNetworkImage(
                                              imageUrl:
                                                  categoryData['imageUrl'],
                                              imageBuilder:
                                                  (context, imageProvider) {
                                                return Center(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12,
                                                    ),
                                                    child: Container(
                                                      width: width * 0.4,
                                                      height: width * 0.4,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                width * 0.025,
                                                width * 0.0125,
                                                width * 0.0125,
                                                0,
                                              ),
                                              child: Text(
                                                categoryData['categoryName'],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: width * 0.06,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    selectCategoryProvider.selectedCategories
                                            .contains(
                                      categoryDataMap['categoryId'],
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
                              ),
                            );
                          })
                      : SizedBox(
                          width: width,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: ((context, index) {
                              final categoryData = snapshot.data!.docs[index];
                              final categoryDataMap =
                                  categoryData.data() as Map<String, dynamic>;
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.0166,
                                  vertical: width * 0.0225,
                                ),
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: primary2.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          selectCategoryProvider.selectCategory(
                                            categoryDataMap['categoryId'],
                                          );
                                        },
                                        leading: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: width * 0.0125,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: categoryData['imageUrl'],
                                            imageBuilder:
                                                (context, imageProvider) {
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  4,
                                                ),
                                                child: Container(
                                                  width: width * 0.155,
                                                  height: width * 0.166,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        title: Text(
                                          categoryData['categoryName'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.055,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    selectCategoryProvider.selectedCategories
                                            .contains(
                                      categoryDataMap['categoryId'],
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
                                ),
                              );
                            }),
                          ),
                        ),
                );
              }

              return SafeArea(
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
                            ),
                          );
                        },
                      ),
              );
            }),
          );
        }),
      ),
    );
  }
}
