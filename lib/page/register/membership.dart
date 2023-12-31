// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/models/membership_pricings.dart';
import 'package:find_easy/page/register/firestore_info.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/membership_card.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectMembershipPage extends StatefulWidget {
  const SelectMembershipPage({
    super.key,
    required this.uuid,
  });
  final String uuid;

  @override
  State<SelectMembershipPage> createState() => _SelectMembershipPageState();
}

class _SelectMembershipPageState extends State<SelectMembershipPage> {
  bool isBasicSelected = false;
  bool isGoldSelected = false;
  bool isPremiumSelected = false;
  bool isPaying = false;
  String selectedDuration = "Duration";

  String? selectedPrice = null;
  int? currentBasicPrice = null;
  int? currentGoldPrice = null;
  int? currentPremiumPrice = null;
  String? currentMembership = null;

  @override
  void initState() {
    super.initState();
    isBasicSelected = true;
    isGoldSelected = true;
    isPremiumSelected = true;
  }

  String showPrices(String name) {
    if (selectedDuration != "Duration") {
      if (name == "BASIC") {
        return "0";
      } else if (name == "GOLD") {
        if (selectedDuration == "1 month") {
          return membershipPricing[1][0];
        } else if (selectedDuration == "6 months") {
          return membershipPricing[1][1];
        } else {
          return membershipPricing[1][2];
        }
      } else {
        if (selectedDuration == "1 month") {
          return membershipPricing[2][0];
        } else if (selectedDuration == "6 months") {
          return membershipPricing[2][1];
        } else {
          return membershipPricing[2][2];
        }
      }
    } else {
      return "--";
    }
  }

  void showInfoDialog() {
    showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: Text("Select Membership"),
            content: Text(
              "First select the Duration for which you want the membership\nThen the respective prices will be displayed\nand then select one of them.",
            ),
            actions: [
              MyTextButton(
                onPressed: () {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  Navigator.of(context).pop();
                },
                text: "OK",
                textColor: primaryDark,
              ),
            ],
          )),
    );
  }

  String selectPrice(bool basic, bool gold, bool premium) {
    if (basic) {
      setState(() {
        selectedPrice = currentBasicPrice.toString();
      });
      return selectedPrice!;
    } else if (gold) {
      setState(() {
        selectedPrice = currentGoldPrice.toString();
      });
      return selectedPrice!;
    } else if (premium) {
      setState(() {
        selectedPrice = currentPremiumPrice.toString();
      });
      return selectedPrice!;
    } else {
      setState(() {
        selectedPrice = "null";
      });
      return "null";
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore store = FirebaseFirestore.instance;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 900,
            child: Column(
              children: [
                Expanded(
                  child: Container(),
                  flex: 2,
                ),
                HeadText(text: "MEMBERSHIPS"),
                Expanded(
                  child: Container(),
                  flex: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 1,
                          color: primary2,
                        ),
                      ),
                      child: DropdownButton(
                        autofocus: true,
                        underline:
                            DropdownButtonHideUnderline(child: Container()),
                        borderRadius: BorderRadius.circular(12),
                        hint: Text(selectedDuration),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        elevation: 1,
                        onTap: () {
                          print("ONTAP");
                          isBasicSelected = false;
                          isGoldSelected = false;
                          isPremiumSelected = false;
                        },
                        dropdownColor: primary,
                        items: ["1 month", "6 months", "1 year"]
                            .map(
                              (e) => DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDuration = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: showInfoDialog,
                      icon: Icon(
                        Icons.info_outline,
                        color: primaryDark,
                      ),
                    ),
                    SizedBox(width: 12),
                  ],
                ),
                Expanded(
                  child: Container(),
                  flex: 2,
                ),
                MembershipCard(
                  isSelected: isBasicSelected,
                  selectedColor: white,
                  selectedBorderColor: Colors.black,
                  name: "BASIC",
                  price: showPrices("BASIC"),
                  textColor: Color.fromARGB(255, 61, 60, 60),
                  priceTextColor: const Color.fromARGB(255, 81, 81, 81),
                  benefitBackSelectedColor: Color.fromARGB(255, 196, 196, 196),
                  benefit1: 1,
                  benefit2: 2,
                  benefit3: 3,
                  storageSize: 100,
                  storageUnit: "MB",
                  onTap: () {
                    if (selectedDuration == "Duration") {
                      mySnackBar(context, "Please select a Duration first");
                    } else {
                      setState(() {
                        isBasicSelected = true;
                        isGoldSelected = false;
                        isPremiumSelected = false;
                        currentBasicPrice = int.parse(showPrices("BASIC"));
                        currentMembership = "BASIC";
                      });
                    }
                  },
                ),
                Expanded(
                  child: Container(),
                  flex: 1,
                ),
                MembershipCard(
                  isSelected: isGoldSelected,
                  selectedColor: Color.fromARGB(255, 253, 243, 154),
                  selectedBorderColor: Color.fromARGB(255, 93, 76, 0),
                  name: "GOLD",
                  price: showPrices("GOLD"),
                  textColor: Color.fromARGB(255, 94, 86, 0),
                  priceTextColor: Color.fromARGB(255, 102, 92, 0),
                  benefitBackSelectedColor: Color.fromARGB(255, 200, 182, 19),
                  benefit1: 1,
                  benefit2: 2,
                  benefit3: 3,
                  storageSize: 2,
                  onTap: () {
                    if (selectedDuration == "Duration") {
                      mySnackBar(context, "Please select a Duration first");
                    } else {
                      setState(() {
                        isBasicSelected = false;
                        isGoldSelected = true;
                        isPremiumSelected = false;
                        currentGoldPrice = int.parse(showPrices("GOLD"));
                        currentMembership = "GOLD";
                      });
                    }
                  },
                  // }),
                ),
                Expanded(
                  child: Container(),
                  flex: 1,
                ),
                MembershipCard(
                  isSelected: isPremiumSelected,
                  selectedColor: Color.fromARGB(255, 202, 226, 238),
                  selectedBorderColor: Colors.blueGrey.shade600,
                  name: "PREMIUM",
                  price: showPrices("PREMIUM"),
                  textColor: Color.fromARGB(255, 43, 72, 87),
                  priceTextColor: Color.fromARGB(255, 67, 92, 106),
                  benefitBackSelectedColor: Color.fromARGB(255, 112, 140, 157),
                  benefit1: 1,
                  benefit2: 2,
                  benefit3: 3,
                  storageSize: 5,
                  onTap: () {
                    if (selectedDuration == "Duration") {
                      mySnackBar(context, "Please select a Duration first");
                    } else {
                      setState(() {
                        isBasicSelected = false;
                        isGoldSelected = false;
                        isPremiumSelected = true;
                        currentPremiumPrice = int.parse(showPrices("PREMIUM"));
                        currentMembership = "PREMIUM";
                      });
                    }
                  },
                ),
                Expanded(
                  child: Container(),
                  flex: 2,
                ),
                MyButton(
                  text: selectPrice(isBasicSelected, isGoldSelected,
                                  isPremiumSelected) !=
                              null &&
                          selectPrice(isBasicSelected, isGoldSelected,
                                  isPremiumSelected) !=
                              "null"
                      ? "Pay - ${selectPrice(isBasicSelected, isGoldSelected, isPremiumSelected)}"
                      : "❌❌",
                  onTap: () async {
                    if (isGoldSelected && isPremiumSelected ||
                        isPremiumSelected && isBasicSelected ||
                        isBasicSelected && isGoldSelected ||
                        isBasicSelected &&
                            isGoldSelected &&
                            isPremiumSelected &&
                            selectedPrice == null ||
                        selectedPrice == "null") {
                      mySnackBar(context, "Please select a Membership");
                    } else {
                      if (currentMembership != null) {
                        if (currentMembership == "BASIC") {
                          setState(() {
                            selectedPrice = showPrices("BASIC");
                          });
                        } else if (currentMembership == "GOLD") {
                          setState(() {
                            selectedPrice = showPrices("GOLD");
                          });
                        } else if (currentMembership == "PREMIUM") {
                          setState(() {
                            selectedPrice = showPrices("PREMIUM");
                          });
                        }
                        try {
                          setState(() {
                            isPaying = true;
                          });
                          // Pay
                          BusinessFirestoreData.addAll({
                            'MembershipName': currentMembership.toString(),
                            'MembershipDuration': selectedDuration.toString(),
                            'MembershipTime': DateTime.now().toString(),
                          });
                          print(UserFirestoreData);
                          await store
                              .collection('Business')
                              .doc('Owners')
                              .collection('Users')
                              .doc(widget.uuid)
                              .set(UserFirestoreData);
                          await store
                              .collection('Business')
                              .doc('Owners')
                              .collection('Shops')
                              .doc(widget.uuid)
                              .set(BusinessFirestoreData);
                          setState(() {
                            isPaying = false;
                          });
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                          Navigator.of(context).popAndPushNamed('/profile');
                        } catch (e) {
                          setState(() {
                            isPaying = false;
                          });
                          // Error
                          mySnackBar(context, e.toString());
                        }
                      } else {
                        mySnackBar(context, "Please select a Membership");
                      }
                    }
                  },
                  isLoading: isPaying,
                  horizontalPadding: 40,
                ),
                Expanded(
                  child: Container(),
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
