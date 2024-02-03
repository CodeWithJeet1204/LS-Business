import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/view%20page/category/category_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({super.key});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  bool isGridView = true;

  void delete(String categoryId, String imageUrl) async {
    try {
      final postSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      print("DONE 1");

      for (final doc in postSnap.docs) {
        await doc.reference.update(
          {
            'categoryName': "No Category Selected",
            "categoryId": "0",
          },
        );
      }

      print("DONE 2");

      await storage.refFromURL(imageUrl).delete();

      print("DONE 3");

      await store
          .collection('Business')
          .doc('Data')
          .collection('Category')
          .doc(categoryId)
          .delete();

      Navigator.of(context).pop();

      print("DONE 4");
    } catch (e) {
      mySnackBar(context, e.toString());
    }
  }

  // CONFIRM DELETE
  confirmDelete(String categoryId, String imageUrl) {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: Text("Confirm DELETE"),
          content: Text(
            "Are you sure you want to delete this Category\nProducts will not be deleted",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                delete(categoryId, imageUrl);
              },
              child: Text(
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
    final Stream<QuerySnapshot> categoryStream = store
        .collection('Business')
        .doc('Data')
        .collection('Category')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .orderBy('categoryName')
        .where('categoryName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('categoryName',
            isLessThan: searchController.text.toString() + '\uf8ff')
        .orderBy('datetime', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("ALL CATEGORIES"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double width = constraints.maxWidth;

            return SingleChildScrollView(
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
                            decoration: InputDecoration(
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
                  StreamBuilder(
                    stream: categoryStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasError) {
                        return Center(
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
                                  final categorySnap =
                                      snapshot.data!.docs[index];
                                  final Map<String, dynamic> categoryData =
                                      categorySnap.data();

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 6,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: ((context) => CategoryPage(
                                                  categoryId: categoryData[
                                                      'categoryId'],
                                                  categoryName: categoryData[
                                                      'categoryName'],
                                                )),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: primary2.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
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
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  9,
                                                ),
                                                child: Image.network(
                                                  categoryData['imageUrl'],
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    categoryData[
                                                        'categoryName'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: primaryDark,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      confirmDelete(
                                                        categoryData[
                                                            'categoryId'],
                                                        categoryData[
                                                            'imageUrl'],
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.delete_forever,
                                                      color: Colors.red,
                                                      size: 32,
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
                                    final categoryData =
                                        snapshot.data!.docs[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 8,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: ((context) =>
                                                  CategoryPage(
                                                    categoryId: categoryData[
                                                        'categoryId'],
                                                    categoryName: categoryData[
                                                        'categoryName'],
                                                  )),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: primary2.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ListTile(
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                categoryData['imageUrl'],
                                                width: 45,
                                                height: 45,
                                                fit: BoxFit.cover,
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
                                      ),
                                    );
                                  }),
                                ),
                              );
                      }

                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
