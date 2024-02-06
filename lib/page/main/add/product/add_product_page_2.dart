// ignore_for_file: unnecessary_null_comparison
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/models/category_properties.dart';
import 'package:find_easy/page/main/main_page.dart';
import 'package:find_easy/provider/add_product_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/additional_info_box.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddProductPage2 extends StatefulWidget {
  const AddProductPage2({
    super.key,
    required this.productId,
  });
  final String productId;

  @override
  State<AddProductPage2> createState() => _AddProductPage2State();
}

class _AddProductPage2State extends State<AddProductPage2> {
  final store = FirebaseFirestore.instance;
  late String shopTypes = '';
  Map<String, dynamic> properties = {};
  final GlobalKey<FormState> productKey = GlobalKey<FormState>();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController otherInfoController = TextEditingController();
  final TextEditingController otherInfoValueController =
      TextEditingController();
  String? otherInfo;

  final TextEditingController property0Controller = TextEditingController();
  final TextEditingController property1Controller = TextEditingController();
  final TextEditingController property2Controller = TextEditingController();
  final TextEditingController property3Controller = TextEditingController();
  final TextEditingController property4Controller = TextEditingController();
  final TextEditingController property5Controller = TextEditingController();
  List<String> tagList = [];
  List<String> property0 = [];
  List<String> property1 = [];
  List<String> property2 = [];
  List<String> property3 = [];
  List<String> property4 = [];
  List<String> property5 = [];
  List<String> otherInfoList = [];
  String? propertyValue0;
  String? propertyValue1;
  String? propertyValue2;
  String? propertyValue3;
  String? propertyValue4;
  String? propertyValue5;
  bool isAddingProduct = false;

  void addTag(String tag) {
    if (tag.length > 1) {
      setState(() {
        tagList.add(tag);
        tagController.clear();
      });
    } else {
      mySnackBar(context, "Tag should be atleast 2 chars long");
    }
  }

  void removeTag(int index) {
    setState(() {
      tagList.removeAt(index);
    });
  }

  void addOtherInfoValue() {
    if (otherInfoValueController.text.toString().length > 1) {
      setState(() {
        otherInfoList.add(otherInfoValueController.text.toString());
      });
      otherInfoValueController.clear();
    } else {
      mySnackBar(context, "Value length should be greater than 1");
    }
  }

  void removeOtherInfo(int index) {
    setState(() {
      otherInfoList.removeAt(index);
    });
  }

  void addProduct(AddProductProvider Provider) async {
    if (productKey.currentState!.validate()) {
      if (property0.isEmpty && getCompulsory(0)) {
        if (getNoOfAnswers(0) == 1) {
          if (property0Controller.text.isEmpty ||
              property0Controller.text == null) {
            return mySnackBar(
                context, "Enter value for ${getPropertiesKeys(0)}");
          }
          property0.add(property0Controller.text.toString().toUpperCase());
        } else if (getNoOfAnswers(0) == 2) {
          return mySnackBar(context, "Select ${getPropertiesKeys(0)}");
        } else if (getNoOfAnswers(0) == 3) {
          return mySnackBar(
              context, "Add atleast one value to ${getPropertiesKeys(0)}");
        }
      }
      if (property1.isEmpty && getCompulsory(1)) {
        if (getNoOfAnswers(1) == 1) {
          if (property1Controller.text.isEmpty ||
              property1Controller.text == null) {
            return mySnackBar(
                context, "Enter value for ${getPropertiesKeys(1)}");
          }
          property1.add(property1Controller.text.toString().toUpperCase());
        } else if (getNoOfAnswers(1) == 2) {
          return mySnackBar(context, "Select ${getPropertiesKeys(1)}");
        } else if (getNoOfAnswers(1) == 3) {
          return mySnackBar(
              context, "Add atleast one value to ${getPropertiesKeys(1)}");
        }
      }
      if (property2.isEmpty && getCompulsory(2)) {
        if (getNoOfAnswers(2) == 1) {
          if (property2Controller.text.isEmpty ||
              property2Controller.text == null) {
            return mySnackBar(
                context, "Enter value for ${getPropertiesKeys(2)}");
          }
          property2.add(property2Controller.text.toString().toUpperCase());
        } else if (getNoOfAnswers(2) == 2) {
          return mySnackBar(context, "Select ${getPropertiesKeys(2)}");
        } else if (getNoOfAnswers(2) == 3) {
          return mySnackBar(
              context, "Add atleast one value to ${getPropertiesKeys(2)}");
        }
      }
      if (property3.isEmpty && getCompulsory(3)) {
        if (getNoOfAnswers(3) == 1) {
          if (property3Controller.text.isEmpty ||
              property3Controller.text == null) {
            return mySnackBar(
                context, "Enter value for ${getPropertiesKeys(3)}");
          }
          property3.add(property3Controller.text.toString().toUpperCase());
        } else if (getNoOfAnswers(3) == 2) {
          return mySnackBar(context, "Select ${getPropertiesKeys(3)}");
        } else if (getNoOfAnswers(3) == 3) {
          return mySnackBar(
              context, "Add atleast one value to ${getPropertiesKeys(3)}");
        }
      }
      if (property4.isEmpty && getCompulsory(4)) {
        if (getNoOfAnswers(4) == 1) {
          if (property4Controller.text.isEmpty ||
              property4Controller.text == null) {
            return mySnackBar(
                context, "Enter value for ${getPropertiesKeys(4)}");
          }
          property4.add(property4Controller.text.toString().toUpperCase());
        } else if (getNoOfAnswers(4) == 2) {
          return mySnackBar(context, "Select ${getPropertiesKeys(4)}");
        } else if (getNoOfAnswers(4) == 3) {
          return mySnackBar(
              context, "Add atleast one value to ${getPropertiesKeys(4)}");
        }
      }
      if (property5.isEmpty && getCompulsory(5)) {
        if (getNoOfAnswers(5) == 1) {
          if (property5Controller.text.isEmpty ||
              property5Controller.text == null) {
            return mySnackBar(
                context, "Enter value for ${getPropertiesKeys(5)}");
          }
          property5.add(property5Controller.text.toString().toUpperCase());
        } else if (getNoOfAnswers(5) == 2) {
          return mySnackBar(context, "Select ${getPropertiesKeys(5)}");
        } else if (getNoOfAnswers(5) == 3) {
          return mySnackBar(
              context, "Add atleast one value to ${getPropertiesKeys(5)}");
        }
      }

      try {
        setState(() {
          isAddingProduct = true;
        });
        properties.addAll({
          'propertyName0': getPropertiesKeys(0),
          'propertyName1': getPropertiesKeys(1),
          'propertyName2': getPropertiesKeys(2),
          'propertyName3': getPropertiesKeys(3),
          'propertyName4': getPropertiesKeys(4),
          'propertyName5': getPropertiesKeys(5),
          'propertyValue0': property0,
          'propertyValue1': property1,
          'propertyValue2': property2,
          'propertyValue3': property3,
          'propertyValue4': property4,
          'propertyValue5': property5,
          'propertyNoOfAnswers0': getNoOfAnswers(0),
          'propertyNoOfAnswers1': getNoOfAnswers(1),
          'propertyNoOfAnswers2': getNoOfAnswers(2),
          'propertyNoOfAnswers3': getNoOfAnswers(3),
          'propertyNoOfAnswers4': getNoOfAnswers(4),
          'propertyNoOfAnswers5': getNoOfAnswers(5),
          'propertyChangable0': getChangeBool(0),
          'propertyChangable1': getChangeBool(1),
          'propertyChangable2': getChangeBool(2),
          'propertyChangable3': getChangeBool(3),
          'propertyChangable4': getChangeBool(4),
          'propertyChangable5': getChangeBool(5),
          'propertyInputType0': getPropertiesInputType(0) == TextInputType.text,
          'propertyInputType1': getPropertiesInputType(1) == TextInputType.text,
          'propertyInputType2': getPropertiesInputType(2) == TextInputType.text,
          'propertyInputType3': getPropertiesInputType(3) == TextInputType.text,
          'propertyInputType4': getPropertiesInputType(4) == TextInputType.text,
          'propertyInputType5': getPropertiesInputType(5) == TextInputType.text,
        });
        await store
            .collection('Business')
            .doc('Data')
            .collection('Products')
            .doc(widget.productId)
            .set(Provider.productInfo);

        await store
            .collection('Business')
            .doc('Data')
            .collection('Products')
            .doc(widget.productId)
            .update({
          'Properties': properties,
          'Tags': tagList,
        });

        setState(() {
          isAddingProduct = false;
        });
        if (context.mounted) {
          mySnackBar(context, "Product Added");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: ((context) => const MainPage(index: 0)),
            ),
            (route) => false,
          );
        }
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
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await getShopType();
  }

  Future<void> getShopType() async {
    final Future<String> shopType = FirebaseFirestore.instance
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      String type = documentSnapshot.get('Type');
      return type;
    });
    shopTypes = await shopType;
    setState(() {
      shopTypes = shopTypes;
    });
  }

  String getPropertiesKeys(int index) {
    return categoryProperties[shopTypes]![index][0];
  }

  String getPropertiesHintText(int index) {
    return categoryProperties[shopTypes]![index][1];
  }

  int getNoOfAnswers(int index) {
    return categoryProperties[shopTypes]![index][2];
  }

  List<String> getDropDownItems(int index) {
    return categoryProperties[shopTypes]![index][3];
  }

  TextInputType getPropertiesInputType(int index) {
    return categoryProperties[shopTypes]![index][4];
  }

  int getMaxLines(int index) {
    return categoryProperties[shopTypes]![index][5];
  }

  bool getChangeBool(int index) {
    if (getNoOfAnswers(index) == 1 || getNoOfAnswers(index) == 3) {
      return true;
    } else {
      return false;
    }
  }

  bool getCompulsory(int index) {
    return categoryProperties[shopTypes]![index][6];
  }

  @override
  Widget build(BuildContext context) {
    final addProductProvider = Provider.of<AddProductProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Additional Info'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              addProduct(addProductProvider);
            },
            icon: const Icon(Icons.ios_share),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: isAddingProduct
              ? const Size(double.infinity, 10)
              : const Size(0, 0),
          child:
              isAddingProduct ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: shopTypes == ''
          ? Center(
              child: CircularProgressIndicator(
                color: primaryDark,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: LayoutBuilder(
                builder: ((context, constraints) {
                  double width = constraints.maxWidth;
                  double height = constraints.maxHeight;
                  return SingleChildScrollView(
                    child: Form(
                      key: productKey,
                      child: Column(
                        children: [
                          Text(
                            "Properties marked with '*' are compulsory to fill",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primaryDark2,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),

                          // TAGS
                          PropertyBox(
                            headText: "Tags",
                            widget1: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: tagController,
                                    maxLength: 16,
                                    maxLines: 1,
                                    minLines: 1,
                                    decoration: const InputDecoration(
                                      hintText: "Product Tags (Optional)",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: primaryDark2,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                MyTextButton(
                                  onPressed: () {
                                    addTag(tagController.text
                                        .toString()
                                        .toUpperCase());
                                  },
                                  text: "Add",
                                  textColor: primaryDark2,
                                ),
                              ],
                            ),
                            widget2: tagList.isNotEmpty
                                ? Container(
                                    width: width,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: primary3.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: tagList.length,
                                      itemBuilder: ((context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: primaryDark2
                                                  .withOpacity(0.75),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 12,
                                                  ),
                                                  child: Text(
                                                    tagList[index],
                                                    style: const TextStyle(
                                                      color: white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 2),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      removeTag(index);
                                                    },
                                                    icon: const Icon(
                                                      Icons
                                                          .highlight_remove_outlined,
                                                      color: white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  )
                                : Container(),
                          ),

                          // PROPERTY 0
                          getPropertiesKeys(0) != ''
                              ? PropertyBox(
                                  headText: getCompulsory(0)
                                      ? "${getPropertiesKeys(0)}*"
                                      : getPropertiesKeys(0),
                                  widget1: getNoOfAnswers(0) == 1
                                      ? TextFormField(
                                          controller: property0Controller,
                                          maxLines: getMaxLines(0),
                                          minLines: 1,
                                          keyboardType:
                                              getPropertiesInputType(0),
                                          decoration: InputDecoration(
                                            hintText: getPropertiesHintText(0),
                                            border: const OutlineInputBorder(),
                                          ),
                                        )
                                      : getNoOfAnswers(0) == 2
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: primary3,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: DropdownButton(
                                                dropdownColor: primary,
                                                hint: const Text("Select"),
                                                value: propertyValue0,
                                                underline: Container(),
                                                items: getDropDownItems(0)
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e.toUpperCase(),
                                                        child: Text(
                                                            e.toUpperCase()),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value != null) {
                                                      propertyValue0 = value;
                                                      property0.clear();
                                                      property0
                                                          .add(propertyValue0!);
                                                    }
                                                  });
                                                },
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller:
                                                        property0Controller,
                                                    keyboardType:
                                                        getPropertiesInputType(
                                                            0),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          getPropertiesHintText(
                                                              0),
                                                      border:
                                                          const OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                MyTextButton(
                                                  onPressed: () {
                                                    if (property0Controller
                                                            .text.isNotEmpty &&
                                                        property0Controller.text
                                                                .toString() !=
                                                            null) {
                                                      if (property0Controller
                                                              .text
                                                              .toString()
                                                              .length <
                                                          2) {
                                                        return mySnackBar(
                                                          context,
                                                          "Answer should be greater than 1",
                                                        );
                                                      }
                                                      setState(() {
                                                        property0.add(
                                                          property0Controller
                                                              .text
                                                              .toString()
                                                              .toUpperCase(),
                                                        );
                                                        property0Controller
                                                            .clear();
                                                      });
                                                    }
                                                  },
                                                  text: "ADD",
                                                  textColor: primaryDark,
                                                ),
                                              ],
                                            ),
                                  widget2: getNoOfAnswers(0) <= 2
                                      ? Container()
                                      : property0.isNotEmpty
                                          ? SizedBox(
                                              height: 50,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: property0.length,
                                                itemBuilder: ((context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: primaryDark2
                                                            .withOpacity(0.75),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 12,
                                                            ),
                                                            child: Text(
                                                              property0[index],
                                                              style:
                                                                  const TextStyle(
                                                                color: white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              right: 2,
                                                            ),
                                                            child: IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  property0
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .highlight_remove_outlined,
                                                                color: white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            )
                                          : Container(),
                                )
                              : Container(),

                          // PROPERTY 1
                          getPropertiesKeys(1) != ''
                              ? PropertyBox(
                                  headText: getCompulsory(1)
                                      ? "${getPropertiesKeys(1)}*"
                                      : getPropertiesKeys(1),
                                  widget1: getNoOfAnswers(1) == 1
                                      ? TextFormField(
                                          controller: property1Controller,
                                          maxLines: getMaxLines(1),
                                          minLines: 1,
                                          keyboardType:
                                              getPropertiesInputType(1),
                                          decoration: InputDecoration(
                                            hintText: getPropertiesHintText(1),
                                            border: const OutlineInputBorder(),
                                          ),
                                        )
                                      : getNoOfAnswers(1) == 2
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: primary3,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: DropdownButton(
                                                dropdownColor: primary,
                                                hint: const Text("Select"),
                                                value: propertyValue1,
                                                underline: Container(),
                                                items: getDropDownItems(1)
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e.toUpperCase(),
                                                        child: Text(
                                                            e.toUpperCase()),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value != null) {
                                                      propertyValue1 = value;
                                                      property1.clear();
                                                      property1
                                                          .add(propertyValue1!);
                                                    }
                                                  });
                                                },
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller:
                                                        property1Controller,
                                                    keyboardType:
                                                        getPropertiesInputType(
                                                            1),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          getPropertiesHintText(
                                                              1),
                                                      border:
                                                          const OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                MyTextButton(
                                                  onPressed: () {
                                                    if (property1Controller
                                                            .text.isNotEmpty &&
                                                        property1Controller.text
                                                                .toString() !=
                                                            null) {
                                                      if (property1Controller
                                                              .text
                                                              .toString()
                                                              .length <
                                                          2) {
                                                        return mySnackBar(
                                                          context,
                                                          "Answer should be greater than 1",
                                                        );
                                                      }
                                                      setState(() {
                                                        property1.add(
                                                          property1Controller
                                                              .text
                                                              .toString()
                                                              .toUpperCase(),
                                                        );
                                                        property1Controller
                                                            .clear();
                                                      });
                                                    }
                                                  },
                                                  text: "ADD",
                                                  textColor: primaryDark,
                                                ),
                                              ],
                                            ),
                                  widget2: getNoOfAnswers(1) <= 2
                                      ? Container()
                                      : property1.isNotEmpty
                                          ? SizedBox(
                                              height: 50,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: property1.length,
                                                itemBuilder: ((context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: primaryDark2
                                                            .withOpacity(0.75),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 12,
                                                            ),
                                                            child: Text(
                                                              property1[index],
                                                              style:
                                                                  const TextStyle(
                                                                color: white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              right: 2,
                                                            ),
                                                            child: IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  property1
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .highlight_remove_outlined,
                                                                color: white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            )
                                          : Container(),
                                )
                              : Container(),

                          // PROPERTY 2
                          getPropertiesKeys(2) != ''
                              ? PropertyBox(
                                  headText: getCompulsory(2)
                                      ? "${getPropertiesKeys(2)}*"
                                      : getPropertiesKeys(2),
                                  widget1: getNoOfAnswers(2) == 1
                                      ? TextFormField(
                                          controller: property2Controller,
                                          maxLines: getMaxLines(2),
                                          minLines: 1,
                                          keyboardType:
                                              getPropertiesInputType(2),
                                          decoration: InputDecoration(
                                            hintText: getPropertiesHintText(2),
                                            border: const OutlineInputBorder(),
                                          ),
                                        )
                                      : getNoOfAnswers(2) == 2
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: primary3,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: DropdownButton(
                                                dropdownColor: primary,
                                                hint: const Text("Select"),
                                                value: propertyValue2,
                                                underline: Container(),
                                                items: getDropDownItems(2)
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e.toUpperCase(),
                                                        child: Text(
                                                            e.toUpperCase()),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value != null) {
                                                      propertyValue2 = value;
                                                      property2.clear();
                                                      property2
                                                          .add(propertyValue2!);
                                                    }
                                                  });
                                                },
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller:
                                                        property2Controller,
                                                    keyboardType:
                                                        getPropertiesInputType(
                                                            2),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          getPropertiesHintText(
                                                              2),
                                                      border:
                                                          const OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                MyTextButton(
                                                  onPressed: () {
                                                    if (property2Controller
                                                            .text.isNotEmpty &&
                                                        property2Controller.text
                                                                .toString() !=
                                                            null) {
                                                      if (property2Controller
                                                              .text
                                                              .toString()
                                                              .length <
                                                          2) {
                                                        return mySnackBar(
                                                          context,
                                                          "Answer should be greater than 1",
                                                        );
                                                      }
                                                      setState(() {
                                                        property2.add(
                                                          property2Controller
                                                              .text
                                                              .toString()
                                                              .toUpperCase(),
                                                        );
                                                        property2Controller
                                                            .clear();
                                                      });
                                                    }
                                                  },
                                                  text: "ADD",
                                                  textColor: primaryDark,
                                                ),
                                              ],
                                            ),
                                  widget2: getNoOfAnswers(2) <= 2
                                      ? Container()
                                      : property2.isNotEmpty
                                          ? SizedBox(
                                              height: 50,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: property2.length,
                                                itemBuilder: ((context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: primaryDark2
                                                            .withOpacity(0.75),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 12,
                                                            ),
                                                            child: Text(
                                                              property2[index],
                                                              style:
                                                                  const TextStyle(
                                                                color: white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              right: 2,
                                                            ),
                                                            child: IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  property2
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .highlight_remove_outlined,
                                                                color: white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            )
                                          : Container(),
                                )
                              : Container(),

                          // PROPERTY 3
                          getPropertiesKeys(3) != ''
                              ? PropertyBox(
                                  headText: getCompulsory(3)
                                      ? "${getPropertiesKeys(3)}*"
                                      : getPropertiesKeys(3),
                                  widget1: getNoOfAnswers(3) == 1
                                      ? TextFormField(
                                          controller: property3Controller,
                                          maxLines: getMaxLines(3),
                                          minLines: 1,
                                          keyboardType:
                                              getPropertiesInputType(3),
                                          decoration: InputDecoration(
                                            hintText: getPropertiesHintText(3),
                                            border: const OutlineInputBorder(),
                                          ),
                                        )
                                      : getNoOfAnswers(3) == 2
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: primary3,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: DropdownButton(
                                                dropdownColor: primary,
                                                hint: const Text("Select"),
                                                value: propertyValue3,
                                                underline: Container(),
                                                items: getDropDownItems(3)
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e.toUpperCase(),
                                                        child: Text(
                                                            e.toUpperCase()),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value != null) {
                                                      propertyValue3 = value;
                                                      property3.clear();
                                                      property3
                                                          .add(propertyValue3!);
                                                    }
                                                  });
                                                },
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller:
                                                        property3Controller,
                                                    keyboardType:
                                                        getPropertiesInputType(
                                                            3),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          getPropertiesHintText(
                                                              3),
                                                      border:
                                                          const OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                MyTextButton(
                                                  onPressed: () {
                                                    if (property3Controller
                                                            .text.isNotEmpty &&
                                                        property3Controller.text
                                                                .toString() !=
                                                            null) {
                                                      if (property3Controller
                                                              .text
                                                              .toString()
                                                              .length <
                                                          2) {
                                                        return mySnackBar(
                                                          context,
                                                          "Answer should be greater than 1",
                                                        );
                                                      }
                                                      setState(() {
                                                        property3.add(
                                                          property3Controller
                                                              .text
                                                              .toString()
                                                              .toUpperCase(),
                                                        );
                                                        property3Controller
                                                            .clear();
                                                      });
                                                    }
                                                  },
                                                  text: "ADD",
                                                  textColor: primaryDark,
                                                ),
                                              ],
                                            ),
                                  widget2: getNoOfAnswers(3) <= 2
                                      ? Container()
                                      : property3.isNotEmpty
                                          ? SizedBox(
                                              height: 50,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: property3.length,
                                                itemBuilder: ((context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: primaryDark2
                                                            .withOpacity(0.75),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 12,
                                                            ),
                                                            child: Text(
                                                              property3[index],
                                                              style:
                                                                  const TextStyle(
                                                                color: white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              right: 2,
                                                            ),
                                                            child: IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  property3
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .highlight_remove_outlined,
                                                                color: white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            )
                                          : Container(),
                                )
                              : Container(),

                          // PROPERTY 4
                          getPropertiesKeys(4) != ''
                              ? PropertyBox(
                                  headText: getCompulsory(4)
                                      ? "${getPropertiesKeys(4)}*"
                                      : getPropertiesKeys(4),
                                  widget1: getNoOfAnswers(4) == 1
                                      ? TextFormField(
                                          controller: property4Controller,
                                          maxLines: getMaxLines(4),
                                          minLines: 1,
                                          keyboardType:
                                              getPropertiesInputType(4),
                                          decoration: InputDecoration(
                                            hintText: getPropertiesHintText(4),
                                            border: const OutlineInputBorder(),
                                          ),
                                        )
                                      : getNoOfAnswers(4) == 2
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: primary3,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: DropdownButton(
                                                dropdownColor: primary,
                                                hint: const Text("Select"),
                                                value: propertyValue4,
                                                underline: Container(),
                                                items: getDropDownItems(4)
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e.toUpperCase(),
                                                        child: Text(
                                                            e.toUpperCase()),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value != null) {
                                                      propertyValue4 = value;
                                                      property4.clear();
                                                      property4
                                                          .add(propertyValue4!);
                                                    }
                                                  });
                                                },
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller:
                                                        property4Controller,
                                                    keyboardType:
                                                        getPropertiesInputType(
                                                            4),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          getPropertiesHintText(
                                                              4),
                                                      border:
                                                          const OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                MyTextButton(
                                                  onPressed: () {
                                                    if (property4Controller
                                                            .text.isNotEmpty &&
                                                        property4Controller.text
                                                                .toString() !=
                                                            null) {
                                                      if (property4Controller
                                                              .text
                                                              .toString()
                                                              .length <
                                                          2) {
                                                        return mySnackBar(
                                                          context,
                                                          "Answer should be greater than 1",
                                                        );
                                                      }
                                                      setState(() {
                                                        property4.add(
                                                          property4Controller
                                                              .text
                                                              .toString()
                                                              .toUpperCase(),
                                                        );
                                                        property4Controller
                                                            .clear();
                                                      });
                                                    }
                                                  },
                                                  text: "ADD",
                                                  textColor: primaryDark,
                                                ),
                                              ],
                                            ),
                                  widget2: getNoOfAnswers(4) <= 2
                                      ? Container()
                                      : property4.isNotEmpty
                                          ? SizedBox(
                                              height: 50,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: property4.length,
                                                itemBuilder: ((context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: primaryDark2
                                                            .withOpacity(0.75),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 12,
                                                            ),
                                                            child: Text(
                                                              property4[index],
                                                              style:
                                                                  const TextStyle(
                                                                color: white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              right: 2,
                                                            ),
                                                            child: IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  property4
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .highlight_remove_outlined,
                                                                color: white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            )
                                          : Container(),
                                )
                              : Container(),

                          // PROPERTY 5
                          getPropertiesKeys(5) != ''
                              ? PropertyBox(
                                  headText: getCompulsory(5)
                                      ? "${getPropertiesKeys(5)}*"
                                      : getPropertiesKeys(5),
                                  widget1: getNoOfAnswers(5) == 1
                                      ? TextFormField(
                                          controller: property5Controller,
                                          minLines: 1,
                                          maxLines: getMaxLines(5),
                                          keyboardType:
                                              getPropertiesInputType(5),
                                          decoration: InputDecoration(
                                            hintText: getPropertiesHintText(5),
                                            border: const OutlineInputBorder(),
                                          ),
                                        )
                                      : getNoOfAnswers(5) == 2
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: primary3,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: DropdownButton(
                                                dropdownColor: primary,
                                                hint: const Text("Select"),
                                                value: propertyValue5,
                                                underline: Container(),
                                                items: getDropDownItems(5)
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e.toUpperCase(),
                                                        child: Text(
                                                            e.toUpperCase()),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value != null) {
                                                      propertyValue5 = value;
                                                      property5.clear();
                                                      property5
                                                          .add(propertyValue5!);
                                                    }
                                                  });
                                                },
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller:
                                                        property5Controller,
                                                    keyboardType:
                                                        getPropertiesInputType(
                                                            5),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          getPropertiesHintText(
                                                              5),
                                                      border:
                                                          const OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                MyTextButton(
                                                  onPressed: () {
                                                    if (property5Controller
                                                            .text.isNotEmpty &&
                                                        property5Controller.text
                                                                .toString() !=
                                                            null) {
                                                      if (property5Controller
                                                              .text
                                                              .toString()
                                                              .length <
                                                          2) {
                                                        return mySnackBar(
                                                          context,
                                                          "Answer should be greater than 1",
                                                        );
                                                      }
                                                      setState(() {
                                                        property5.add(
                                                          property5Controller
                                                              .text
                                                              .toString()
                                                              .toUpperCase(),
                                                        );
                                                        property5Controller
                                                            .clear();
                                                      });
                                                    }
                                                  },
                                                  text: "ADD",
                                                  textColor: primaryDark,
                                                ),
                                              ],
                                            ),
                                  widget2: getNoOfAnswers(5) <= 2
                                      ? Container()
                                      : property5.isNotEmpty
                                          ? SizedBox(
                                              height: 50,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: property5.length,
                                                itemBuilder: ((context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: primaryDark2
                                                            .withOpacity(0.75),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 12,
                                                            ),
                                                            child: Text(
                                                              property5[index],
                                                              style:
                                                                  const TextStyle(
                                                                color: white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              right: 2,
                                                            ),
                                                            child: IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  property5
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .highlight_remove_outlined,
                                                                color: white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            )
                                          : Container(),
                                )
                              : Container(),

                          // ADDITIONAL INFO
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: PropertyBox(
                              headText: "Additional Info ?",
                              widget1: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: otherInfoController,
                                    maxLines: 1,
                                    minLines: 1,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                      hintText: "Property Name",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: primaryDark2,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        otherInfo = value;
                                      });
                                    },
                                  ),
                                  SizedBox(height: height * 0.015),
                                  otherInfo != null
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    otherInfoValueController,
                                                maxLines: 1,
                                                minLines: 1,
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: "Value",
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: primaryDark2,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            MyTextButton(
                                              onPressed: () {
                                                addOtherInfoValue();
                                              },
                                              text: "Add Value",
                                              textColor: primaryDark,
                                            ),
                                          ],
                                        )
                                      : Container(),
                                ],
                              ),
                              widget2: otherInfoList.isNotEmpty
                                  ? SizedBox(
                                      height: 50,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: otherInfoList.length,
                                        itemBuilder: ((context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: primaryDark2
                                                    .withOpacity(0.75),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 12,
                                                    ),
                                                    child: Text(
                                                      otherInfoList[index],
                                                      style: const TextStyle(
                                                        color: white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 2,
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        removeOtherInfo(index);
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .highlight_remove_outlined,
                                                        color: white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    )
                                  : Container(),
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
