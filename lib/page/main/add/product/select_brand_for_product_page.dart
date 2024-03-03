import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/provider/select_brand_for_product_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/product_grid_view_skeleton.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectBrandForProductPage extends StatefulWidget {
  const SelectBrandForProductPage({super.key});

  @override
  State<SelectBrandForProductPage> createState() =>
      _SelectBrandForProductPageState();
}

class _SelectBrandForProductPageState extends State<SelectBrandForProductPage> {
  bool isGridView = true;
  String? searchedBrand;

  @override
  Widget build(BuildContext context) {
    final selectBrandProvider =
        Provider.of<SelectBrandForProductProvider>(context);

    final Stream<QuerySnapshot> allBrandStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .where(
          'vendorId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(overflow: TextOverflow.ellipsis, "SELECT BRANDS"),
        actions: [
          MyTextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: "NEXT",
            textColor: primaryDark,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            76,
          ),
          child: Padding(
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
                      searchedBrand = value;
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

          return Column(
            children: [
              StreamBuilder(
                stream: allBrandStream,
                builder: ((context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Something went wrong",
                        overflow: TextOverflow.ellipsis,
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
                                final brandData = snapshot.data!.docs[index];
                                final brandDataMap =
                                    brandData.data() as Map<String, dynamic>;
                                // CARD
                                return Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () {
                                      selectBrandProvider.selectBrand(
                                        brandDataMap['brandName'],
                                        brandDataMap['brandId'],
                                      );
                                    },
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
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
                                                      12,
                                                    ),
                                                    child: Image.network(
                                                      brandData['imageUrl'],
                                                      width: width * 0.4,
                                                      height: width * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    width * 0.025,
                                                    width * 0.0125,
                                                    width * 0.0125,
                                                    0,
                                                  ),
                                                  child: Text(
                                                    brandData['brandName'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: width * 0.06,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        selectBrandProvider.selectedBrandId ==
                                                brandDataMap['brandId']
                                            ? Container(
                                                margin: EdgeInsets.all(
                                                  width * 0.01,
                                                ),
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
                                  final brandData = snapshot.data!.docs[index];
                                  final brandDataMap =
                                      brandData.data() as Map<String, dynamic>;
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
                                              selectBrandProvider.selectBrand(
                                                brandDataMap['brandName'],
                                                brandDataMap['brandId'],
                                              );
                                            },
                                            leading: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: width * 0.01,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.network(
                                                  brandData['imageUrl'],
                                                  width: width * 0.155,
                                                  height: width * 0.166,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              brandData['brandName'],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: width * 0.055,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        selectBrandProvider.selectedBrandName ==
                                                brandDataMap['brandId']
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                  right: width * 0.025,
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: primaryDark2,
                                                  ),
                                                  child: Icon(
                                                    FeatherIcons.check,
                                                    color: Colors.white,
                                                    size: width * 0.095,
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                                  height: 30,
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
              ),
            ],
          );
        }),
      ),
    );
  }
}
