import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/page/main/add/product/add_product_page_5.dart';
import 'package:ls_business/vendors/provider/add_product_provider.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/additional_info_box.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class AddProductPage4 extends StatefulWidget {
  const AddProductPage4({
    super.key,
    required this.shopType,
    required this.category,
  });

  final String shopType;
  final String category;

  @override
  State<AddProductPage4> createState() => _AddProductPage4State();
}

class _AddProductPage4State extends State<AddProductPage4> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Map<String, dynamic> properties = {};
  final GlobalKey<FormState> productKey = GlobalKey<FormState>();
  final tagController = TextEditingController();
  final otherInfoController = TextEditingController();
  final otherInfoValueController = TextEditingController();
  String? otherInfo;
  Map<String, dynamic>? householdCategoryProperties;
  final property0Controller = TextEditingController();
  final property1Controller = TextEditingController();
  final property2Controller = TextEditingController();
  final property3Controller = TextEditingController();
  final property4Controller = TextEditingController();
  final property5Controller = TextEditingController();
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
  bool isSaving = false;
  bool isDialog = false;

  // INIT STATE
  @override
  void initState() {
    getCategoryProperties();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    tagController.dispose();
    otherInfoController.dispose();
    otherInfoValueController.dispose();
    property0Controller.dispose();
    property1Controller.dispose();
    property2Controller.dispose();
    property3Controller.dispose();
    property4Controller.dispose();
    property5Controller.dispose();
    super.dispose();
  }

  // GET CATEGORY PROPERTIES
  Future<void> getCategoryProperties() async {
    final categoryPropertySnap = await store
        .collection('Shop Types And Category Data')
        .doc('Category Properties')
        .get();

    final categoryPropertyData = categoryPropertySnap.data()!;

    final categoryProperties = categoryPropertyData['categoryPropertiesData'];

    setState(() {
      householdCategoryProperties = categoryProperties;
    });
  }

  // ADD TAG
  void addTag() {
    if (tagController.text.toString().trim().length > 1) {
      if (!tagList
          .contains(tagController.text.toString().trim().toUpperCase())) {
        setState(() {
          tagList.insert(0, tagController.text.toString().trim().toUpperCase());
          tagController.clear();
        });
      } else {
        tagController.clear();
        mySnackBar(context, 'This Tag has already been added');
      }
    } else {
      mySnackBar(context, 'Tag should be atleast 2 chars long');
    }
  }

  // REMOVE TAG
  void removeTag(int index) {
    setState(() {
      tagList.removeAt(index);
    });
  }

  // ADD OTHER INFO
  void addOtherInfoValue() {
    if (otherInfoValueController.text.toString().trim().length > 1) {
      setState(() {
        otherInfoList.add(otherInfoValueController.text.toString().trim());
      });
      otherInfoValueController.clear();
    } else {
      mySnackBar(context, 'Value length should be greater than 1');
    }
  }

  // REMOVE OTHER INFO
  void removeOtherInfo(int index) {
    setState(() {
      otherInfoList.removeAt(index);
    });
  }

  // ADD PRODUCT
  void addProduct(AddProductProvider provider) {
    if (productKey.currentState!.validate()) {
      if (property0.isEmpty && getCompulsory(0)) {
        if (getNoOfAnswers(0) == 1) {
          if (property0Controller.text.toString().trim().isEmpty) {
            return mySnackBar(
                context, 'Enter value for ${getPropertiesKeys(0)}');
          }
          property0
              .add(property0Controller.text.toString().trim().toUpperCase());
        } else if (getNoOfAnswers(0) == 2) {
          return mySnackBar(context, 'Select ${getPropertiesKeys(0)}');
        } else if (getNoOfAnswers(0) == 3) {
          return mySnackBar(
              context, 'Add atleast one value to ${getPropertiesKeys(0)}');
        }
      }
      if (property1.isEmpty && getCompulsory(1)) {
        if (getNoOfAnswers(1) == 1) {
          if (property1Controller.text.toString().trim().isEmpty) {
            return mySnackBar(
                context, 'Enter value for ${getPropertiesKeys(1)}');
          }
          property1
              .add(property1Controller.text.toString().trim().toUpperCase());
        } else if (getNoOfAnswers(1) == 2) {
          return mySnackBar(context, 'Select ${getPropertiesKeys(1)}');
        } else if (getNoOfAnswers(1) == 3) {
          return mySnackBar(
              context, 'Add atleast one value to ${getPropertiesKeys(1)}');
        }
      }
      if (property2.isEmpty && getCompulsory(2)) {
        if (getNoOfAnswers(2) == 1) {
          if (property2Controller.text.toString().trim().isEmpty) {
            return mySnackBar(
                context, 'Enter value for ${getPropertiesKeys(2)}');
          }
          property2
              .add(property2Controller.text.toString().trim().toUpperCase());
        } else if (getNoOfAnswers(2) == 2) {
          return mySnackBar(context, 'Select ${getPropertiesKeys(2)}');
        } else if (getNoOfAnswers(2) == 3) {
          return mySnackBar(
              context, 'Add atleast one value to ${getPropertiesKeys(2)}');
        }
      }
      if (property3.isEmpty && getCompulsory(3)) {
        if (getNoOfAnswers(3) == 1) {
          if (property3Controller.text.toString().trim().isEmpty) {
            return mySnackBar(
                context, 'Enter value for ${getPropertiesKeys(3)}');
          }
          property3
              .add(property3Controller.text.toString().trim().toUpperCase());
        } else if (getNoOfAnswers(3) == 2) {
          return mySnackBar(context, 'Select ${getPropertiesKeys(3)}');
        } else if (getNoOfAnswers(3) == 3) {
          return mySnackBar(
              context, 'Add atleast one value to ${getPropertiesKeys(3)}');
        }
      }
      if (property4.isEmpty && getCompulsory(4)) {
        if (getNoOfAnswers(4) == 1) {
          if (property4Controller.text.toString().trim().isEmpty) {
            return mySnackBar(
                context, 'Enter value for ${getPropertiesKeys(4)}');
          }
          property4
              .add(property4Controller.text.toString().trim().toUpperCase());
        } else if (getNoOfAnswers(4) == 2) {
          return mySnackBar(context, 'Select ${getPropertiesKeys(4)}');
        } else if (getNoOfAnswers(4) == 3) {
          return mySnackBar(
              context, 'Add atleast one value to ${getPropertiesKeys(4)}');
        }
      }
      if (property5.isEmpty && getCompulsory(5)) {
        if (getNoOfAnswers(5) == 1) {
          if (property5Controller.text.toString().trim().isEmpty) {
            return mySnackBar(
                context, 'Enter value for ${getPropertiesKeys(5)}');
          }
          property5
              .add(property5Controller.text.toString().trim().toUpperCase());
        } else if (getNoOfAnswers(5) == 2) {
          return mySnackBar(context, 'Select ${getPropertiesKeys(5)}');
        } else if (getNoOfAnswers(5) == 3) {
          return mySnackBar(
              context, 'Add atleast one value to ${getPropertiesKeys(5)}');
        }
      }

      try {
        setState(() {
          isSaving = true;
          isDialog = true;
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
          'propertyInputType0':
              getPropertiesInputType(0) == TextInputType.text ||
                  getPropertiesInputType(0) == TextInputType.name,
          'propertyInputType1':
              getPropertiesInputType(1) == TextInputType.text ||
                  getPropertiesInputType(1) == TextInputType.name,
          'propertyInputType2':
              getPropertiesInputType(2) == TextInputType.text ||
                  getPropertiesInputType(2) == TextInputType.name,
          'propertyInputType3':
              getPropertiesInputType(3) == TextInputType.text ||
                  getPropertiesInputType(3) == TextInputType.name,
          'propertyInputType4':
              getPropertiesInputType(4) == TextInputType.text ||
                  getPropertiesInputType(4) == TextInputType.name,
          'propertyInputType5':
              getPropertiesInputType(5) == TextInputType.text ||
                  getPropertiesInputType(5) == TextInputType.name,
        });

        // await store
        //     .collection('Business')
        //     .doc('Data')
        //     .collection('Products')
        //     .doc(widget.productId)
        //     .set(provider.productInfo);

        // await store
        //     .collection('Business')
        //     .doc('Data')
        //     .collection('Products')
        //     .doc(widget.productId)
        //     .update({
        //   'Properties': properties,
        //   'Tags': tagList,
        // });

        provider.add(
          {
            'Properties': properties,
            'Tags': tagList,
          },
          true,
        );

        setState(() {
          isSaving = false;
          isDialog = false;
        });
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddProductPage5(),
            ),
          );
        }
      } catch (e) {
        setState(() {
          isSaving = false;
          isDialog = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  // GET PROPERTIES KEYS
  String getPropertiesKeys(int index) {
    return householdCategoryProperties![widget.shopType]!
        .keys
        .toList()[index]
        .toString()
        .trim();
  }

  // GET PROPERTIES HINT TEXT
  String getPropertiesHintText(int index) {
    return householdCategoryProperties![widget.shopType]!
        .values
        .toList()[index]['hintText']
        .toString()
        .trim();
  }

  // GET NO. OF ANSWERS
  int getNoOfAnswers(int index) {
    return householdCategoryProperties![widget.shopType]!.values.toList()[index]
        ['noOfAnswers'];
  }

  // GET DROP DOWN ITEMS
  List getDropDownItems(int index) {
    return householdCategoryProperties![widget.shopType]!.values.toList()[index]
        ['dropDownItems'];
  }

  // GET PROPERTIES INPUT TYPE
  TextInputType getPropertiesInputType(int index) {
    final number = householdCategoryProperties![widget.shopType]!
        .values
        .toList()[index]['inputType'];
    if (number == 2) {
      return TextInputType.datetime;
    } else if (number == 1) {
      return TextInputType.number;
    } else {
      return TextInputType.name;
    }
  }

  // GET MAX LINES
  int getMaxLines(int index) {
    return householdCategoryProperties![widget.shopType]!.values.toList()[index]
        ['maxLines'];
  }

  // GET CHANGE BOOL
  bool getChangeBool(int index) {
    if (getNoOfAnswers(index) == 1 || getNoOfAnswers(index) == 3) {
      return true;
    } else {
      return false;
    }
  }

  // GET COMPULSORY
  bool getCompulsory(int index) {
    return householdCategoryProperties![widget.shopType]!.values.toList()[index]
        ['compulsory'];
  }

  @override
  Widget build(BuildContext context) {
    final addProductProvider = Provider.of<AddProductProvider>(context);

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 0.5,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Additional Info'),
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
              MyTextButton(
                onTap: () {
                  addProduct(addProductProvider);
                },
                text: 'NEXT',
                textColor: primaryDark2,
              ),
            ],
          ),
          body: householdCategoryProperties == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: primaryDark,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    return SingleChildScrollView(
                      child: Form(
                        key: productKey,
                        child: Column(
                          children: [
                            const Text(
                              'Properties marked with \' * \' are compulsory to fill',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryDark2,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),

                            // TAGS
                            PropertyBox(
                              headText: 'Tags (Recommended)',
                              widget1: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: tagController,
                                      onTapOutside: (event) =>
                                          FocusScope.of(context).unfocus(),
                                      maxLength: 16,
                                      maxLines: 1,
                                      minLines: 1,
                                      decoration: const InputDecoration(
                                        hintText: 'Product Tags',
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
                                    onTap: addTag,
                                    text: 'Add',
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
                                        physics: const ClampingScrollPhysics(),
                                        itemCount: tagList.length,
                                        itemBuilder: (context, index) {
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
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                        },
                                      ),
                                    )
                                  : Container(),
                            ),

                            // PROPERTY 0
                            getPropertiesKeys(0) != '2' &&
                                    getPropertiesKeys(0) != '0' &&
                                    getPropertiesKeys(0) != '1'
                                ? PropertyBox(
                                    headText: getCompulsory(0)
                                        ? '${getPropertiesKeys(0)}*'
                                        : getPropertiesKeys(0),
                                    widget1: getNoOfAnswers(0) == 1
                                        ? TextFormField(
                                            controller: property0Controller,
                                            onTapOutside: (event) =>
                                                FocusScope.of(context)
                                                    .unfocus(),
                                            maxLines: getMaxLines(0),
                                            minLines: 1,
                                            keyboardType:
                                                getPropertiesInputType(0),
                                            decoration: InputDecoration(
                                              hintText:
                                                  getPropertiesHintText(0),
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                          )
                                        : getNoOfAnswers(0) == 2
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.0225,
                                                  vertical: width * 0.0125,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: primary3,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: DropdownButton(
                                                  dropdownColor: primary3,
                                                  hint: const Text(
                                                    'Select',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  value: propertyValue0,
                                                  underline: Container(),
                                                  items: getDropDownItems(0)
                                                      .map(
                                                        (e) => DropdownMenuItem(
                                                          value:
                                                              e.toUpperCase(),
                                                          child: Text(
                                                            e
                                                                .toString()
                                                                .trim()
                                                                .toUpperCase(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (value != null) {
                                                        propertyValue0 =
                                                            value.toString();
                                                        property0.clear();
                                                        property0.add(
                                                            propertyValue0!);
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
                                                      onTapOutside: (event) =>
                                                          FocusScope.of(context)
                                                              .unfocus(),
                                                      keyboardType:
                                                          getPropertiesInputType(
                                                              0),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            getPropertiesHintText(
                                                                0),
                                                        border:
                                                            const OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  MyTextButton(
                                                    onTap: () {
                                                      if (property0Controller
                                                          .text
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty) {
                                                        if (property0Controller
                                                                .text
                                                                .toString()
                                                                .trim()
                                                                .length <
                                                            2) {
                                                          return mySnackBar(
                                                            context,
                                                            'Answer should be greater than 1',
                                                          );
                                                        }
                                                        setState(() {
                                                          property0.insert(
                                                            0,
                                                            property0Controller
                                                                .text
                                                                .toString()
                                                                .trim()
                                                                .toUpperCase(),
                                                          );
                                                          property0Controller
                                                              .clear();
                                                        });
                                                      }
                                                    },
                                                    text: 'ADD',
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
                                                  physics:
                                                      const ClampingScrollPhysics(),
                                                  itemCount: property0.length,
                                                  itemBuilder:
                                                      ((context, index) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                        vertical: 2,
                                                      ),
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primaryDark2
                                                              .withOpacity(
                                                                  0.75),
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
                                                                property0[index]
                                                                    .toString()
                                                                    .trim(),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
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
                                                                icon:
                                                                    const Icon(
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
                            getPropertiesKeys(1) != '2' &&
                                    getPropertiesKeys(1) != '0' &&
                                    getPropertiesKeys(1) != '1'
                                ? PropertyBox(
                                    headText: getCompulsory(1)
                                        ? '${getPropertiesKeys(1)}*'
                                        : getPropertiesKeys(1),
                                    widget1: getNoOfAnswers(1) == 1
                                        ? TextFormField(
                                            controller: property1Controller,
                                            onTapOutside: (event) =>
                                                FocusScope.of(context)
                                                    .unfocus(),
                                            maxLines: getMaxLines(1),
                                            minLines: 1,
                                            keyboardType:
                                                getPropertiesInputType(1),
                                            decoration: InputDecoration(
                                              hintText:
                                                  getPropertiesHintText(1),
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                          )
                                        : getNoOfAnswers(1) == 2
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.0225,
                                                  vertical: width * 0.0125,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: primary3,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: DropdownButton(
                                                  dropdownColor: primary3,
                                                  hint: const Text(
                                                    'Select',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  value: propertyValue1,
                                                  underline: Container(),
                                                  items: getDropDownItems(1)
                                                      .map(
                                                        (e) => DropdownMenuItem(
                                                          value:
                                                              e.toUpperCase(),
                                                          child: Text(
                                                            e
                                                                .toString()
                                                                .trim()
                                                                .toUpperCase(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (value != null) {
                                                        propertyValue1 =
                                                            value.toString();
                                                        property1.clear();
                                                        property1.add(
                                                            propertyValue1!);
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
                                                      onTapOutside: (event) =>
                                                          FocusScope.of(context)
                                                              .unfocus(),
                                                      keyboardType:
                                                          getPropertiesInputType(
                                                              1),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            getPropertiesHintText(
                                                                1),
                                                        border:
                                                            const OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  MyTextButton(
                                                    onTap: () {
                                                      if (property1Controller
                                                          .text.isNotEmpty) {
                                                        if (property1Controller
                                                                .text
                                                                .toString()
                                                                .trim()
                                                                .length <
                                                            2) {
                                                          return mySnackBar(
                                                            context,
                                                            'Answer should be greater than 1',
                                                          );
                                                        }
                                                        setState(() {
                                                          property1.insert(
                                                            0,
                                                            property1Controller
                                                                .text
                                                                .toString()
                                                                .trim()
                                                                .toUpperCase(),
                                                          );
                                                          property1Controller
                                                              .clear();
                                                        });
                                                      }
                                                    },
                                                    text: 'ADD',
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
                                                  physics:
                                                      const ClampingScrollPhysics(),
                                                  itemCount: property1.length,
                                                  itemBuilder:
                                                      ((context, index) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                        vertical: 2,
                                                      ),
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primaryDark2
                                                              .withOpacity(
                                                                  0.75),
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
                                                                property1[index]
                                                                    .toString()
                                                                    .trim(),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
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
                                                                icon:
                                                                    const Icon(
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
                            getPropertiesKeys(2) != '2' &&
                                    getPropertiesKeys(2) != '0' &&
                                    getPropertiesKeys(2) != '1'
                                ? PropertyBox(
                                    headText: getCompulsory(2)
                                        ? '${getPropertiesKeys(2)}*'
                                        : getPropertiesKeys(2),
                                    widget1: getNoOfAnswers(2) == 1
                                        ? TextFormField(
                                            controller: property2Controller,
                                            onTapOutside: (event) =>
                                                FocusScope.of(context)
                                                    .unfocus(),
                                            maxLines: getMaxLines(2),
                                            minLines: 1,
                                            keyboardType:
                                                getPropertiesInputType(2),
                                            decoration: InputDecoration(
                                              hintText:
                                                  getPropertiesHintText(2),
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                          )
                                        : getNoOfAnswers(2) == 2
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.0225,
                                                  vertical: width * 0.0125,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: primary3,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: DropdownButton(
                                                  dropdownColor: primary3,
                                                  hint: const Text(
                                                    'Select',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  value: propertyValue2,
                                                  underline: Container(),
                                                  items: getDropDownItems(2)
                                                      .map(
                                                        (e) => DropdownMenuItem(
                                                          value:
                                                              e.toUpperCase(),
                                                          child: Text(
                                                            e
                                                                .toString()
                                                                .trim()
                                                                .toUpperCase(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (value != null) {
                                                        propertyValue2 =
                                                            value.toString();
                                                        property2.clear();
                                                        property2.add(
                                                            propertyValue2!);
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
                                                      onTapOutside: (event) =>
                                                          FocusScope.of(context)
                                                              .unfocus(),
                                                      keyboardType:
                                                          getPropertiesInputType(
                                                              2),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            getPropertiesHintText(
                                                                2),
                                                        border:
                                                            const OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  MyTextButton(
                                                    onTap: () {
                                                      if (property2Controller
                                                          .text.isNotEmpty) {
                                                        if (property2Controller
                                                                .text
                                                                .toString()
                                                                .trim()
                                                                .length <
                                                            2) {
                                                          return mySnackBar(
                                                            context,
                                                            'Answer should be greater than 1',
                                                          );
                                                        }
                                                        setState(() {
                                                          property2.insert(
                                                            0,
                                                            property2Controller
                                                                .text
                                                                .toString()
                                                                .trim()
                                                                .toUpperCase(),
                                                          );
                                                          property2Controller
                                                              .clear();
                                                        });
                                                      }
                                                    },
                                                    text: 'ADD',
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
                                                  physics:
                                                      const ClampingScrollPhysics(),
                                                  itemCount: property2.length,
                                                  itemBuilder:
                                                      ((context, index) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                        vertical: 2,
                                                      ),
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primaryDark2
                                                              .withOpacity(
                                                                  0.75),
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
                                                                property2[index]
                                                                    .toString()
                                                                    .trim(),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
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
                                                                icon:
                                                                    const Icon(
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
                            getPropertiesKeys(3) != '2' &&
                                    getPropertiesKeys(3) != '0' &&
                                    getPropertiesKeys(3) != '1'
                                ? PropertyBox(
                                    headText: getCompulsory(3)
                                        ? '${getPropertiesKeys(3)}*'
                                        : getPropertiesKeys(3),
                                    widget1: getNoOfAnswers(3) == 1
                                        ? TextFormField(
                                            controller: property3Controller,
                                            onTapOutside: (event) =>
                                                FocusScope.of(context)
                                                    .unfocus(),
                                            maxLines: getMaxLines(3),
                                            minLines: 1,
                                            keyboardType:
                                                getPropertiesInputType(3),
                                            decoration: InputDecoration(
                                              hintText:
                                                  getPropertiesHintText(3),
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                          )
                                        : getNoOfAnswers(3) == 2
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.0225,
                                                  vertical: width * 0.0125,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: primary3,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: DropdownButton(
                                                  dropdownColor: primary3,
                                                  hint: const Text(
                                                    'Select',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  value: propertyValue3,
                                                  underline: Container(),
                                                  items: getDropDownItems(3)
                                                      .map(
                                                        (e) => DropdownMenuItem(
                                                          value:
                                                              e.toUpperCase(),
                                                          child: Text(
                                                            e
                                                                .toString()
                                                                .trim()
                                                                .toUpperCase(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (value != null) {
                                                        propertyValue3 =
                                                            value.toString();
                                                        property3.clear();
                                                        property3.add(
                                                            propertyValue3!);
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
                                                      onTapOutside: (event) =>
                                                          FocusScope.of(context)
                                                              .unfocus(),
                                                      keyboardType:
                                                          getPropertiesInputType(
                                                              3),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            getPropertiesHintText(
                                                                3),
                                                        border:
                                                            const OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  MyTextButton(
                                                    onTap: () {
                                                      if (property3Controller
                                                          .text
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty) {
                                                        if (property3Controller
                                                                .text
                                                                .toString()
                                                                .trim()
                                                                .length <
                                                            2) {
                                                          return mySnackBar(
                                                            context,
                                                            'Answer should be greater than 1',
                                                          );
                                                        }
                                                        setState(() {
                                                          property3.insert(
                                                            0,
                                                            property3Controller
                                                                .text
                                                                .toString()
                                                                .trim()
                                                                .toUpperCase(),
                                                          );
                                                          property3Controller
                                                              .clear();
                                                        });
                                                      }
                                                    },
                                                    text: 'ADD',
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
                                                  physics:
                                                      const ClampingScrollPhysics(),
                                                  itemCount: property3.length,
                                                  itemBuilder:
                                                      ((context, index) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                        vertical: 2,
                                                      ),
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primaryDark2
                                                              .withOpacity(
                                                                  0.75),
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
                                                                property3[index]
                                                                    .toString()
                                                                    .trim(),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
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
                                                                icon:
                                                                    const Icon(
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
                            getPropertiesKeys(4) != '2' &&
                                    getPropertiesKeys(4) != '0' &&
                                    getPropertiesKeys(4) != '1'
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      bottom: getPropertiesKeys(4) != '2' &&
                                              getPropertiesKeys(4) != '0' &&
                                              getPropertiesKeys(4) != '1'
                                          ? MediaQuery.sizeOf(context).width
                                          : 0,
                                    ),
                                    child: PropertyBox(
                                      headText: getCompulsory(4)
                                          ? '${getPropertiesKeys(4)}*'
                                          : getPropertiesKeys(4),
                                      widget1: getNoOfAnswers(4) == 1
                                          ? TextFormField(
                                              controller: property4Controller,
                                              onTapOutside: (event) =>
                                                  FocusScope.of(context)
                                                      .unfocus(),
                                              maxLines: getMaxLines(4),
                                              minLines: 1,
                                              keyboardType:
                                                  getPropertiesInputType(4),
                                              decoration: InputDecoration(
                                                hintText:
                                                    getPropertiesHintText(4),
                                                border:
                                                    const OutlineInputBorder(),
                                              ),
                                            )
                                          : getNoOfAnswers(4) == 2
                                              ? Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: width * 0.0225,
                                                    vertical: width * 0.0125,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: primary3,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: DropdownButton(
                                                    dropdownColor: primary3,
                                                    hint: const Text(
                                                      'Select',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    value: propertyValue4,
                                                    underline: Container(),
                                                    items: getDropDownItems(4)
                                                        .map(
                                                          (e) =>
                                                              DropdownMenuItem(
                                                            value:
                                                                e.toUpperCase(),
                                                            child: Text(
                                                              e
                                                                  .toString()
                                                                  .trim()
                                                                  .toUpperCase(),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        if (value != null) {
                                                          propertyValue4 =
                                                              value.toString();
                                                          property4.clear();
                                                          property4.add(
                                                              propertyValue4!);
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
                                                        onTapOutside: (event) =>
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus(),
                                                        keyboardType:
                                                            getPropertiesInputType(
                                                                4),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              getPropertiesHintText(
                                                                  4),
                                                          border:
                                                              const OutlineInputBorder(),
                                                        ),
                                                      ),
                                                    ),
                                                    MyTextButton(
                                                      onTap: () {
                                                        if (property4Controller
                                                            .text
                                                            .toString()
                                                            .trim()
                                                            .isNotEmpty) {
                                                          if (property4Controller
                                                                  .text
                                                                  .toString()
                                                                  .trim()
                                                                  .length <
                                                              2) {
                                                            return mySnackBar(
                                                              context,
                                                              'Answer should be greater than 1',
                                                            );
                                                          }
                                                          setState(() {
                                                            property4.insert(
                                                              0,
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
                                                      text: 'ADD',
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
                                                    physics:
                                                        const ClampingScrollPhysics(),
                                                    itemCount: property4.length,
                                                    itemBuilder:
                                                        ((context, index) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: primaryDark2
                                                                .withOpacity(
                                                                    0.75),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
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
                                                                  property4[
                                                                          index]
                                                                      .toString()
                                                                      .trim(),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      const TextStyle(
                                                                    color:
                                                                        white,
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
                                                                child:
                                                                    IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      property4
                                                                          .removeAt(
                                                                              index);
                                                                    });
                                                                  },
                                                                  icon:
                                                                      const Icon(
                                                                    Icons
                                                                        .highlight_remove_outlined,
                                                                    color:
                                                                        white,
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
                                  )
                                : Container(),

                            // PROPERTY 5
                            getPropertiesKeys(5) != '2' &&
                                    getPropertiesKeys(5) != '0' &&
                                    getPropertiesKeys(5) != '1'
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      bottom: getPropertiesKeys(5) != '2' &&
                                              getPropertiesKeys(5) != '0' &&
                                              getPropertiesKeys(5) != '1'
                                          ? MediaQuery.sizeOf(context).width
                                          : 0,
                                    ),
                                    child: PropertyBox(
                                      headText: getCompulsory(5)
                                          ? '${getPropertiesKeys(5)}*'
                                          : getPropertiesKeys(5),
                                      widget1: getNoOfAnswers(5) == 1
                                          ? TextFormField(
                                              controller: property5Controller,
                                              onTapOutside: (event) =>
                                                  FocusScope.of(context)
                                                      .unfocus(),
                                              maxLines: getMaxLines(5),
                                              minLines: 1,
                                              keyboardType:
                                                  getPropertiesInputType(5),
                                              decoration: InputDecoration(
                                                hintText:
                                                    getPropertiesHintText(5),
                                                border:
                                                    const OutlineInputBorder(),
                                              ),
                                            )
                                          : getNoOfAnswers(5) == 2
                                              ? Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: width * 0.0225,
                                                    vertical: width * 0.0125,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: primary3,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: DropdownButton(
                                                    dropdownColor: primary3,
                                                    hint: const Text(
                                                      'Select',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    value: propertyValue5,
                                                    underline: Container(),
                                                    items: getDropDownItems(5)
                                                        .map(
                                                          (e) =>
                                                              DropdownMenuItem(
                                                            value:
                                                                e.toUpperCase(),
                                                            child: Text(
                                                              e
                                                                  .toString()
                                                                  .trim()
                                                                  .toUpperCase(),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        if (value != null) {
                                                          propertyValue5 =
                                                              value.toString();
                                                          property5.clear();
                                                          property5.add(
                                                              propertyValue5!);
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
                                                        onTapOutside: (event) =>
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus(),
                                                        keyboardType:
                                                            getPropertiesInputType(
                                                                5),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              getPropertiesHintText(
                                                                  5),
                                                          border:
                                                              const OutlineInputBorder(),
                                                        ),
                                                      ),
                                                    ),
                                                    MyTextButton(
                                                      onTap: () {
                                                        if (property5Controller
                                                            .text
                                                            .toString()
                                                            .trim()
                                                            .isNotEmpty) {
                                                          if (property5Controller
                                                                  .text
                                                                  .toString()
                                                                  .trim()
                                                                  .length <
                                                              2) {
                                                            return mySnackBar(
                                                              context,
                                                              'Answer should be greater than 1',
                                                            );
                                                          }
                                                          setState(() {
                                                            property5.insert(
                                                              0,
                                                              property5Controller
                                                                  .text
                                                                  .toString()
                                                                  .trim()
                                                                  .toUpperCase(),
                                                            );
                                                            property5Controller
                                                                .clear();
                                                          });
                                                        }
                                                      },
                                                      text: 'ADD',
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
                                                    physics:
                                                        const ClampingScrollPhysics(),
                                                    itemCount: property5.length,
                                                    itemBuilder:
                                                        ((context, index) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: primaryDark2
                                                                .withOpacity(
                                                                    0.75),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
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
                                                                  property5[
                                                                          index]
                                                                      .toString()
                                                                      .trim(),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      const TextStyle(
                                                                    color:
                                                                        white,
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
                                                                child:
                                                                    IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      property5
                                                                          .removeAt(
                                                                        index,
                                                                      );
                                                                    });
                                                                  },
                                                                  icon:
                                                                      const Icon(
                                                                    Icons
                                                                        .highlight_remove_outlined,
                                                                    color:
                                                                        white,
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
                                  )
                                : Container(),

                            // ADDITIONAL INFO
                            // Padding(
                            //   padding: EdgeInsets.only(
                            //     bottom: MediaQuery.of(context).viewInsets.bottom,
                            //   ),
                            //   child: PropertyBox(
                            //     headText: 'Additional Info ?',
                            //     widget1: Column(
                            //       mainAxisAlignment: MainAxisAlignment.start,
                            //       children: [
                            //         TextFormField(
                            //           controller: otherInfoController,
                            //           maxLines: 1,
                            //           minLines: 1,
                            //           keyboardType: TextInputType.text,
                            //           onTapOutside: (event) =>
                            //               FocusScope.of(context).unfocus(),
                            //           decoration: const InputDecoration(
                            //             hintText: 'Property Name',
                            //             border: OutlineInputBorder(
                            //               borderSide: BorderSide(
                            //                 color: primaryDark2,
                            //                 width: 2,
                            //               ),
                            //             ),
                            //           ),
                            //           onChanged: (value) {
                            //             setState(() {
                            //               otherInfo = value;
                            //             });
                            //           },
                            //         ),
                            //         const SizedBox(height: 12),
                            //         otherInfo != null
                            //             ? Row(
                            //                 crossAxisAlignment:
                            //                     CrossAxisAlignment.start,
                            //                 children: [
                            //                   Expanded(
                            //                     child: TextFormField(
                            //                       controller:
                            //                           otherInfoValueController,
                            //                       onTapOutside: (event) =>
                            //                           FocusScope.of(context)
                            //                               .unfocus(),
                            //                       maxLines: 1,
                            //                       minLines: 1,
                            //                       keyboardType:
                            //                           TextInputType.text,
                            //                       decoration:
                            //                           const InputDecoration(
                            //                         hintText: 'Value',
                            //                         border: OutlineInputBorder(
                            //                           borderSide: BorderSide(
                            //                             color: primaryDark2,
                            //                             width: 2,
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   MyTextButton(
                            //                     onPressed: () {
                            //                       addOtherInfoValue();
                            //                     },
                            //                     text: 'Add Value',
                            //                   ),
                            //                 ],
                            //               )
                            //             : Container(),
                            //       ],
                            //     ),
                            //     widget2: otherInfoList.isNotEmpty
                            //         ? SizedBox(
                            //             height: 50,
                            //             child: ListView.builder(
                            //               scrollDirection: Axis.horizontal,
                            //               shrinkWrap: true,
                            //               physics: ClampingScrollPhysics(),
                            //               itemCount: otherInfoList.length,
                            //               itemBuilder: ((context, index) {
                            //                 return Padding(
                            //                   padding: const EdgeInsets.symmetric(
                            //                     horizontal: 4,
                            //                     vertical: 2,
                            //                   ),
                            //                   child: Container(
                            //                     alignment: Alignment.center,
                            //                     decoration: BoxDecoration(
                            //                       color: primaryDark2
                            //                           .withOpacity(0.75),
                            //                       borderRadius:
                            //                           BorderRadius.circular(16),
                            //                     ),
                            //                     child: Row(
                            //                       mainAxisAlignment:
                            //                           MainAxisAlignment.center,
                            //                       children: [
                            //                         Padding(
                            //                           padding:
                            //                               const EdgeInsets.only(
                            //                             left: 12,
                            //                           ),
                            //                           child: Text(
                            //                             otherInfoList[index].toString().trim(),
                            //                             maxLines: 1,
                            //                             overflow:
                            //                                 TextOverflow.ellipsis,
                            //                             style: const TextStyle(
                            //                               color: white,
                            //                               fontWeight:
                            //                                   FontWeight.bold,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                         Padding(
                            //                           padding:
                            //                               const EdgeInsets.only(
                            //                             right: 2,
                            //                           ),
                            //                           child: IconButton(
                            //                             onPressed: () {
                            //                               removeOtherInfo(index);
                            //                             },
                            //                             icon: const Icon(
                            //                               Icons
                            //                                   .highlight_remove_outlined,
                            //                               color: white,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ],
                            //                     ),
                            //                   ),
                            //                 );
                            //               }),
                            //             ),
                            //           )
                            //         : Container(),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
        ),
      ),
    );
  }
}
