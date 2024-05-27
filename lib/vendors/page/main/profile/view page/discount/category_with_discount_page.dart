import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CategoryWithDiscountPage extends StatefulWidget {
  const CategoryWithDiscountPage({
    super.key,
    required this.discountId,
  });

  final String discountId;

  @override
  State<CategoryWithDiscountPage> createState() =>
      _CategoryWithDiscountPageState();
}

class _CategoryWithDiscountPageState extends State<CategoryWithDiscountPage> {
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  bool isGridView = true;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // CONFIRM REMOVE
  Future<void> confirmRemove(String categoryName) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            overflow: TextOverflow.ellipsis,
            'Remove $categoryName',
          ),
          content: Text(
            overflow: TextOverflow.ellipsis,
            'Are you sure you want to remove $categoryName from Discount?',
          ),
          actions: [
            MyTextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'NO',
              textColor: Colors.green,
            ),
            MyTextButton(
              onPressed: () async {
                await remove(categoryName);
              },
              text: 'YES',
              textColor: Colors.red,
            ),
          ],
        );
      },
    );
  }

  // REMOVE
  Future<void> remove(String categoryName) async {
    final discountData = await store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .doc(widget.discountId)
        .get();

    final List categories = discountData['categories'];

    await store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .doc(widget.discountId)
        .update({
      'categories': categories.remove(categoryName),
    });
  }

  @override
  Widget build(BuildContext context) {
    // GET DISCOUNT CATEGORY STREAM
    Stream<List<Map<String, String>>> discountCategoriesStream = store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .doc(widget.discountId)
        .snapshots()
        .map((snapshot) {
      final categoriesData = snapshot.data()?['categories'];
      if (categoriesData is List<Map<String, String>>) {
        return categoriesData;
      } else {
        return []; // Return an empty list if categories data is not present or not of the correct type
      }
    }).switchMap((categoryIds) => Rx.combineLatest(
              categoryIds.map((categoryId) => store
                  .collection('Business')
                  .doc('Data')
                  .collection('Category')
                  .doc(categoryId)
                  .snapshots()),
              (List<DocumentSnapshot<Map<String, dynamic>>> snapshots) =>
                  snapshots
                      .map((snapshot) => {
                            'categoryName': snapshot.id,
                            'categoryName':
                                snapshot.data()!['categoryName'] as String,
                            'imageUrl': snapshot.data()!['imageUrl'] as String,
                          })
                      .toList()
                      .cast<Map<String, String>>(),
            ));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'CATEGORIES',
        ),
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
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
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
                    isGridView ? Icons.list : Icons.grid_view_rounded,
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
          double width = constraints.maxWidth;

          return StreamBuilder(
            stream: discountCategoriesStream,
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    'Something went wrong',
                  ),
                );
              }

              if (snapshot.hasData) {
                final categories = snapshot.data!;
                return isGridView
                    ? GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: width / 415,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return categories[index]['categoryName']!
                                  .toLowerCase()
                                  .contains(searchController.text
                                      .toString()
                                      .toLowerCase())
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.01,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: primary2.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: width * 0.02,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              categories[index]['imageUrl']!,
                                              width: width * 0.45,
                                              height: width * 0.4,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.01,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: width * 0.45,
                                                height: width * 0.1,
                                                child: Text(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  categories[index]
                                                      ['categoryName']!,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: width * 0.06,
                                                    fontWeight: FontWeight.w500,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              // IconButton(
                                              //   onPressed: () {
                                              //     confirmRemove(
                                              //       categories[index]
                                              //           ['categoryName']!,
                                              //       categories[index]
                                              //           ['categoryName']!,
                                              //     );
                                              //   },
                                              //   icon: Icon(
                                              //     Icons
                                              //         .highlight_remove_outlined,
                                              //     color: Colors.red,
                                              //     size: width * 0.075,
                                              //   ),
                                              //   tooltip: 'Remove',
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container();
                        },
                      )
                    : SizedBox(
                        width: width,
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: width * 0.0225,
                                vertical: width * 0.02,
                              ),
                              width: width,
                              height: width * 0.2,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Padding(
                                  padding: EdgeInsets.only(
                                    top: width * 0.02,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      4,
                                    ),
                                    child: Image.network(
                                      categories[index]['imageUrl']!,
                                      width: width * 0.15,
                                      height: width * 0.15,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  categories[index]['categoryName']!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.0525,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
          );
        }),
      ),
    );
  }
}
