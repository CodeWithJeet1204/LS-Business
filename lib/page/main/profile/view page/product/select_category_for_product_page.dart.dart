import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/provider/change_category_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeCategory extends StatefulWidget {
  const ChangeCategory({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  State<ChangeCategory> createState() => _ChangeCategoryState();
}

class _ChangeCategoryState extends State<ChangeCategory> {
  final searchController = TextEditingController();
  bool isGridView = true;
  bool isAdding = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changeCategoryProvider = Provider.of<ChangeCategoryProvider>(context);
    final Stream<QuerySnapshot> allCategoryStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Category')
        .where(
          'vendorId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
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
          "SELECT CATEGORY",
        ),
        actions: [
          MyTextButton(
            onPressed: () async {
              setState(() {
                isAdding = true;
              });
              if (changeCategoryProvider.selectedCategory.isEmpty) {
                await FirebaseFirestore.instance
                    .collection('Business')
                    .doc('Data')
                    .collection('Products')
                    .doc(widget.productId)
                    .update({
                  'categoryId': '0',
                  'categoryName': 'No Category Selected',
                });
              } else {
                await FirebaseFirestore.instance
                    .collection('Business')
                    .doc('Data')
                    .collection('Products')
                    .doc(widget.productId)
                    .update({
                  'categoryId': changeCategoryProvider.selectedCategory[0],
                  'categoryName': changeCategoryProvider.selectedCategory[1],
                });
                changeCategoryProvider.selectedCategory.clear();
              }
              setState(() {
                isAdding = true;
              });
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            text: 'DONE',
            textColor: primaryDark2,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
              isAdding ? double.infinity : double.infinity, isAdding ? 90 : 80),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
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
              isAdding ? const LinearProgressIndicator() : Container(),
            ],
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
                return isGridView
                    ? GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          childAspectRatio: width * 0.5 / width * 1.75,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final categoryData = snapshot.data!.docs[index];
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedOverflowBox(
                              size: Size(width * 0.5, 210),
                              child: GestureDetector(
                                onTap: () {
                                  changeCategoryProvider.changeCategory(
                                    categoryData['categoryId'],
                                    categoryData['categoryName'],
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
                                            // IMAGE
                                            Center(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  categoryData['imageUrl'],
                                                  height: width * 0.4,
                                                  width: width * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                width * 0.02125,
                                                width * 0.012125,
                                                width * 0.0125,
                                                0,
                                              ),
                                              child: Text(
                                                categoryData['categoryName'],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: width * 0.055,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    changeCategoryProvider.selectedCategory
                                            .contains(
                                                categoryData['categoryId'])
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
                                              size: width * 0.09,
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
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
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.0166,
                                vertical: width * 0.0225,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  changeCategoryProvider.changeCategory(
                                    categoryData['categoryId'],
                                    categoryData['categoryName'],
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primary2.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.centerRight,
                                    children: [
                                      ListTile(
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.network(
                                            categoryData['imageUrl'],
                                            width: width * 0.14,
                                            height: width * 0.14,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        title: Text(
                                          categoryData['categoryName'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.05,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      changeCategoryProvider.selectedCategory
                                              .contains(
                                                  categoryData['categoryId'])
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
                                                size: width * 0.09,
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
              }

              return const Center(
                child: CircularProgressIndicator(
                  color: primaryDark,
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
