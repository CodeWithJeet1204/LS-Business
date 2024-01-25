import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/firebase/storage_methods.dart';
import 'package:find_easy/provider/category_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = StorageMethods();
  final fireStorage = FirebaseStorage.instance;
  final productKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  bool isAddingProduct = false;
  final List<File> _image = [];
  int currentImageIndex = 0;
  String? selectedCategory;
  final List<String> _imageDownloadUrl = [];
  final ImagePicker picker = ImagePicker();

  void addProductImages() async {
    final XFile? im = await picker.pickImage(source: ImageSource.gallery);
    if (im != null) {
      setState(() {
        _image.add(File(im.path));
      });
    } else {
      if (context.mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  void removeProductImages(int index) {
    setState(() {
      _image.removeAt(index);
    });
  }

  void addProduct() async {
    if (productKey.currentState!.validate()) {
      if (_image.isEmpty) {
        return mySnackBar(context, "Select atleast 1 image");
      }
      if (selectedCategory == null) {
        return mySnackBar(context, "Select Category");
      }
      try {
        setState(() {
          isAddingProduct = true;
        });
        for (File img in _image) {
          try {
            Reference ref = fireStorage
                .ref()
                .child('Data/Products')
                .child(const Uuid().v4());
            await ref.putFile(img).whenComplete(() async {
              await ref.getDownloadURL().then((value) {
                setState(() {
                  _imageDownloadUrl.add(value);
                });
              });
            });
          } catch (e) {
            if (context.mounted) {
              mySnackBar(context, e.toString());
            }
          }
        }
        // ignore: avoid_function_literals_in_foreach_calls
        // _image.forEach((element) async {
        //   String url = await storage.uploadImageToStorage(
        //     'Data/Products',
        //     element!,
        //     false,
        //   );
        //   _imageDownloadUrl.add(url);
        // });
        final String productId = const Uuid().v4();
        await store
            .collection('Business')
            .doc('Data')
            .collection('Products')
            .doc(productId)
            .set({
          'productName': nameController.text,
          'productPrice': priceController.text,
          'productId': productId,
          'images': _imageDownloadUrl,
          'vendorId': FirebaseAuth.instance.currentUser!.uid,
        });
        setState(() {
          isAddingProduct = false;
        });
        Timer(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      } catch (e) {
        setState(() {
          isAddingProduct = false;
        });
        if (context.mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final CategoryProvider categoryProvider =
        Provider.of<CategoryProvider>(context);
    List<String> categories = categoryProvider.getCategory.keys.toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text("Add Product"),
        actions: [
          IconButton(
            onPressed: () {
              addProduct();
            },
            icon: const Icon(
              Icons.ios_share_rounded,
              size: 24,
            ),
            tooltip: "Add Product",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isAddingProduct ? const LinearProgressIndicator() : Container(),
                _image.isNotEmpty
                    ? Column(
                        children: [
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  height: 300,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: FileImage(
                                        _image[currentImageIndex],
                                      ),
                                    ),
                                  ),
                                ),
                                // Image.memory(
                                //   _image[currentImageIndex]!,
                                //   height: 300,
                                // ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: IconButton.filledTonal(
                                      onPressed:
                                          currentImageIndex != _image.length - 1
                                              ? () {
                                                  removeProductImages(
                                                      currentImageIndex);
                                                }
                                              : null,
                                      icon: const Icon(
                                        Icons.highlight_remove_rounded,
                                        size: 40,
                                      ),
                                      tooltip: "Remove Image",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.025),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryDark,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(4),
                                height: height * 0.125,
                                width: width * 0.79,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _image.length,
                                  itemBuilder: ((context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          currentImageIndex = index;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: Container(
                                          height: height * 0.125,
                                          width: height * 0.125 / 2,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: FileImage(
                                                _image[index],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // child: Padding(
                                      //   padding: const EdgeInsets.all(2),
                                      //   child: Image.asset(
                                      //     _image[index],
                                      //     height: height * 0.125,
                                      //     width: height * 0.125 / 2,
                                      //   ),
                                      // ),
                                    );
                                  }),
                                ),
                              ),
                              SizedBox(width: width * 0.0275),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryDark,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    addProductImages();
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : SizedOverflowBox(
                        size: Size(width, height * 0.4),
                        child: Container(
                          width: width,
                          height: height * 0.4,
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
                              IconButton(
                                onPressed: addProductImages,
                                icon: const Icon(
                                  Icons.arrow_circle_up_rounded,
                                  size: 120,
                                ),
                              ),
                              SizedBox(height: height * 0.05),
                              const Text(
                                "Select Image",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                SizedBox(height: height * 0.05),
                Form(
                  key: productKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: "Product Name",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: primaryDark2,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != null) {
                            if (value.length < 20 && value.isNotEmpty) {
                              return null;
                            } else {
                              return "20 characters max.";
                            }
                          } else {
                            return "Enter name";
                          }
                        },
                      ),
                      SizedBox(height: height * 0.025),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Price (Optional)",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: primaryDark2,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.0125),
                      const Divider(),
                      SizedBox(height: height * 0.0125),
                      Container(
                        width: width * 0.6,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton(
                          hint: const Text("Select category"),
                          style: const TextStyle(
                            fontSize: 22,
                            color: primaryDark2,
                            fontWeight: FontWeight.w600,
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Colors.black,
                          ),
                          value: selectedCategory,
                          dropdownColor: primary2,
                          borderRadius: BorderRadius.circular(12),
                          underline: const SizedBox(),
                          items: categories.isNotEmpty
                              ? categories
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList()
                              : ['None']
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
