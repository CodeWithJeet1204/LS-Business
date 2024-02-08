import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/provider/change_category_provider.dart';
import 'package:find_easy/utils/colors.dart';
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
        title: const Text("SELECT CATEGORY"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
            icon: isGridView
                ? const Icon(Icons.list)
                : const Icon(Icons.grid_view_rounded),
            tooltip: isGridView ? "List View" : "Grid View",
          ),
          IconButton(
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
            icon: const Icon(Icons.navigate_next),
            tooltip: "Continue",
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              Size(isAdding ? double.infinity : 0, isAdding ? 10 : 0),
          child: isAdding ? const LinearProgressIndicator() : Container(),
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
                  child: Text("Something went wrong"),
                );
              }

              if (snapshot.hasData) {
                return SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
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
                                isGridView
                                    ? Icons.list
                                    : Icons.grid_view_rounded,
                              ),
                              tooltip: isGridView ? "List View" : "Grid View",
                            ),
                          ],
                        ),
                      ),
                      isGridView
                          ? GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: width * 0.5 / 210,
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
                                            width: width * 0.5,
                                            decoration: BoxDecoration(
                                              color: primary2.withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 2),
                                                  Center(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: Image.network(
                                                        categoryData[
                                                            'imageUrl'],
                                                        height: 140,
                                                        width: 140,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 4, 4, 0),
                                                    child: Text(
                                                      categoryData[
                                                          'categoryName'],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          changeCategoryProvider
                                                  .selectedCategory
                                                  .contains(categoryData[
                                                      'categoryId'])
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: primaryDark2,
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 32,
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
                                  final categoryData =
                                      snapshot.data!.docs[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 8,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: primary2.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: primaryDark,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.network(
                                              categoryData['imageUrl'],
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          categoryData['categoryName'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                    ],
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
