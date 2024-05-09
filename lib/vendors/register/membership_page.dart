// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/vendors/models/membership_no_of_plans.dart';
import 'package:find_easy/vendors/models/membership_pricings.dart';
import 'package:find_easy/vendors/page/main/main_page.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/membership_card.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectMembershipPage extends StatefulWidget {
  const SelectMembershipPage({
    super.key,
  });

  @override
  State<SelectMembershipPage> createState() => _SelectMembershipPageState();
}

class _SelectMembershipPageState extends State<SelectMembershipPage> {
  final FirebaseFirestore store = FirebaseFirestore.instance;
  bool isBasicSelected = false;
  bool isGoldSelected = false;
  bool isPremiumSelected = false;
  bool isPaying = false;
  String selectedDuration = "Duration";
  DateTime? selectedDurationDateTime;

  String? selectedPrice;
  int? currentBasicPrice;
  int? currentGoldPrice;
  int? currentPremiumPrice;
  String? currentMembership;

  @override
  void initState() {
    super.initState();
    isBasicSelected = true;
    isGoldSelected = true;
    isPremiumSelected = true;
  }

  // SHOW PRICES
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

  // SHOW INFO DIALOG
  Future<void> showInfoDialog() async {
    await showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: const Text(
              overflow: TextOverflow.ellipsis,
              "Select Membership",
            ),
            content: const Text(
              overflow: TextOverflow.ellipsis,
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

  // SELECT PRICE
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
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: width * 0.1),
              const HeadText(
                text: "SELECT\nMEMBERSHIP",
              ),
              SizedBox(height: width * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // DURATION DROP DOWN
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.033),
                    child: Container(
                      decoration: BoxDecoration(
                        color: primary2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 1,
                          color: primary2,
                        ),
                      ),
                      child: DropdownButton(
                        autofocus: true,
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(12),
                        hint: Text(
                            overflow: TextOverflow.ellipsis, selectedDuration),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        elevation: 1,
                        onTap: () {
                          isBasicSelected = false;
                          isGoldSelected = false;
                          isPremiumSelected = false;
                        },
                        dropdownColor: primary2,
                        items: ["1 month", "6 months", "1 year"]
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(overflow: TextOverflow.ellipsis, e),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDuration = value!;
                            if (value == '1 month') {
                              selectedDurationDateTime = DateTime.now().add(
                                const Duration(
                                  days: 28,
                                ),
                              );
                            } else if (value == '6 months') {
                              selectedDurationDateTime = DateTime.now().add(
                                const Duration(
                                  days: 168,
                                ),
                              );
                            } else if (value == '1 year') {
                              selectedDurationDateTime = DateTime.now().add(
                                const Duration(
                                  days: 336,
                                ),
                              );
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  // INFO ICON
                  Padding(
                    padding: EdgeInsets.only(right: width * 0.033),
                    child: IconButton(
                      onPressed: () async {
                        await showInfoDialog();
                      },
                      icon: const Icon(
                        Icons.info_outline,
                        color: primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.025),

              // BASIC
              MembershipCard(
                isSelected: isBasicSelected,
                selectedColor: white,
                selectedBorderColor: Colors.black,
                name: "BASIC",
                price: showPrices(
                  "BASIC",
                ),
                textColor: const Color.fromARGB(255, 61, 60, 60),
                priceTextColor: const Color.fromARGB(255, 81, 81, 81),
                benefitBackSelectedColor:
                    const Color.fromARGB(255, 196, 196, 196),
                width: width,
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

              // GOLD
              MembershipCard(
                isSelected: isGoldSelected,
                selectedColor: const Color.fromARGB(255, 253, 243, 154),
                selectedBorderColor: const Color.fromARGB(255, 93, 76, 0),
                name: "GOLD",
                price: showPrices(
                  "GOLD",
                ),
                textColor: const Color.fromARGB(255, 94, 86, 0),
                priceTextColor: const Color.fromARGB(255, 102, 92, 0),
                benefitBackSelectedColor:
                    const Color.fromARGB(255, 200, 182, 19),
                width: width,
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
              ),

              // PREMIUM
              LayoutBuilder(
                builder: (context, constraints) {
                  return MembershipCard(
                    isSelected: isPremiumSelected,
                    selectedColor: const Color.fromARGB(255, 202, 226, 238),
                    selectedBorderColor: Colors.blueGrey.shade600,
                    name: "PREMIUM",
                    price: showPrices(
                      "PREMIUM",
                    ),
                    textColor: const Color.fromARGB(255, 43, 72, 87),
                    priceTextColor: const Color.fromARGB(255, 67, 92, 106),
                    benefitBackSelectedColor:
                        const Color.fromARGB(255, 112, 140, 157),
                    width: constraints.maxWidth,
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
                          currentPremiumPrice = int.parse(
                            showPrices("PREMIUM"),
                          );
                          currentMembership = "PREMIUM";
                        });
                      }
                    },
                  );
                },
              ),

              // PAY BUTTON
              Padding(
                padding: EdgeInsets.only(bottom: width * 0.0225),
                child: MyButton(
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

                          await store
                              .collection('Business')
                              .doc('Owners')
                              .collection('Shops')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            'MembershipName': currentMembership.toString(),
                            'MembershipDuration': selectedDuration.toString(),
                            'MembershipTime': DateTime.now().toString(),
                            'MembershipEndDateTime': selectedDurationDateTime,
                            'noOfTextPosts': membershipNoOfPlans[
                                currentMembership]!['textPost'],
                            'noOfImagePosts': membershipNoOfPlans[
                                currentMembership]!['imagePost'],
                            'noOfShorts': membershipNoOfPlans[
                                currentMembership]!['shorts'],
                          });

                          setState(() {
                            isPaying = false;
                          });
                          if (FirebaseAuth.instance.currentUser != null) {
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const MainPage()),
                                (route) => false,
                              );
                            }
                          }
                        } catch (e) {
                          setState(() {
                            isPaying = false;
                          });
                          // Error
                          if (context.mounted) {
                            mySnackBar(context, e.toString());
                          }
                        }
                      } else {
                        mySnackBar(context, "Please select a Membership");
                      }
                    }
                  },
                  isLoading: isPaying,
                  horizontalPadding: width * 0.01125,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
