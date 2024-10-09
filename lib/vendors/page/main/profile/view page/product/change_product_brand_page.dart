import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/page/main/profile/view%20page/product/product_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/shimmer_skeleton_container.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/video_tutorial.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class changeProductBrandPage extends StatefulWidget {
  const changeProductBrandPage({
    super.key,
    required this.productId,
    required this.productName,
    required this.currentBrandId,
  });

  final String productId;
  final String productName;
  final String currentBrandId;

  @override
  State<changeProductBrandPage> createState() => _changeProductBrandPageState();
}

class _changeProductBrandPageState extends State<changeProductBrandPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  Map<String, Map<String, dynamic>> allBrands = {};
  Map<String, Map<String, dynamic>> currentBrands = {};
  String? selectedBrandId;
  String? selectedBrandName;
  int? total;
  int noOfGridView = 8;
  bool isLoadMoreGridView = false;
  final scrollControllerGridView = ScrollController();
  int noOfListView = 20;
  bool isLoadMoreListView = false;
  final scrollControllerListView = ScrollController();
  bool isGridView = true;
  bool isData = false;
  bool isDialog = false;

  // INIT STATE
  @override
  void initState() {
    if (widget.currentBrandId != '0') {
      setState(() {
        selectedBrandId = widget.currentBrandId;
      });
    }
    getTotal();
    getBrandData();
    scrollControllerGridView.addListener(scrollListenerGridView);
    scrollControllerListView.addListener(scrollListenerListView);
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    scrollControllerGridView.dispose();
    scrollControllerListView.dispose();
    super.dispose();
  }

  // SCROLL LISTENER GRID VIEW
  Future<void> scrollListenerGridView() async {
    if (total != null && noOfGridView < total!) {
      if (scrollControllerGridView.position.pixels ==
          scrollControllerGridView.position.maxScrollExtent) {
        setState(() {
          isLoadMoreGridView = true;
        });
        noOfGridView = noOfGridView + 8;
        await getBrandData();
        setState(() {
          isLoadMoreGridView = false;
        });
      }
    }
  }

  // SCROLL LISTENER LIST VIEW
  Future<void> scrollListenerListView() async {
    if (total != null && noOfListView < total!) {
      if (scrollControllerListView.position.pixels ==
          scrollControllerListView.position.maxScrollExtent) {
        setState(() {
          isLoadMoreListView = true;
        });
        noOfListView = noOfListView + 12;
        await getBrandData();
        setState(() {
          isLoadMoreListView = false;
        });
      }
    }
  }

  // GET TOTAL
  Future<void> getTotal() async {
    final brandSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    final brandLength = brandSnap.docs.length;

    setState(() {
      total = brandLength;
    });
  }

  // GET BRAND DATA
  Future<void> getBrandData() async {
    Map<String, Map<String, dynamic>> myBrands = {};
    final brandSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .limit(isGridView ? noOfGridView : noOfListView)
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
    final width = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        opacity: 0.5,
        color: primaryDark,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Select Brand'),
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
                    isDialog = true;
                  });
                  try {
                    print('selectedBrandId: $selectedBrandId');
                    print('selectedBrandName: $selectedBrandName');
                    await store
                        .collection('Business')
                        .doc('Data')
                        .collection('Products')
                        .doc(widget.productId)
                        .update({
                      'productBrandId': selectedBrandId ?? '0',
                      'productBrand': selectedBrandName ?? 'No Brand',
                    });
                    setState(() {
                      isDialog = false;
                    });
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductPage(
                          productId: widget.productId,
                          productName: widget.productName,
                        ),
                      ),
                    );
                  } catch (e) {
                    setState(() {
                      isDialog = false;
                    });
                    mySnackBar(context, e.toString());
                  }
                },
                text: 'DONE',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size(width, 80),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.0166,
                  vertical: width * 0.0225,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SEARCH
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
                                    .contains(value
                                        .toLowerCase()
                                        .toString()
                                        .trim())) {
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
                          physics: const ClampingScrollPhysics(),
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
                          physics: const ClampingScrollPhysics(),
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
                  ? const SizedBox(
                      height: 80,
                      child: Center(
                        child: Text('No Brands'),
                      ),
                    )
                  : SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.006125),
                        child: LayoutBuilder(builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final height = constraints.maxHeight;

                          return isGridView
                              ? GridView.builder(
                                  controller: scrollControllerGridView,
                                  cacheExtent: height * 1.5,
                                  addAutomaticKeepAlives: true,
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                  ),
                                  itemCount: noOfGridView > currentBrands.length
                                      ? currentBrands.length
                                      : noOfGridView,
                                  itemBuilder: ((context, index) {
                                    final brandData = currentBrands[
                                        currentBrands.keys.toList()[index]]!;
                                    final brandId = brandData['brandId'];
                                    final brandName = brandData['brandName'];

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedBrandId = brandId;
                                          selectedBrandName = brandName;
                                        });
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
                                                            child:
                                                                Image.network(
                                                              brandData[
                                                                      'imageUrl']
                                                                  .trim(),
                                                              width:
                                                                  width * 0.5,
                                                              height:
                                                                  width * 0.5,
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
                                                            'No Image',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color:
                                                                  primaryDark2,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    width * 0.0125,
                                                    0,
                                                    width * 0.0125,
                                                    0,
                                                  ),
                                                  child: SizedBox(
                                                    width: width * 0.5,
                                                    child: Text(
                                                      brandName.trim(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                          selectedBrandId == brandId
                                              ? Container(
                                                  margin: EdgeInsets.all(
                                                    width * 0.01,
                                                  ),
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
                                                )
                                              : Container()
                                        ],
                                      ),
                                    );
                                  }),
                                )
                              : ListView.builder(
                                  controller: scrollControllerListView,
                                  cacheExtent: height * 1.5,
                                  addAutomaticKeepAlives: true,
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: noOfListView > currentBrands.length
                                      ? currentBrands.length
                                      : noOfListView,
                                  itemBuilder: ((context, index) {
                                    final brandData = currentBrands[
                                        currentBrands.keys.toList()[index]]!;
                                    final brandId = brandData['brandId'];
                                    final brandName = brandData['brandName'];

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
                                              setState(() {
                                                selectedBrandId = brandId;
                                                selectedBrandName = brandName;
                                              });
                                            },
                                            leading: brandData['imageUrl'] !=
                                                    null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      2,
                                                    ),
                                                    child: Image.network(
                                                      brandData['imageUrl']
                                                          .trim(),
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
                                                        'No Image',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: primaryDark2,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            title: Text(
                                              brandName.trim(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: width * 0.06,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        selectedBrandId == brandId
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
                                );
                        }),
                      ),
                    ),
        ),
      ),
    );
  }
}
