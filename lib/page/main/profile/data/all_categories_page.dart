import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/view%20page/category/category_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({super.key});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;
  bool isGridView = true;
  String? searchedCategory;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> categoryStream = store
        .collection('Business')
        .doc('Data')
        .collection('Category')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
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
                            autocorrect: false,
                            decoration: InputDecoration(
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

                                  return snapshot.data!.docs.length == 0
                                      ? Center(
                                          child: Text('No Categories Created'),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 6,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: ((context) =>
                                                      CategoryPage(
                                                        categoryId:
                                                            categoryData[
                                                                'categoryId'],
                                                        categoryName:
                                                            categoryData[
                                                                'categoryName'],
                                                      )),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    primary2.withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                              9),
                                                      child: Image.network(
                                                        categoryData[
                                                            'imageUrl'],
                                                        height: width * 0.4,
                                                        width: width * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(),
                                                    ),
                                                    Text(
                                                      categoryData[
                                                          'categoryName'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: primaryDark,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 20,
                                                      ),
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
                            : snapshot.data!.docs.length == 0
                                ? Center(
                                    child: Text('No Categories Created'),
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
                                                        categoryId:
                                                            categoryData[
                                                                'categoryId'],
                                                        categoryName:
                                                            categoryData[
                                                                'categoryName'],
                                                      )),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    primary2.withOpacity(0.5),
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






// import 'package:find_easy/utils/colors.dart';
// import 'package:flutter/material.dart';

// class CategoriesPage extends StatelessWidget {
//   const CategoriesPage({super.key});
//   final String categoryName = "Pens";
//   final int categoryItemsLength = 20;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: ListView.builder(
//         shrinkWrap: true,
//         itemCount: 21,
//         physics: ClampingScrollPhysics(),
//         itemBuilder: ((context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
//             child: ListTile(
//               tileColor: primary2,
//               leading: ClipRRect(
//                 borderRadius: BorderRadius.circular(9),
//                 child: Image.network(
//                   'https://yt3.googleusercontent.com/oSx8mAQ3_f9cvlml2wntk2_39M1DYXMDpSzLQOiK4sJOvypCMFjZ1gbiGQs62ZvRNClUN_14Ow=s900-c-k-c0x00ffffff-no-rj',
//                   height: 100,
//                   filterQuality: FilterQuality.none,
//                 ),
//               ),
//               title: Text(categoryName),
//               subtitle: Text(categoryItemsLength.toString()),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }