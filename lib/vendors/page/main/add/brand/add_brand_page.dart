import 'dart:io';
import 'package:Localsearch/widgets/show_loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/add/brand/select_products_for_brand_page.dart';
import 'package:Localsearch/vendors/provider/products_added_to_brand.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/my_button.dart';
import 'package:Localsearch/widgets/image_pick_dialog.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:Localsearch/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class AddBrandPage extends StatefulWidget {
  const AddBrandPage({super.key});

  @override
  State<AddBrandPage> createState() => _AddBrandPageState();
}

class _AddBrandPageState extends State<AddBrandPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final brandKey = GlobalKey<FormState>();
  final brandNameController = TextEditingController();
  bool isSaving = false;
  File? _image;
  String? imageUrl;

  // DISPOSE
  @override
  void dispose() {
    brandNameController.dispose();
    super.dispose();
  }

  // REMOVE CATEGORY IMAGE
  void removeImage() {
    setState(() {
      _image = null;
    });
  }

  // SELECT CATEGORY IMAGE
  Future<void> selectImage() async {
    final images = await showImagePickDialog(context, true);
    if (images.isNotEmpty) {
      final im = images[0];
      setState(() {
        _image = (File(im.path));
      });
    }
  }

  Future<void> addBrand(ProductAddedToBrandProvider provider) async {
    if (brandKey.currentState!.validate()) {
      try {
        setState(() {
          isSaving = true;
        });

        bool brandDoesntExists = true;
        final previousProducts = await store
            .collection('Business')
            .doc('Data')
            .collection('Brands')
            .where('vendorId', isEqualTo: auth.currentUser!.uid)
            .get();

        for (QueryDocumentSnapshot doc in previousProducts.docs) {
          if (doc['brandName'] == brandNameController.text.toString()) {
            if (mounted) {
              mySnackBar(
                context,
                'Product with same name already exists',
              );
            }
            brandDoesntExists = false;
          }
        }

        if (brandDoesntExists) {
          final String brandId = const Uuid().v4();
          if (_image != null) {
            Reference ref = storage.ref().child('Vendor/Brand').child(brandId);

            await ref.putFile(_image!).whenComplete(() async {
              await ref.getDownloadURL().then((value) {
                setState(() {
                  imageUrl = value;
                });
              });
            });
          }

          await store
              .collection('Business')
              .doc('Data')
              .collection('Brands')
              .doc(brandId)
              .set({
            'brandId': brandId,
            'brandName': brandNameController.text.toString(),
            'imageUrl': imageUrl,
            'vendorId': auth.currentUser!.uid,
          });
          if (mounted) {
            mySnackBar(context, 'Brand Added');
          }

          for (String id in provider.selectedProducts) {
            await store
                .collection('Business')
                .doc('Data')
                .collection('Products')
                .doc(id)
                .update({
              'productBrandId': brandId,
              'productBrand': brandNameController.text..toString(),
            });
          }

          provider.clearProducts();
          setState(() {
            isSaving = false;
          });
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          if (mounted) {
            return mySnackBar(context, 'Brand with same name alreadye exists!');
          }
        }
      } catch (e) {
        setState(() {
          isSaving = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAddedToBrandProvider =
        Provider.of<ProductAddedToBrandProvider>(context);

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text(
          'ADD BRAND',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
                  subject: 'LS Business Feedback',
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
          MyTextButton(
            onPressed: () async {
              await showLoadingDialog(
                context,
                () async {
                  await addBrand(
                    productsAddedToBrandProvider,
                  );
                },
              );
            },
            text: 'DONE',
            textColor: primaryDark2,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.0125,
        ),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Form(
                key: brandKey,
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    // IMAGE
                    _image != null
                        ? Center(
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                // NOT NULL
                                Container(
                                  height: width,
                                  width: width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: primaryDark,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image(
                                      image: FileImage(_image!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // ICONS
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Padding(
                                    //   padding: EdgeInsets.all(width * 0.0125),
                                    //   child: IconButton.filledTonal(
                                    //     onPressed: selectImage,
                                    //     icon: Icon(
                                    //       FeatherIcons.camera,
                                    //       size: width * 0.1125,
                                    //     ),
                                    //     tooltip: 'Change Image',
                                    //   ),
                                    // ),
                                    // REMOVE IMAGE
                                    Padding(
                                      padding: EdgeInsets.all(width * 0.0125),
                                      child: IconButton.filledTonal(
                                        onPressed: removeImage,
                                        icon: Icon(
                                          FeatherIcons.x,
                                          size: width * 0.1125,
                                        ),
                                        tooltip: 'Remove Image',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : SizedOverflowBox(
                            size: Size(width, width),
                            child: InkWell(
                              onTap: () async {
                                await selectImage();
                              },
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Container(
                                width: width,
                                height: width,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryDark,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FeatherIcons.upload,
                                      size: width * 0.4,
                                    ),
                                    SizedBox(height: width * 0.09),
                                    Text(
                                      'Select Image',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: width * 0.09,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // NAME
                    MyTextFormField(
                      hintText: 'Brand Name',
                      controller: brandNameController,
                      borderRadius: 12,
                      horizontalPadding: 0,
                      autoFillHints: null,
                    ),

                    // ADD PRODUCTS
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: MyButton(
                        text:
                            'Add Products (${productsAddedToBrandProvider.selectedProducts.length})',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) =>
                                  const AddProductsToBrandPage()),
                            ),
                          );
                        },
                        horizontalPadding: 0,
                        verticalPadding: width * 0.05,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
