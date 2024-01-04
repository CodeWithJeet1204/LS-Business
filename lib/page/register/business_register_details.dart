import 'package:find_easy/models/industry_segments.dart';
import 'package:find_easy/page/register/firestore_info.dart';
import 'package:find_easy/page/register/membership.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/image_container.dart';
import 'package:find_easy/widgets/image_text_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BusinessRegisterDetailsPage extends StatefulWidget {
  const BusinessRegisterDetailsPage({
    super.key,
  });

  @override
  State<BusinessRegisterDetailsPage> createState() =>
      _BusinessRegisterDetailsPageState();
}

class _BusinessRegisterDetailsPageState
    extends State<BusinessRegisterDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final GlobalKey<FormState> businessFormKey = GlobalKey<FormState>();
  final TextEditingController categoryNameController = TextEditingController();
  final String uuid = FirebaseAuth.instance.currentUser!.uid;
  bool isImageSelected = false;
  bool isNext = false;
  String? selectedIndustrySegment;
  // ignore: prefer_typing_uninitialized_variables
  var selectedImage;

  void showCategoryDialog() async {
    await showDialog(
      context: context,
      builder: ((context) => const ImageContainer()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 875,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                const HeadText(text: "BUSINESS\nDETAILS"),
                const SizedBox(height: 40),
                isImageSelected
                    ? Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            child: selectedImage,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton.filledTonal(
                              icon: const Icon(Icons.camera_alt_outlined),
                              iconSize: 30,
                              tooltip: "Change Shop Picture",
                              onPressed: () {},
                              color: primaryDark,
                            ),
                          ),
                        ],
                      )
                    : const CircleAvatar(
                        radius: 50,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 60,
                        ),
                      ),
                const SizedBox(height: 12),
                Form(
                  key: businessFormKey,
                  child: Column(
                    children: [
                      MyTextFormField(
                        hintText: "Shop Name",
                        controller: nameController,
                        borderRadius: 12,
                        horizontalPadding: 20,
                        verticalPadding: 4,
                        autoFillHints: const [
                          AutofillHints.streetAddressLevel1
                        ],
                      ),
                      MyTextFormField(
                        hintText: "Address (Don't include Shop Name)",
                        controller: addressController,
                        borderRadius: 12,
                        horizontalPadding: 20,
                        verticalPadding: 12,
                        keyboardType: TextInputType.streetAddress,
                        autoFillHints: const [
                          AutofillHints.streetAddressLevel2
                        ],
                      ),
                      GestureDetector(
                        onTap: showCategoryDialog,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: primary2.withOpacity(0.2),
                          ),
                          child: Text(
                            selectedCategory,
                            style: const TextStyle(
                              color: primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      selectedCategory == "Other"
                          ? Column(
                              children: [
                                const SizedBox(height: 12),
                                MyTextFormField(
                                  hintText: "Category Name",
                                  controller: categoryNameController,
                                  borderRadius: 12,
                                  horizontalPadding: 20,
                                  autoFillHints: null,
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primary2.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          elevation: 0,
                          isDense: false,
                          menuMaxHeight: 700,
                          itemHeight: 48,
                          dropdownColor:
                              const Color.fromARGB(255, 189, 234, 255),
                          hint: const Text("Select Industry Segment"),
                          items: industrySegments
                              .map((element) => DropdownMenuItem(
                                    value: element,
                                    child: Text(element),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedIndustrySegment = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        text: "Next",
                        onTap: () async {
                          if (businessFormKey.currentState!.validate()) {
                            try {
                              setState(() {
                                isNext = true;
                              });
                              businessFirestoreData.addAll(
                                {
                                  "Name": nameController.text.toString(),
                                  "Type": selectedCategory,
                                  "Address": addressController.text.toString(),
                                  "Industry": selectedIndustrySegment,
                                  "Image": "",
                                },
                              );
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: ((context) => SelectMembershipPage(
                                        uuid: uuid,
                                      )),
                                ),
                              );
                              setState(() {
                                isNext = false;
                              });
                            } catch (e) {
                              setState(() {
                                isNext = false;
                              });
                              if (context.mounted) {
                                mySnackBar(context, e.toString());
                              }
                            }
                          }
                        },
                        isLoading: isNext,
                        horizontalPadding: 20,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
