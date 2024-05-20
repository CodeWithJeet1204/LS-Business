import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/provider/discount_brand_provider.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/shimmer_skeleton_container.dart';
import 'package:localy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectBrandForDiscountPage extends StatefulWidget {
  const SelectBrandForDiscountPage({super.key});

  @override
  State<SelectBrandForDiscountPage> createState() =>
      _SelectBrandForDiscountPageState();
}

class _SelectBrandForDiscountPageState
    extends State<SelectBrandForDiscountPage> {
  bool isGridView = true;
  String? searchedBrand;

  @override
  Widget build(BuildContext context) {
    final selectBrandProvider =
        Provider.of<SelectBrandForDiscountProvider>(context);

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
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'SELECT BRANDS',
        ),
        actions: [
          MyTextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'DONE',
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
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    decoration: const InputDecoration(
                      hintText: 'Search ...',
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
                  tooltip: isGridView ? 'List View' : 'Grid View',
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
                        'Something went wrong',
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
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.795,
                              ),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final brandData = snapshot.data!.docs[index];
                                final brandDataMap =
                                    brandData.data() as Map<String, dynamic>;

                                // CARD
                                return GestureDetector(
                                  onTap: () {
                                    selectBrandProvider.selectBrands(
                                      brandDataMap['brandId'],
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
                                        margin: EdgeInsets.all(width * 0.00625),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(
                                                width * 0.00625,
                                              ),
                                              child: Center(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  child: Image.network(
                                                    brandData['imageUrl'],
                                                    width: width * 0.5,
                                                    height: width * 0.5,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                width * 0.0125,
                                                width * 0.0125,
                                                width * 0.0125,
                                                0,
                                              ),
                                              child: SizedBox(
                                                width: width * 0.275,
                                                child: Text(
                                                  brandData['brandName'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: width * 0.055,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      selectBrandProvider.selectedBrands
                                              .contains(
                                        brandDataMap['brandId'],
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
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: ((context, index) {
                                  final brandSnap = snapshot.data!.docs[index];
                                  final brandData =
                                      brandSnap.data() as Map<String, dynamic>;

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
                                            selectBrandProvider.selectBrands(
                                              brandData['brandId'],
                                            );
                                          },
                                          // leading: CachedNetworkImage(
                                          //   imageUrl: brandData['imageUrl'],
                                          //   imageBuilder:
                                          //       (context, imageProvider) {
                                          //     return ClipRRect(
                                          //       borderRadius:
                                          //           BorderRadius.circular(
                                          //         4,
                                          //       ),
                                          //       child: Container(
                                          //         width: width * 0.155,
                                          //         height: width * 0.175,
                                          //         decoration: BoxDecoration(
                                          //           image: DecorationImage(
                                          //             image: imageProvider,
                                          //             fit: BoxFit.cover,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     );
                                          //   },
                                          // ),
                                          leading: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            child: Image.network(
                                              brandData['imageUrl'],
                                              width: width * 0.15,
                                              height: width * 0.15,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          title: Text(
                                            brandSnap['brandName'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: width * 0.05,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      selectBrandProvider.selectedBrands
                                              .contains(
                                        brandData['brandId'],
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
