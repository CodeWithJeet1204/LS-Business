import 'package:find_easy/firebase/auth_methods.dart';
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
  String? selectedIndustrySegment = null;
  var selectedImage;

  void showCategoryDialog() async {
    await showDialog(
      context: context,
      builder: ((context) => ImageContainer()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    // ignore: unused_local_variable
    final AuthMethods auth = AuthMethods(_auth);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 875,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                HeadText(text: "BUSINESS\nDETAILS"),
                SizedBox(height: 40),
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
                    : CircleAvatar(
                        radius: 50,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 60,
                        ),
                      ),
                SizedBox(height: 12),
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
                        autoFillHints: [AutofillHints.streetAddressLevel1],
                      ),
                      MyTextFormField(
                        hintText: "Address (Don't include Shop Name)",
                        controller: addressController,
                        borderRadius: 12,
                        horizontalPadding: 20,
                        verticalPadding: 12,
                        keyboardType: TextInputType.streetAddress,
                        autoFillHints: [AutofillHints.streetAddressLevel2],
                      ),
                      GestureDetector(
                        // onTap: () async {
                        //   selectedCategory = await Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //       builder: (context) => ImageContainer(),
                        //     ),
                        //   );
                        // },
                        onTap: showCategoryDialog,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 0,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Text(
                            selectedCategory,
                            style: TextStyle(
                              color: primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: primary2.withOpacity(0.2),
                          ),
                        ),
                      ),
                      selectedCategory == "Other"
                          ? Column(
                              children: [
                                SizedBox(height: 12),
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
                      SizedBox(height: 16),
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
                          dropdownColor: Color.fromARGB(255, 189, 234, 255),
                          hint: Text("Select Industry Segment"),
                          items: industrySegments
                              .map((element) => DropdownMenuItem(
                                    child: Text(element),
                                    value: element,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedIndustrySegment = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      MyButton(
                        text: "Next",
                        onTap: () async {
                          if (businessFormKey.currentState!.validate()) {
                            try {
                              setState(() {
                                isNext = true;
                              });
                              // await store
                              //     .collection('Business')
                              //     .doc('Owners')
                              //     .collection('Shops')
                              //     .doc(widget.uuid)
                              //     .set({
                              //   'Name': nameController.text.toString(),
                              //   'Type': selectedCategory != "Other"
                              //       ? selectedCategory.toString()
                              //       : categoryNameController.text.toString(),
                              //   'Address': addressController.text.toString(),
                              //   'Industry': selectedIndustrySegment,
                              //   'Image': '',
                              // });
                              BusinessFirestoreData.addAll(
                                {
                                  "Name": nameController.text.toString(),
                                  "Type": selectedCategory,
                                  "Address": addressController.text.toString(),
                                  "Industry": selectedIndustrySegment,
                                  "Image": "",
                                },
                              );
                              print(UserFirestoreData);
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
                              mySnackBar(context, e.toString());
                            }
                          }
                        },
                        isLoading: isNext,
                        horizontalPadding: 20,
                      ),
                      SizedBox(height: 12),
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
