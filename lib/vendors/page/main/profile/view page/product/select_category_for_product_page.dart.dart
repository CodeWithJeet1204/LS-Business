import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Localsearch/vendors/page/main/profile/view%20page/product/product_page.dart';
import 'package:Localsearch/vendors/provider/change_category_provider.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeCategory extends StatefulWidget {
  const ChangeCategory({
    super.key,
    required this.productId,
    required this.shopTypes,
    required this.productName,
  });

  final String productId;
  final String productName;
  final List shopTypes;

  @override
  State<ChangeCategory> createState() => _ChangeCategoryState();
}

class _ChangeCategoryState extends State<ChangeCategory> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  bool isGridView = true;
  bool isAdding = false;
  Map<String, dynamic> categories = {};
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

    for (var type in widget.shopTypes) {
      final specialSnapshot = await store
          .collection('Business')
          .doc('Special Categories')
          .collection(type)
          .get();

      for (var specialCategory in specialSnapshot.docs) {
        final specialCategoryData = specialCategory.data();

        final name = specialCategoryData['specialCategoryName'];
        final imageUrl = specialCategoryData['specialCategoryImageUrl'];

        myCategory[name] = imageUrl;
      }
    }

    setState(() {
      categories = myCategory;
      getData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final changeCategoryProvider = Provider.of<ChangeCategoryProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Select Category',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          MyTextButton(
            onPressed: () async {
              setState(() {
                isAdding = true;
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
          preferredSize: Size(
            double.infinity,
            isAdding ? 90 : 80,
          ),
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
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        decoration: const InputDecoration(
                          hintText: 'Search ...',
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
                      tooltip: isGridView ? 'List View' : 'Grid View',
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
          final width = constraints.maxWidth;

          return !getData
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : isGridView
                  ? GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: width * 0.75 / width,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final id = categories.keys.toList()[index];
                        final name = categories.keys.toList()[index];
                        final imageUrl = categories.values.toList()[index];

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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                            imageUrl,
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
                                          name,
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
                        itemCount: categories.length,
                        itemBuilder: ((context, index) {
                          final id = categories.keys.toList()[index];
                          final name = categories.keys.toList()[index];
                          final imageUrl = categories.values.toList()[index];

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
                                        imageUrl,
                                        width: width * 0.15,
                                        height: width * 0.15,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: width * 0.05,
                                        fontWeight: FontWeight.w500,
                                      ),
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
                            ),
                          );
                        }),
                      ),
                    );
        }),
      ),
    );
  }
}
