import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Localsearch/vendors/page/register/business_choose_categories_page.dart';
import 'package:Localsearch/widgets/select_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class BusinessChooseShopTypesPage extends StatefulWidget {
  const BusinessChooseShopTypesPage({
    super.key,
    this.selectedShopTypes,
    required this.isEditing,
  });

  final bool isEditing;
  final List? selectedShopTypes;

  @override
  State<BusinessChooseShopTypesPage> createState() =>
      _BusinessChooseShopTypesPageState();
}

class _BusinessChooseShopTypesPageState
    extends State<BusinessChooseShopTypesPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Map<String, dynamic>? shopTypes;
  List selected = [];
  bool isNext = false;

  // INIT STATE
  @override
  void initState() {
    if (widget.selectedShopTypes != null) {
      setState(() {
        selected = widget.selectedShopTypes!;
      });
    }
    getShopTypes();
    super.initState();
  }

  // GET SHOP TYPES
  Future<void> getShopTypes() async {
    final shopTypesSnap = await store
        .collection('Shop Types And Category Data')
        .doc('Shop Types Data')
        .get();

    final shopTypesData = shopTypesSnap.data()!;

    final myShopTypes = shopTypesData['shopTypesData'];

    setState(() {
      shopTypes = myShopTypes;
    });
  }

  // NEXT
  Future<void> next() async {
    if (selected.isEmpty) {
      return mySnackBar(context, 'Select atleast one Type');
    }

    setState(() {
      isNext = true;
    });

    await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .update({
      'Type': selected,
    });

    setState(() {
      isNext = false;
    });

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) => BusinessChooseCategoriesPage(
                selectedTypes: selected,
                isEditing: widget.isEditing,
              )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Choose Your Type'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              BetterFeedback.of(context).show((feedback) async {
                Future<String> writeImageToStorage(
                    Uint8List feedbackScreenshot) async {
                  final Directory output = await getTemporaryDirectory();
                  final String screenshotFilePath =
                      '${output.path}/feedback.png';
                  final File screenshotFile = File(screenshotFilePath);
                  await screenshotFile.writeAsBytes(feedbackScreenshot);
                  return screenshotFilePath;
                }

                final screenshotFilePath =
                    await writeImageToStorage(feedback.screenshot);

                final Email email = Email(
                  body: feedback.text,
                  subject: 'Localsearch Feedback',
                  recipients: ['infinitylab1204@gmail.com'],
                  attachmentPaths: [screenshotFilePath],
                  isHTML: false,
                );
                await FlutterEmailSender.send(email);
              });
            },
            icon: const Icon(
              Icons.bug_report_outlined,
            ),
            tooltip: 'Report Problem',
          ),
        ],
      ),
      body: shopTypes == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
                child: LayoutBuilder(builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;

                  return SizedBox(
                    width: width,
                    height: height * 0.8875,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 16 / 9,
                      ),
                      itemCount: shopTypes!.length,
                      itemBuilder: (context, index) {
                        final name = shopTypes!.keys.toList()[index];
                        final imageUrl = shopTypes!.values.toList()[index];

                        return SelectContainer(
                          width: width,
                          text: name,
                          isSelected: selected.contains(name),
                          imageUrl: imageUrl,
                          onTap: () {
                            setState(() {
                              if (selected.contains(name)) {
                                selected.remove(name);
                              } else {
                                selected.add(name);
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await next();
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
