import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/provider/select_brand_for_product_provider.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/shimmer_skeleton_container.dart';
import 'package:localy/widgets/text_button.dart';
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
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Map<String, Map<String, dynamic>> allBrands = {};
  Map<String, Map<String, dynamic>> currentBrands = {};
  final searchController = TextEditingController();
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
    Map<String, Map<String, dynamic>> myBrands = {};
    final brandSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (var brand in brandSnap.docs) {
      final brandId = brand.id;

      final brandData = brand.data();

      myBrands[brandId] = brandData;
    }

    setState(() {
      currentBrands = myBrands;
      allBrands = myBrands;
      isData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectBrandProvider =
        Provider.of<SelectBrandForProductProvider>(context);

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'SELECT BRANDS',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          MyTextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'NEXT',
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
                          currentBrands =
                              Map<String, Map<String, dynamic>>.from(
                            allBrands,
                          );
                        } else {
                          Map<String, Map<String, dynamic>> filteredBrands =
                              Map<String, Map<String, dynamic>>.from(
                            allBrands,
                          );
                          List<String> keysToRemove = [];

                          filteredBrands.forEach((key, brandData) {
                            if (!brandData['brandName']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase().trim())) {
                              keysToRemove.add(key);
                            }
                          });

                          for (var key in keysToRemove) {
                            filteredBrands.remove(key);
                          }

                          currentBrands = filteredBrands;
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
            )
          : currentBrands.isEmpty
              ? const Center(
                  child: Text('No Brands'),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.006125),
                    child: LayoutBuilder(
                      builder: ((context, constraints) {
                        final double width = constraints.maxWidth;

                        return isGridView
                            ? GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: currentBrands.length,
                                itemBuilder: ((context, index) {
                                  final brandData = currentBrands[
                                      currentBrands.keys.toList()[index]]!;

                                  return GestureDetector(
                                    onTap: () {
                                      selectBrandProvider.selectBrand(
                                        brandData['brandName'],
                                        brandData['brandId'],
                                      );
                                    },
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: primary2.withOpacity(0.125),
                                            border: Border.all(
                                              width: 0.25,
                                              color: primaryDark,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                          margin:
                                              EdgeInsets.all(width * 0.00625),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              brandData['imageUrl'] != null
                                                  ? Padding(
                                                      padding: EdgeInsets.all(
                                                        width * 0.0125,
                                                      ),
                                                      child: Center(
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            2,
                                                          ),
                                                          child: Image.network(
                                                            brandData[
                                                                'imageUrl'],
                                                            width: width * 0.5,
                                                            height: width * 0.5,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width: width,
                                                      height: width * 0.525,
                                                      child: const Center(
                                                        child: Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          'No Image',
                                                          style: TextStyle(
                                                            color: primaryDark2,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              const Divider(
                                                height: 0,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                  width * 0.0125,
                                                  width * 0.0125,
                                                  width * 0.0125,
                                                  0,
                                                ),
                                                child: SizedBox(
                                                  width: width * 0.5,
                                                  child: Text(
                                                    brandData['brandName'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: width * 0.06,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        selectBrandProvider.selectedBrandId ==
                                                brandData['brandId']
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
                                  );
                                }),
                              )
                            : SizedBox(
                                width: width,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: currentBrands.length,
                                  itemBuilder: ((context, index) {
                                    final brandData = currentBrands[
                                        currentBrands.keys.toList()[index]]!;

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
                                            visualDensity:
                                                VisualDensity.standard,
                                            onTap: () {
                                              selectBrandProvider.selectBrand(
                                                brandData['brandName'],
                                                brandData['brandId'],
                                              );
                                            },
                                            leading: brandData['imageUrl'] !=
                                                    null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      2,
                                                    ),
                                                    child: Image.network(
                                                      brandData['imageUrl'],
                                                      width: width * 0.15,
                                                      height: width * 0.15,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    width: width * 0.15,
                                                    height: width * 0.15,
                                                    child: const Center(
                                                      child: Text(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        'No Image',
                                                        style: TextStyle(
                                                          color: primaryDark2,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            title: Text(
                                              brandData['brandName'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: width * 0.06,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        selectBrandProvider.selectedBrandId ==
                                                brandData['brandId']
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
                                                    size: width * 0.1,
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    );
                                  }),
                                ),
                              );
                      }),
                    ),
                  ),
                ),
    );
  }
}
