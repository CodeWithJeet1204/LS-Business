import 'package:find_easy/firebase/storage_methods.dart';
import 'package:find_easy/page/register/business_register_details.dart';
import 'package:find_easy/page/register/firestore_info.dart';
import 'package:find_easy/provider/sign_in_method_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/image_picker.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserRegisterDetailsPage extends StatefulWidget {
  const UserRegisterDetailsPage({
    super.key,
  });

  @override
  State<UserRegisterDetailsPage> createState() =>
      _UserRegisterDetailsPageState();
}

class _UserRegisterDetailsPageState extends State<UserRegisterDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> userFormKey = GlobalKey<FormState>();
  bool isImageSelected = false;
  Uint8List? _image;
  bool isNext = false;

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

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String uid = _auth.currentUser!.uid;
    final signInMethodProvider = Provider.of<SignInMethodProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 723,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                const HeadText(text: "USER\nDETAILS"),
                const SizedBox(height: 40),
                Column(
                  children: [
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
                                  tooltip: "Change User Picture",
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
                  ],
                ),
                Form(
                  key: userFormKey,
                  child: Column(
                    children: [
                      MyTextFormField(
                        hintText: "Your Name",
                        controller: nameController,
                        borderRadius: 12,
                        horizontalPadding: 20,
                        verticalPadding: 12,
                        autoFillHints: const [AutofillHints.name],
                      ),
                      !signInMethodProvider.isNumberChosen
                          ? Container()
                          : MyTextFormField(
                              hintText: "Email",
                              controller: emailController,
                              borderRadius: 12,
                              horizontalPadding: 20,
                              verticalPadding: 12,
                              keyboardType: TextInputType.emailAddress,
                              autoFillHints: const [AutofillHints.email],
                            ),
                      signInMethodProvider.isNumberChosen
                          ? Container()
                          : MyTextFormField(
                              hintText: "Your Phone Number (Personal)",
                              controller: phoneController,
                              borderRadius: 12,
                              horizontalPadding: 20,
                              verticalPadding: 12,
                              keyboardType: TextInputType.number,
                              autoFillHints: const [
                                AutofillHints.telephoneNumber
                              ],
                            ),
                      MyButton(
                        text: "Next",
                        onTap: () async {
                          if (userFormKey.currentState!.validate()) {
                            if (confirmPasswordController.text ==
                                passwordController.text) {
                              if (_image != null) {
                                try {
                                  setState(() {
                                    isNext = true;
                                  });
                                  userImage.addAll({
                                    "Image": _image!,
                                  });
                                  String userPhotoUrl = await StorageMethods()
                                      .uploadImageToStorage(
                                    'Profile/Users',
                                    userImage["Image"]!,
                                    false,
                                  );
                                  signInMethodProvider.isGoogleChosen
                                      ? userFirestoreData.addAll(
                                          {
                                            "Phone Number":
                                                phoneController.text,
                                            "Image": userPhotoUrl,
                                          },
                                        )
                                      : signInMethodProvider.isNumberChosen
                                          ? userFirestoreData.addAll({
                                              "uid": uid,
                                              "Email": emailController.text
                                                  .toString(),
                                              "Name": nameController.text
                                                  .toString(),
                                              "Image": userPhotoUrl,
                                            })
                                          : signInMethodProvider.isEmailChosen
                                              ? userFirestoreData.addAll({
                                                  "uid": uid,
                                                  "Phone Number":
                                                      phoneController.text
                                                          .toString(),
                                                  "Image": userPhotoUrl,
                                                })
                                              : mySnackBar(context,
                                                  "Some error occured");
                                  setState(() {
                                    isNext = false;
                                  });
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BusinessRegisterDetailsPage(),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setState(() {
                                    isNext = false;
                                  });
                                  if (context.mounted) {
                                    mySnackBar(context, e.toString());
                                  }
                                }
                              } else {
                                mySnackBar(context, "Select Profile Image");
                              }
                            } else {
                              mySnackBar(
                                context,
                                "Passwords do not match. Check Again!",
                              );
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
