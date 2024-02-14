import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/view%20page/brand/brand_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AllBrandPage extends StatefulWidget {
  const AllBrandPage({super.key});

  @override
  State<AllBrandPage> createState() => _AllBrandPageState();
}

class _AllBrandPageState extends State<AllBrandPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  bool isGridView = true;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // DELETE
  void delete(String brandId, String? imageUrl) async {
    try {
      final productSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .where('vendorId', isEqualTo: auth.currentUser!.uid)
          .where('productBrandId', isEqualTo: brandId)
          .get();

      for (final doc in productSnap.docs) {
        await doc.reference.update(
          {
            'productBrand': "No Brand",
            "productBrandId": "0",
          },
        );
      }

      if (imageUrl != null) {
        await storage.refFromURL(imageUrl).delete();
      }

      await store
          .collection('Business')
          .doc('Data')
          .collection('Brands')
          .doc(brandId)
          .delete();

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // CONFIRM DELETE
  confirmDelete(String brandId, String? imageUrl) {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text("Confirm DELETE"),
          content: const Text(
            "Are you sure you want to delete this Brand\nProducts in this brand will be set as 'No Brand",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                delete(brandId, imageUrl);
              },
              child: const Text(
                'YES',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> brandStream = store
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .orderBy('brandName')
        .where('brandName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('brandName', isLessThan: '${searchController.text}\uf8ff')
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("ALL BRANDS"),
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            80,
          ),
          child: Padding(
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
                    isGridView ? Icons.list : Icons.grid_view_rounded,
                  ),
                  tooltip: isGridView ? "List View" : "Grid View",
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double width = constraints.maxWidth;

            return StreamBuilder(
              stream: brandStream,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }

                if (snapshot.hasData) {
                  return isGridView
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                            childAspectRatio: width * 0.5 / 230,
                          ),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            final brandSnap = snapshot.data!.docs[index];
                            final Map<String, dynamic> brandData =
                                brandSnap.data();

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 6,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: ((context) => BrandPage(
                                            brandId: brandData['brandId'],
                                            brandName: brandData['brandName'],
                                          )),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primary2.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.0125,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Container(),
                                        ),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                          child: Image.network(
                                            brandData['imageUrl'] ??
                                                'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                            height: width * 0.4,
                                            width: width * 0.4,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Container(),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: width * 0.02,
                                              ),
                                              child: SizedBox(
                                                width: width * 0.275,
                                                child: Text(
                                                  brandData['brandName'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: width * 0.06,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                confirmDelete(
                                                  brandData['brandId'],
                                                  brandData['imageUrl'],
                                                );
                                              },
                                              icon: Icon(
                                                Icons.delete_forever,
                                                color: Colors.red,
                                                size: width * 0.08,
                                              ),
                                              tooltip: "DELETE",
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        )
                      : SizedBox(
                          width: width,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: ((context, index) {
                              final brandData = snapshot.data!.docs[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.01,
                                  vertical: width * 0.025,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: ((context) => BrandPage(
                                              brandId: brandData['brandId'],
                                              brandName: brandData['brandName'],
                                            )),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: primary2.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          brandData['imageUrl'] ??
                                              'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                          width: width * 0.1175,
                                          height: width * 0.1175,
                                          fit: BoxFit.cover,
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
                                      trailing: IconButton(
                                        onPressed: () {
                                          confirmDelete(
                                            brandData['brandId'],
                                            brandData['imageUrl'],
                                          );
                                        },
                                        icon: Icon(
                                          Icons.delete_forever,
                                          color: Colors.red,
                                          size: width * 0.08,
                                        ),
                                        tooltip: "DELETE",
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
