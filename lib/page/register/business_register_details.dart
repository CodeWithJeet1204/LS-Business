import 'package:find_easy/firebase/storage_methods.dart';
import 'package:find_easy/models/industry_segments.dart';
import 'package:find_easy/page/register/firestore_info.dart';
import 'package:find_easy/page/register/membership.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/image_container.dart';
import 'package:find_easy/widgets/image_picker.dart';
import 'package:find_easy/widgets/image_text_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController gstController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController specialNoteController = TextEditingController();
  final GlobalKey<FormState> businessFormKey = GlobalKey<FormState>();
  final TextEditingController categoryNameController = TextEditingController();
  bool isNext = false;
  String? selectedIndustrySegment;
  bool isImageSelected = false;
  Uint8List? _image;

  void showCategoryDialog() async {
    await showDialog(
      context: context,
      builder: ((context) => const ImageContainer()),
    );
    setState(() {});
  }

  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    if (im == null) {
      setState(() {
        isImageSelected = false;
      });
    } else {
      setState(() {
        _image = im;
        isImageSelected = true;
      });
    }
  }

  void uploadDetails() async {
    if (businessFormKey.currentState!.validate()) {
      if (_image != null) {
        try {
          setState(() {
            isNext = true;
          });
          businessImage.addAll({
            "Image": _image!,
          });
          String businessPhotoUrl = await StorageMethods().uploadImageToStorage(
            'Profile/Shops',
            businessImage["Image"]!,
            false,
          );
          businessFirestoreData.addAll(
            {
              "Name": nameController.text.toString(),
              "Type": selectedCategory == "Other"
                  ? categoryNameController.text.toString()
                  : selectedCategory,
              "GSTNumber": gstController.text.toString(),
              "Address": addressController.text.toString(),
              "Special Note": specialNoteController.text.toString(),
              "Industry": selectedIndustrySegment,
              "Image": businessPhotoUrl,
            },
          );

          SystemChannels.textInput.invokeMethod('TextInput.hide');
          if (context.mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const SelectMembershipPage()),
              ),
            );
          }
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
      } else {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const HeadText(text: "BUSINESS\nDETAILS"),
              const SizedBox(height: 40),

              // IMAGE
              isImageSelected
                  ? Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: MemoryImage(_image!),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton.filledTonal(
                            icon: const Icon(Icons.camera_alt_outlined),
                            iconSize: 30,
                            tooltip: "Change Shop Picture",
                            onPressed: selectImage,
                            color: primaryDark,
                          ),
                        ),
                      ],
                    )
                  : CircleAvatar(
                      radius: 50,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          size: 60,
                        ),
                        onPressed: selectImage,
                      ),
                    ),
              const SizedBox(height: 12),
              Form(
                key: businessFormKey,
                child: Column(
                  children: [
                    // SHOP NAME
                    MyTextFormField(
                      hintText: "Shop Name",
                      controller: nameController,
                      borderRadius: 12,
                      horizontalPadding: 20,
                      verticalPadding: 4,
                      autoFillHints: const [AutofillHints.streetAddressLevel1],
                    ),

                    // GST NUMBER
                    MyTextFormField(
                      hintText: "GST Number",
                      controller: gstController,
                      borderRadius: 12,
                      horizontalPadding: 20,
                      verticalPadding: 4,
                      autoFillHints: null,
                    ),

                    // ADDRESS
                    MyTextFormField(
                      hintText: "Address (Don't include Shop Name)",
                      controller: addressController,
                      borderRadius: 12,
                      horizontalPadding: 20,
                      verticalPadding: 12,
                      keyboardType: TextInputType.streetAddress,
                      autoFillHints: const [AutofillHints.streetAddressLevel2],
                    ),

                    // CATEGORY
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
                          color: primary2.withOpacity(0.75),
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

                    // OTHER CATEGORY
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

                    // INDUSTRY SEGMENT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primary2.withOpacity(0.75),
                              width: 1,
                            ),
                          ),
                        ),
                        elevation: 0,
                        isDense: false,
                        menuMaxHeight: 700,
                        itemHeight: 48,
                        dropdownColor: const Color.fromARGB(255, 189, 234, 255),
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

                    // SPECIAL NOTE
                    MyTextFormField(
                      hintText: "Special Note",
                      controller: specialNoteController,
                      borderRadius: 12,
                      horizontalPadding: 20,
                      autoFillHints: null,
                    ),
                    const SizedBox(height: 20),

                    // NEXT
                    MyButton(
                      text: "Next",
                      onTap: uploadDetails,
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
    );
  }
}
