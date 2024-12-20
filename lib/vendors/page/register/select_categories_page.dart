import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/page/register/select_products_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/select_container.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class SelectCategoriesPage extends StatefulWidget {
  const SelectCategoriesPage({
    super.key,
    required this.selectedTypes,
    required this.isEditing,
    this.selectedCategories,
  });

  final bool isEditing;
  final List selectedTypes;
  final List? selectedCategories;

  @override
  State<SelectCategoriesPage> createState() => _SelectCategoriesPageState();
}

class _SelectCategoriesPageState extends State<SelectCategoriesPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  List<String> selectedCategories = [];
  Map<String, bool> selectAll = {};
  Map<String, dynamic>? categories;
  String? expandedCategory;
  bool isDialog = false;

  // INIT STATE
  @override
  void initState() {
    getCategories();
    for (var selectedType in widget.selectedTypes) {
      selectAll.addAll({
        selectedType: false,
      });
    }
    super.initState();
  }

  // GET CATEGORIES
  Future<void> getCategories() async {
    final catalogueSnap = await store
        .collection('Shop Types And Category Data')
        .doc('Catalogue')
        .get();

    final catalogueData = catalogueSnap.data()!;

    final catalogue = catalogueData['catalogueData'];

    setState(() {
      categories = catalogue;
    });
  }

  // NEXT
  Future<void> next() async {
    if (selectedCategories.isEmpty) {
      return mySnackBar(context, 'Select Atleast One Category');
    }

    try {
      setState(() {
        isDialog = true;
      });

      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'Categories': selectedCategories,
      });

      setState(() {
        isDialog = false;
      });

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SelectProductsPage(
              selectedCategories: selectedCategories,
              selectedTypes: widget.selectedTypes,
              isEditing: widget.isEditing,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isDialog = false;
      });
      if (mounted) {
        mySnackBar(context, 'Some error occured');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        progressIndicator: const LoadingIndicator(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Select Categories'),
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
            ],
          ),
          body: categories == null
              ? const Center(
                  child: LoadingIndicator(),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
                    child: Column(
                      children: widget.selectedTypes.map((category) {
                        final categoryData =
                            categories![category.toString().trim()];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: width * 0.0125,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.8,
                                    child: Text(
                                      category.toString().trim(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value: selectAll[category.toString().trim()],
                                  onChanged: (value) {
                                    setState(() {
                                      selectAll[category.toString().trim()] =
                                          !selectAll[
                                              category.toString().trim()]!;
                                    });
                                    if (selectAll[
                                        category.toString().trim()]!) {
                                      for (var entry
                                          in categoryData!.entries.toList()) {
                                        if (!selectedCategories
                                            .contains(entry.key)) {
                                          selectedCategories.add(entry.key);
                                        }
                                      }
                                    } else {
                                      for (var entry
                                          in categoryData!.entries.toList()) {
                                        if (selectedCategories
                                            .contains(entry.key)) {
                                          selectedCategories.remove(entry.key);
                                        }
                                      }
                                    }
                                  },
                                  activeColor: primaryDark,
                                  checkColor: primary2,
                                ),
                              ],
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 16 / 9,
                              ),
                              itemCount: categoryData?.length ?? 0,
                              itemBuilder: (context, index) {
                                final entry =
                                    categoryData!.entries.toList()[index];
                                final category = entry.key;

                                return SelectContainer(
                                  width: width,
                                  text: category,
                                  isSelected:
                                      selectedCategories.contains(category),
                                  onTap: () {
                                    setState(() {
                                      if (selectedCategories
                                          .contains(category)) {
                                        selectedCategories.remove(category);
                                      } else {
                                        selectedCategories.add(category);
                                      }
                                    });
                                  },
                                  imageUrl: null,
                                );
                              },
                            ),
                            const Divider(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await next();
            },
            child: const Icon(Icons.arrow_forward),
          ),
        ),
      ),
    );
  }
}
