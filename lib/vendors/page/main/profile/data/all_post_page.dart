import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/profile/view%20page/posts/post_page.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/shimmer_skeleton_container.dart';
import 'package:localy/widgets/snack_bar.dart';
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
  Map<String, Map<String, dynamic>> allPosts = {};
  Map<String, Map<String, dynamic>> currentPosts = {};
  bool isGridView = true;
  String? searchedProduct;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET DATA
  Future<void> getData() async {
    Map<String, Map<String, dynamic>> myPosts = {};

    final postsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Posts')
        .where('postVendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (var postData in postsSnap.docs) {
      final postId = postData.id;

      myPosts[postId] = postData.data();
    }

    setState(() {
      allPosts = myPosts;
      currentPosts = myPosts;
      isData = true;
    });
  }

  // DELETE POST
  Future<void> deletePost(String postId, bool isTextPost) async {
    try {
      int textPostRemaining = 0;
      int imagePostRemaining = 0;

      final productData = await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        textPostRemaining = productData['noOfTextPosts'];
        imagePostRemaining = productData['noOfImagePosts'];
      });

      await store
          .collection('Business')
          .doc('Data')
          .collection('Posts')
          .doc(postId)
          .delete();

      isTextPost
          ? await store
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
              'noOfTextPosts': textPostRemaining + 1,
            })
          : await store
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
              'noOfImagePosts': imagePostRemaining + 1,
            });

      if (mounted) {
        mySnackBar(context, 'Post Deleted');
      }
    } catch (e) {
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // CONFIRM DELETE
  Future<void> confirmDelete(String postId, bool isTextPost) async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            overflow: TextOverflow.ellipsis,
            'Confirm DELETE',
          ),
          content: const Text(
            overflow: TextOverflow.ellipsis,
            'Are you sure you want to delete this Post\nProduct of this post will not be deleted',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                overflow: TextOverflow.ellipsis,
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await deletePost(postId, isTextPost);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'YES',
                overflow: TextOverflow.ellipsis,
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
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'ALL POSTS',
        ),
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            80,
          ),
          child: Padding(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width * 0.0125,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autocorrect: false,
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    decoration: const InputDecoration(
                      labelText: 'Case - Sensitive',
                      hintText: 'Search ...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          currentPosts =
                              Map<String, Map<String, dynamic>>.from(allPosts);
                        } else {
                          Map<String, Map<String, dynamic>> filteredPosts =
                              Map<String, Map<String, dynamic>>.from(allPosts);
                          List<String> keysToRemove = [];

                          filteredPosts.forEach((key, postData) {
                            if (!postData['postProductName']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase().trim())) {
                              keysToRemove.add(key);
                            }
                          });

                          for (var key in keysToRemove) {
                            filteredPosts.remove(key);
                          }

                          currentPosts = filteredPosts;
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
                            isPrice: true,
                            isDelete: true,
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
                            isPrice: true,
                            height: 30,
                            isDelete: true,
                          ),
                        );
                      },
                    ),
            )
          : currentPosts.isEmpty
              ? const Center(
                  child: Text('No Posts'),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.0125,
                  ),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      double width = constraints.maxWidth;

                      return isGridView
                          ? GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.725,
                              ),
                              itemCount: currentPosts.length,
                              itemBuilder: ((context, index) {
                                final postData = currentPosts[
                                    currentPosts.keys.toList()[index]]!;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: ((context) => PostPage(
                                              postId: postData['postId'],
                                              productId:
                                                  postData['postProductId'],
                                              productName:
                                                  postData['postProductName'],
                                              categoryName:
                                                  postData['postCategoryName'],
                                            )),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: primary2.withOpacity(0.125),
                                      border: Border.all(
                                        width: 0.25,
                                        color: primaryDark,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    margin: EdgeInsets.all(width * 0.00625),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        postData['postProductImages'] != null
                                            // ? CachedNetworkImage(
                                            //     imageUrl:
                                            //         postData['postProductImages']
                                            //             [0],
                                            //     imageBuilder:
                                            //         (context, imageProvider) {
                                            //       return Center(
                                            //         child: ClipRRect(
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //             12,
                                            //           ),
                                            //           child: Container(
                                            //             width: width * 0.4125,
                                            //             height: width * 0.4125,
                                            //             decoration: BoxDecoration(
                                            //               image: DecorationImage(
                                            //                 image: imageProvider,
                                            //                 fit: BoxFit.cover,
                                            //               ),
                                            //             ),
                                            //           ),
                                            //         ),
                                            //       );
                                            //     },
                                            //   )
                                            ? Padding(
                                                padding: EdgeInsets.all(
                                                  width * 0.00625,
                                                ),
                                                child: Center(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                    child: Image.network(
                                                      postData[
                                                          'postProductImages'][0],
                                                      width: width * 0.5,
                                                      height: width * 0.5,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox(
                                                width: width * 0.5,
                                                height: width * 0.5,
                                                child: const Center(
                                                  child: Text(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    'No Image',
                                                    style: TextStyle(
                                                      color: primaryDark2,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    width * 0.025,
                                                    width * 0.0125,
                                                    width * 0.0125,
                                                    0,
                                                  ),
                                                  child: SizedBox(
                                                    width: width * 0.275,
                                                    child: Text(
                                                      postData[
                                                          'postProductName'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: width * 0.05,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    width * 0.025,
                                                    0,
                                                    width * 0.0125,
                                                    0,
                                                  ),
                                                  child: Text(
                                                    postData['postProductPrice'] !=
                                                                '' &&
                                                            postData[
                                                                    'postProductPrice'] !=
                                                                null
                                                        ? postData[
                                                            'postProductPrice']
                                                        : 'N/A',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: width * 0.045,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await confirmDelete(
                                                  postData['postId'],
                                                  postData['isTextPost'],
                                                );
                                              },
                                              icon: Icon(
                                                FeatherIcons.trash,
                                                color: Colors.red,
                                                size: width * 0.08,
                                              ),
                                              tooltip: 'Delete Post',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            )
                          : SizedBox(
                              width: width,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: currentPosts.length,
                                itemBuilder: ((context, index) {
                                  final postData = currentPosts[
                                      currentPosts.keys.toList()[index]]!;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: ((context) => PostPage(
                                                postId: postData['postId'],
                                                productId:
                                                    postData['postProductId'],
                                                productName:
                                                    postData['postProductName'],
                                                categoryName: postData[
                                                    'postCategoryName'],
                                              )),
                                        ),
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
                                      child: ListTile(
                                        visualDensity: VisualDensity.standard,
                                        leading: postData[
                                                    'postProductImages'] !=
                                                null
                                            // ? CachedNetworkImage(
                                            //     imageUrl:
                                            //         postData['postProductImages']
                                            //             [0],
                                            //     imageBuilder:
                                            //         (context, imageProvider) {
                                            //       return ClipRRect(
                                            //         borderRadius:
                                            //             BorderRadius.circular(
                                            //           2,
                                            //         ),
                                            //         child: Container(
                                            //           width: width * 0.15,
                                            //           height: width * 0.15,
                                            //           decoration: BoxDecoration(
                                            //             image: DecorationImage(
                                            //               image: imageProvider,
                                            //               fit: BoxFit.cover,
                                            //             ),
                                            //           ),
                                            //         ),
                                            //       );
                                            //     },
                                            //   )
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  2,
                                                ),
                                                child: Image.network(
                                                  postData['postProductImages']
                                                      [0],
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                          postData['postProductName'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.05,
                                          ),
                                        ),
                                        subtitle: Text(
                                          postData['postProductPrice'] != '' &&
                                                  postData[
                                                          'postProductPrice'] !=
                                                      null
                                              ? 'Rs. ${postData['postProductPrice']}'
                                              : 'N/A',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.045,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          onPressed: () async {
                                            await confirmDelete(
                                              postData['postId'],
                                              postData['isTextPost'],
                                            );
                                          },
                                          icon: Icon(
                                            FeatherIcons.trash,
                                            color: Colors.red,
                                            size: width * 0.075,
                                          ),
                                          tooltip: 'Delete Post',
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                    },
                  ),
                ),
    );
  }
}
