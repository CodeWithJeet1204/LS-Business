import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/view%20page/posts/post_page.dart';
import 'package:find_easy/page/main/profile/view%20page/product/product_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AllPostsPage extends StatefulWidget {
  const AllPostsPage({super.key});

  @override
  State<AllPostsPage> createState() => _AllPostsPageState();
}

class _AllPostsPageState extends State<AllPostsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  bool isGridView = true;
  String? searchedProduct;

  void deletePost(String postId) async {
    try {
      await store
          .collection('Business')
          .doc('Data')
          .collection('Posts')
          .doc(postId)
          .delete();
      mySnackBar(context, "Post Deleted");
    } catch (e) {
      mySnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final postStream = store
        .collection('Business')
        .doc('Data')
        .collection('Posts')
        .where('postVendorId', isEqualTo: auth.currentUser!.uid)
        .orderBy('postName')
        .where('postName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('postName',
            isLessThan: searchController.text.toString() + '\uf8ff')
        .orderBy('postDateTime', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('ALL POSTS'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          // double height = constraints.maxHeight;

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
                    stream: postStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(
                          child: Text('Something went wrong'),
                        );
                      }

                      if (snapshot.hasData) {
                        print("YES");
                        return isGridView
                            ? GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 3 / 4,
                                ),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: ((context, index) {
                                  final postSnap = snapshot.data!.docs[index];
                                  final Map<String, dynamic> postData =
                                      postSnap.data();
                                  print(postData);

                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: ((context) => PostPage(
                                                  postId: postData['postId'],
                                                )),
                                          ),
                                        );
                                      },
                                      child: Container(
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
                                                      BorderRadius.circular(12),
                                                  child: Image.network(
                                                    postData['postImages'] !=
                                                            null
                                                        ? postData['postImages']
                                                            [0]
                                                        : 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                                    height: 140,
                                                    width: 140,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                          8,
                                                          4,
                                                          4,
                                                          0,
                                                        ),
                                                        child: Text(
                                                          postData['postName'],
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                          8,
                                                          0,
                                                          4,
                                                          0,
                                                        ),
                                                        child: Text(
                                                          postData['postPrice'] !=
                                                                      "" &&
                                                                  postData[
                                                                          'postPrice'] !=
                                                                      null
                                                              ? postData[
                                                                  'postPrice']
                                                              : "N/A",
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      deletePost(
                                                        postData['postId'],
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.delete_forever,
                                                      color: Colors.red,
                                                      size: 32,
                                                    ),
                                                    tooltip: "Delete Post",
                                                  ),
                                                ],
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
                                    final postData = snapshot.data!.docs[index];
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
                                                  ProductPage(
                                                    productId: postData[
                                                        'postProductId'],
                                                    productName:
                                                        postData['postName'],
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
                                                postData['postImages'] != null
                                                    ? postData['postImages'][0]
                                                    : 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                                width: 45,
                                                height: 45,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            title: Text(
                                              postData['postName'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              postData['postPrice'] != "" &&
                                                      postData['postPrice'] !=
                                                          null
                                                  ? postData['postPrice']
                                                  : "N/A",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
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
                    }),
              ],
            ),
          );
        },
      ),
    );
  }
}
