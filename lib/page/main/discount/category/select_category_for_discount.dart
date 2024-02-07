import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/provider/discount_category_provider.dart';
import 'package:find_easy/utils/colors.dart';
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
      appBar: AppBar(
        title: const Text("SELECT CATEGORIES"),
        actions: [
          MyTextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: "NEXT",
            textColor: primaryDark,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          final double width = constraints.maxWidth;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 8,
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
                        isGridView ? Icons.list : Icons.grid_view_rounded,
                      ),
                      tooltip: isGridView ? "List View" : "Grid View",
                    ),
                  ],
                ),
              ),
              StreamBuilder(
                stream: allCategoryStream,
                builder: ((context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Something went wrong"),
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
                                childAspectRatio: width * 0.5 / 230,
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
                                                      categoryData['imageUrl'],
                                                      height: 140,
                                                      width: 140,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 4, 4, 0),
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
                                        selectCategoryProvider
                                                .selectedCategories
                                                .contains(
                                          categoryDataMap['categoryId'],
                                        )
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
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
                                  final categoryDataMap = categoryData.data()
                                      as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 8,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: primary2.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ListTile(
                                            onTap: () {
                                              selectCategoryProvider
                                                  .selectCategory(
                                                categoryDataMap['categoryId'],
                                              );
                                            },
                                            leading: CircleAvatar(
                                              radius: 30,
                                              backgroundColor: primaryDark,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.network(
                                                  categoryData['imagesUrl'],
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
                                        selectCategoryProvider
                                                .selectedCategories
                                                .contains(
                                          categoryDataMap['categoryId'],
                                        )
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: Container(
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

                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryDark,
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
