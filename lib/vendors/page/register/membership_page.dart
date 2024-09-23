// ignore_for_file: unnecessary_null_comparison
import 'dart:convert';
import 'package:Localsearch/widgets/show_loading_dialog.dart';
import 'package:Localsearch/widgets/text_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Localsearch/vendors/page/main/main_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/my_button.dart';
import 'package:Localsearch/widgets/membership_card.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class SelectMembershipPage extends StatefulWidget {
  const SelectMembershipPage({
    super.key,
    required this.hasAvailedLaunchOffer,
  });

  final bool hasAvailedLaunchOffer;

  @override
  State<SelectMembershipPage> createState() => _SelectMembershipPageState();
}

class _SelectMembershipPageState extends State<SelectMembershipPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final leaderCodeController = TextEditingController();
  Map<String, List<String>> membershipDurations = {};
  Map<String, String> membershipReverseDurations = {};
  Map<String, Map<String, dynamic>> membershipDetails = {};
  Map<String, Map<String, dynamic>> membershipQuota = {};
  Map<String, dynamic>? offerData;
  String? selectedMembership;
  String? selectedDuration;
  String? selectedPrice;
  DateTime? selectedDurationDateTime;
  int? currentPrice;
  bool isAvailingOffer = false;
  bool isOffer = false;
  bool isPaying = false;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    if (!widget.hasAvailedLaunchOffer) {
      getOffersData();
    }
    super.initState();
    getMembershipData();
  }

  // GET OFFERS DATA
  Future<void> getOffersData() async {
    String address = '';

    // GET LOCATION
    Future<Position?> getLocation() async {
      LocationPermission permission = await Geolocator.checkPermission();

      while (true) {
        bool isLocationServiceEnabled =
            await Geolocator.isLocationServiceEnabled();
        if (!isLocationServiceEnabled) {
          await Geolocator.openLocationSettings();
          return Future.error('Location services are disabled.');
        }

        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            continue;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location permissions are permanently denied. Enable them in Settings.',
                style: const TextStyle(
                  color: Color.fromARGB(255, 240, 252, 255),
                ),
              ),
              action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () async {
                  await Geolocator.openAppSettings();
                },
                textColor: primary2,
              ),
              elevation: 2,
              backgroundColor: primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dismissDirection: DismissDirection.down,
              behavior: SnackBarBehavior.floating,
            ),
          );
          await Future.delayed(Duration(seconds: 1));
          continue;
        }

        return await Geolocator.getCurrentPosition();
      }
    }

    // GET ADDRESS
    Future<String> getAddress(double shopLatitude, double shopLongitude) async {
      const apiKey = 'AIzaSyA-CD3MgDBzAsjmp_FlDbofynMMmW6fPsU';
      final apiUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$shopLatitude,$shopLongitude&key=$apiKey';

      try {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' && data['results'].isNotEmpty) {
            final results = data['results'] as List;

            for (var result in results) {
              final addressComponents =
                  result['address_components'] as List<dynamic>;

              for (var component in addressComponents) {
                final types = component['types'] as List<dynamic>;

                if (types.contains('administrative_area_level_3')) {
                  final districtName = component['long_name'];
                  return districtName;
                }
              }
            }

            return '';
          } else {
            if (mounted) {
              mySnackBar(context, 'Failed to get address');
            }
            return '';
          }
        } else {
          if (mounted) {
            mySnackBar(context, 'Failed to load data');
          }
          return '';
        }
      } catch (e) {
        if (mounted) {
          mySnackBar(context, e.toString());
        }
        return '';
      }
    }

    await getLocation().then((coordinates) async {
      if (coordinates != null) {
        address = await getAddress(coordinates.latitude, coordinates.longitude);
      }
    });

    final offerSnap = await store
        .collection('Offers')
        .where('city', isEqualTo: address)
        .where('expiry', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('discount', descending: true)
        .get();

    if (offerSnap.docs.isNotEmpty) {
      Map<String, dynamic> myOffers = {};
      final highestOffer = offerSnap.docs[0];

      final currentOfferData = highestOffer.data();

      myOffers = currentOfferData;

      setState(() {
        isOffer = true;
        offerData = myOffers;
      });
    } else {
      setState(() {
        isOffer = false;
      });
    }
  }

  // GET MEMBERSHIP DATA
  Future<void> getMembershipData() async {
    // DURATION
    final durationSnapshot =
        await store.collection('Membership').doc('Duration').get();
    if (durationSnapshot.exists) {
      Map<String, dynamic> durationData = durationSnapshot.data()!;

      membershipDurations = {'durations': []};

      durationData.forEach((key, value) {
        if (value != null) {
          membershipDurations['durations']!.add(value as String);
        }
      });
    }

    // REVERSE DURATION
    final reverseDurationSnapshot =
        await store.collection('Membership').doc('Reverse Duration').get();
    if (reverseDurationSnapshot.exists) {
      Map<String, dynamic> reverseDurationData =
          reverseDurationSnapshot.data()!;

      membershipReverseDurations = {};

      reverseDurationData.forEach((key, value) {
        if (value != null) {
          membershipReverseDurations[key] = value as String;
        }
      });
    }

    final membershipTypeSnap =
        await store.collection('Membership').doc('Membership Types').get();

    final membershipTypesData = membershipTypeSnap.data()!;

    // MEMBERSHIP
    final membershipTypes = membershipTypesData['membershipTypes'];
    for (String membershipType in membershipTypes) {
      final membershipSnapshot =
          await store.collection('Membership').doc(membershipType).get();
      if (membershipSnapshot.exists) {
        Map<String, dynamic> membershipData = membershipSnapshot.data()!;

        membershipDetails[membershipType] = {
          'benefits': membershipData['benefits'],
          'charges': {},
          'discount': membershipData['discount'],
        };

        int? discount = membershipDetails[membershipType]!['discount'];

        membershipData.forEach((key, value) {
          if (key.startsWith('duration') && value != null) {
            int originalPrice = value;
            double discountedPrice = originalPrice.toDouble();

            if (discount != null && discount > 0) {
              discountedPrice = originalPrice * (1 - (discount / 100));
            }

            discountedPrice = roundToNearest49or99(discountedPrice);

            membershipDetails[membershipType]!['charges']![key] = [
              discountedPrice,
              originalPrice
            ];
          }
        });
      }
    }

    setState(() {
      isData = true;
    });
  }

  // SHOW BENEFITS
  String? showBenefits(String name, String benefitNo) {
    Map benefits = membershipDetails[name]!['benefits'];
    final reverseDuration = showReverseDuration(selectedDuration!);
    return benefits[benefitNo]?[reverseDuration];
  }

  // SHOW PRICES
  int? showPrices(String name) {
    Map charges = membershipDetails[name]?['charges'];
    final reverseDuration = showReverseDuration(selectedDuration!);
    return charges[reverseDuration]?[1].toInt();
  }

  // SHOW DISCOUNT
  double? showDiscount(String name) {
    String? internalKey = membershipReverseDurations[selectedDuration];
    List? prices = membershipDetails[name]?['charges']?[internalKey];
    if (prices != null) {
      double originalPrice = prices[1].toDouble();
      double discount = membershipDetails[name]?['discount']?.toDouble() ?? 0;
      double discountedPrice = originalPrice * (1 - (discount / 100));
      return roundToNearest49or99(discountedPrice);
    }
    return null;
  }

  // SHOW REVERSE DURATION
  String? showReverseDuration(String duration) {
    if (membershipReverseDurations.containsKey(duration)) {
      return membershipReverseDurations[duration]!;
    } else {
      return 'Unknown Duration';
    }
  }

  // ROUND TO NEAREST 49 OR 99
  double roundToNearest49or99(double price) {
    int priceInt = price.toInt();
    int lastTwoDigits = priceInt % 100;

    if (price < 49) {
      return 0;
    } else if (lastTwoDigits > 49) {
      return (priceInt - lastTwoDigits + 99).toDouble();
    } else {
      return (priceInt - lastTwoDigits + 49).toDouble();
    }
  }

  // SHOW INFO DIALOG
  Future<void> showInfoDialog() async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            'Select Membership',
          ),
          content: const Text(
            'First select the Duration for which you want the membership\nThen the respective prices will be displayed\nand then select one of them.',
          ),
          actions: [
            MyTextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'OK',
            ),
          ],
        );
      }),
    );
  }

  // PAY
  Future<void> pay(final width) async {
    if (selectedMembership == null && !isAvailingOffer) {
      mySnackBar(
        context,
        'Please select a Membership',
      );
    } else if (isAvailingOffer) {
      setState(() {
        isPaying = true;
      });
      try {
        if (leaderCodeController.text.isNotEmpty) {
          final leaderSnap = await store
              .collection('Leaders')
              .doc(leaderCodeController.text.toLowerCase())
              .get();

          if (leaderSnap.exists) {
            final leaderData = leaderSnap.data()!;

            var amount = leaderData['Amount'];

            amount = amount + currentPrice;

            await store
                .collection('Leaders')
                .doc(leaderCodeController.text.toLowerCase())
                .update({
              'Amount': amount,
            });
          } else {
            setState(() {
              isPaying = false;
            });
            return mySnackBar(
              context,
              'Leader Code Doesn\'t Exists, Check Again',
            );
          }
        }

        // GET MEMBERSHIP DURATION
        Duration getMembershipDuration(String membershipDuration) {
          final now = DateTime.now();

          if (membershipDuration == '10 Days') {
            return Duration(days: 10);
          } else if (membershipDuration == '1 Month') {
            return DateTime(now.year, now.month + 1, now.day).difference(now);
          } else if (membershipDuration == '3 Months') {
            return DateTime(now.year, now.month + 3, now.day).difference(now);
          } else if (membershipDuration == '6 Months') {
            return DateTime(now.year, now.month + 6, now.day).difference(now);
          } else if (membershipDuration == '1 Year') {
            return DateTime(now.year + 1, now.month, now.day).difference(now);
          } else {
            return Duration.zero;
          }
        }

        final String membershipName = offerData!['membership'];
        final String membershipDuration = offerData!['duration'];
        final Duration membershipDurationDateTime =
            getMembershipDuration(membershipDuration);
        final DateTime membershipEndDateTime =
            DateTime.now().add(membershipDurationDateTime);

        final membershipSnap =
            await store.collection('Membership').doc(selectedMembership).get();

        final membershipData = membershipSnap.data()!;

        final productGallery = membershipData['productGallery'];
        final noOfShorts = membershipData['noOfShorts'];

        final vendorDoc = await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid);

        final vendorSnap = await vendorDoc.get();

        final vendorData = vendorSnap.data()!;
        final currentNoOfShorts = vendorData['noOfShorts'];
        final currentProductGallery = vendorData['productGallery'];

        if (currentNoOfShorts == null && currentProductGallery == null) {
          await vendorDoc.update({
            'MembershipName': membershipName,
            'MembershipDuration': membershipDuration,
            'MembershipStartDateTime': DateTime.now(),
            'MembershipEndDateTime': membershipEndDateTime,
            'productGallery': productGallery,
            'noOfShorts': noOfShorts,
          });
        } else {
          await vendorDoc.update({
            'MembershipName': membershipName,
            'MembershipDuration': membershipDuration,
            'MembershipStartDateTime': DateTime.now(),
            'MembershipEndDateTime': membershipEndDateTime,
            'productGallery': currentProductGallery + productGallery,
            'noOfShorts': currentNoOfShorts + noOfShorts,
          });
        }

        setState(() {
          isPaying = false;
        });
        if (auth.currentUser != null) {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainPage(),
              ),
              (route) => false,
            );
          }
        }
      } catch (e) {
        setState(() {
          isPaying = false;
        });
        if (context.mounted) {
          return mySnackBar(context, e.toString());
        }
      }
    } else {
      if (selectedMembership != null) {
        setState(() {
          selectedPrice = showPrices(selectedMembership!).toString();
          isPaying = true;
        });
        try {
          if (leaderCodeController.text.isNotEmpty) {
            final leaderSnap = await store
                .collection('Leaders')
                .doc(leaderCodeController.text.toLowerCase())
                .get();

            if (leaderSnap.exists) {
              final leaderData = leaderSnap.data()!;

              var amount = leaderData['Amount'];

              amount = amount + currentPrice;

              await store
                  .collection('Leaders')
                  .doc(leaderCodeController.text.toLowerCase())
                  .update({
                'Amount': amount,
              });
            } else {
              setState(() {
                isPaying = false;
              });
              return mySnackBar(
                context,
                'Leader Code Doesn\'t Exists, Check Again',
              );
            }
          }

          final membershipSnap = await store
              .collection('Membership')
              .doc(selectedMembership)
              .get();

          final membershipData = membershipSnap.data()!;

          final productGallery = membershipData['quota']
              [showReverseDuration(selectedDuration!)]['productGallery'];

          final noOfShorts = membershipData['quota']
              [showReverseDuration(selectedDuration!)]['noOfShorts'];

          final maxImages = membershipData['maxImages'];

          final vendorDoc = await store
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(auth.currentUser!.uid);

          final vendorSnap = await vendorDoc.get();

          final vendorData = vendorSnap.data()!;
          final currentNoOfShorts = vendorData['noOfShorts'];
          final currentProductGallery = vendorData['productGallery'];

          if (currentNoOfShorts == null && currentProductGallery == null) {
            await vendorDoc.update({
              'MembershipName': selectedMembership,
              'MembershipDuration': selectedDuration,
              'MembershipStartDateTime': DateTime.now(),
              'MembershipEndDateTime': selectedDurationDateTime,
              'productGallery': productGallery,
              'noOfShorts': noOfShorts,
              'maxImages': maxImages,
            });
          } else {
            await vendorDoc.update({
              'MembershipName': selectedMembership,
              'MembershipDuration': selectedDuration,
              'MembershipStartDateTime': DateTime.now(),
              'MembershipEndDateTime': selectedDurationDateTime,
              'productGallery': currentProductGallery + productGallery,
              'noOfShorts': currentNoOfShorts + noOfShorts,
              'maxImages': maxImages,
            });
          }

          setState(() {
            isPaying = false;
          });
          if (auth.currentUser != null) {
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainPage(),
                ),
                (route) => false,
              );
            }
          }
        } catch (e) {
          setState(() {
            isPaying = false;
          });
          if (context.mounted) {
            return mySnackBar(context, e.toString());
          }
        }
      } else {
        return mySnackBar(
          context,
          'Please select a Membership',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Select Membership'),
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
                  subject: 'Localsearch Feedback',
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
        ],
      ),
      bottomSheet: // PAY BUTTON
          selectedDuration == 'Duration' && !isAvailingOffer
              ? Container()
              : Container(
                  width: width,
                  height: height * 0.07875,
                  margin: EdgeInsets.only(bottom: width * 0.0225),
                  child: MyButton(
                    text: isAvailingOffer
                        ? 'CONTINUE FREE'
                        : currentPrice != null
                            ? 'Pay - $currentPrice'
                            : '❌❌',
                    onTap: () async {
                      await showLoadingDialog(
                        context,
                        () async {
                          await pay(width);
                        },
                      );
                    },
                    horizontalPadding: width * 0.01125,
                  ),
                ),
      body: isData == false || isOffer == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEADER CODE
                    widget.hasAvailedLaunchOffer
                        ? Container()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyTextFormField(
                                hintText: 'Leader Code',
                                controller: leaderCodeController,
                                borderRadius: 12,
                                horizontalPadding: width * 0.025,
                              ),
                              Divider(),
                            ],
                          ),

                    // OFFER
                    !isOffer
                        ? Container()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: width * 0.033),
                                child: Text(
                                  'Launch Offer',
                                  style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 63, 63, 63),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.006125),
                              SizedBox(
                                width: width,
                                child: Builder(
                                  builder: (context) {
                                    final offerName = offerData!['name'];
                                    final offerMembership =
                                        offerData!['membership'];
                                    final offerDuration =
                                        offerData!['duration'];
                                    final lightColor =
                                        offerMembership == 'Basic'
                                            ? white
                                            : offerMembership == 'Gold'
                                                ? const Color.fromARGB(
                                                    255,
                                                    253,
                                                    243,
                                                    154,
                                                  )
                                                : const Color.fromARGB(
                                                    255,
                                                    202,
                                                    226,
                                                    238,
                                                  );
                                    final darkColor = offerMembership == 'Basic'
                                        ? black
                                        : offerMembership == 'Gold'
                                            ? const Color.fromARGB(
                                                255,
                                                93,
                                                76,
                                                0,
                                              )
                                            : Colors.blueGrey.shade600;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isAvailingOffer = !isAvailingOffer;
                                          selectedMembership = null;
                                          // isPremiumSelected = false;
                                        });
                                      },
                                      child: Opacity(
                                        opacity: isAvailingOffer ? 1 : 0.9,
                                        child: Container(
                                          width: width,
                                          decoration: BoxDecoration(
                                            color: lightColor,
                                            border: Border.all(
                                              width: isAvailingOffer ? 3 : 1,
                                              color: darkColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding:
                                              EdgeInsets.all(width * 0.025),
                                          margin: EdgeInsets.all(
                                            width *
                                                (isAvailingOffer
                                                    ? 0.025
                                                    : 0.04),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                offerName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: darkColor,
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: offerMembership,
                                                      style: TextStyle(
                                                        color: darkColor,
                                                        fontSize: width * 0.066,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: ' Membership',
                                                      style: TextStyle(
                                                        color: darkColor,
                                                        fontSize: width * 0.06,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Duration: ',
                                                      style: TextStyle(
                                                        color: darkColor,
                                                        fontSize: width * 0.055,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: offerDuration,
                                                      style: TextStyle(
                                                        color: darkColor,
                                                        fontSize: width * 0.06,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'FREE',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: darkColor,
                                                      fontSize: width * 0.0675,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  MyTextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        isAvailingOffer =
                                                            !isAvailingOffer;
                                                        selectedMembership =
                                                            null;
                                                        // isPremiumSelected = false;
                                                      });
                                                    },
                                                    text: isAvailingOffer
                                                        ? 'SELECTED'
                                                        : 'Select',
                                                    textColor: darkColor,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Divider(),
                            ],
                          ),

                    // MEMBERSHIPS
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.033),
                      child: Text(
                        'Memberships',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 63, 63, 63),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.006125),

                    // DURATION & INFO
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
                                selectedDuration ?? 'DURATION',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              elevation: 1,
                              onTap: () {
                                selectedMembership = null;
                                // isPremiumSelected = false;
                              },
                              dropdownColor: primary2,
                              items: membershipDurations['durations']!
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDuration = value!;
                                  final now = DateTime.now();

                                  if (value == '1 Month') {
                                    selectedDurationDateTime = DateTime(
                                      now.year,
                                      now.month + 1,
                                      now.day,
                                    );
                                  } else if (value == '3 Months') {
                                    selectedDurationDateTime = DateTime(
                                      now.year,
                                      now.month + 3,
                                      now.day,
                                    );
                                  } else if (value == '6 Months') {
                                    selectedDurationDateTime = DateTime(
                                      now.year,
                                      now.month + 6,
                                      now.day,
                                    );
                                  } else if (value == '1 Year') {
                                    selectedDurationDateTime = DateTime(
                                      now.year + 1,
                                      now.month,
                                      now.day,
                                    );
                                  } else if (value == '3 Years') {
                                    selectedDurationDateTime = DateTime(
                                      now.year + 3,
                                      now.month,
                                      now.day,
                                    );
                                  } else {
                                    selectedDurationDateTime = now;
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
                              FeatherIcons.info,
                              color: primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.006125),

                    // REGISTRATION
                    selectedDuration == null
                        ? Container()
                        : MembershipCard(
                            isSelected: selectedMembership == 'Registration',
                            selectedColor: white,
                            selectedBorderColor:
                                const Color.fromARGB(255, 57, 57, 57),
                            name: 'FREE Registration',
                            originalPrice: showPrices('Registration'),
                            discountPrice: showDiscount('Registration'),
                            discount:
                                membershipDetails['Registration']!['discount'],
                            textColor: const Color.fromARGB(255, 61, 60, 60),
                            priceTextColor:
                                const Color.fromARGB(255, 81, 81, 81),
                            benefitBackSelectedColor:
                                const Color.fromARGB(255, 196, 196, 196),
                            benefit1: showBenefits('Registration', 'benefit1'),
                            benefit2: showBenefits('Registration', 'benefit2'),
                            benefit3: showBenefits('Registration', 'benefit3'),
                            benefit4: showBenefits('Registration', 'benefit4'),
                            benefit5: showBenefits('Registration', 'benefit5'),
                            onTap: () {
                              setState(() {
                                isAvailingOffer = false;
                                selectedMembership = 'Registration';
                                // isPremiumSelected = false;
                                currentPrice =
                                    showDiscount('Registration') == null
                                        ? null
                                        : showDiscount('Registration')!.toInt();
                              });
                            },
                          ),

                    // BASIC
                    selectedDuration == null
                        ? Container()
                        : MembershipCard(
                            isSelected: selectedMembership == 'Basic',
                            selectedColor: white,
                            selectedBorderColor: black,
                            name: 'Basic',
                            originalPrice: showPrices('Basic'),
                            discountPrice: showDiscount('Basic'),
                            discount: membershipDetails['Basic']!['discount'],
                            textColor: black,
                            priceTextColor: black,
                            benefitBackSelectedColor: black,
                            benefit1: showBenefits('Basic', 'benefit1'),
                            benefit2: showBenefits('Basic', 'benefit2'),
                            benefit3: showBenefits('Basic', 'benefit3'),
                            benefit4: showBenefits('Basic', 'benefit4'),
                            benefit5: showBenefits('Basic', 'benefit5'),
                            onTap: () {
                              setState(() {
                                isAvailingOffer = false;
                                selectedMembership = 'Basic';
                                // isPremiumSelected = false;
                                currentPrice = showDiscount('Basic') == null
                                    ? null
                                    : showDiscount('Basic')!.toInt();
                              });
                            },
                          ),

                    // GOLD
                    selectedDuration == null
                        ? Container()
                        : MembershipCard(
                            isSelected: selectedMembership == 'Gold',
                            selectedColor:
                                const Color.fromARGB(255, 253, 243, 154),
                            selectedBorderColor:
                                const Color.fromARGB(255, 93, 76, 0),
                            name: 'Gold',
                            originalPrice: showPrices('Gold'),
                            discountPrice: showDiscount('Gold'),
                            discount: membershipDetails['Gold']!['discount'],
                            textColor: const Color.fromARGB(255, 94, 86, 0),
                            priceTextColor:
                                const Color.fromARGB(255, 102, 92, 0),
                            benefitBackSelectedColor:
                                const Color.fromARGB(255, 200, 182, 19),
                            benefit1: showBenefits('Gold', 'benefit1'),
                            benefit2: showBenefits('Gold', 'benefit2'),
                            benefit3: showBenefits('Gold', 'benefit3'),
                            benefit4: showBenefits('Gold', 'benefit4'),
                            benefit5: showBenefits('Gold', 'benefit5'),
                            // storageSize: 2,
                            onTap: () {
                              setState(() {
                                isAvailingOffer = false;
                                selectedMembership = 'Gold';
                                // isPremiumSelected = false;
                                currentPrice = showDiscount('Gold') == null
                                    ? null
                                    : showDiscount('Gold')!.toInt();
                              });
                            },
                          ),

                    // PREMIUM
                    // selectedDuration == null
                    //     ? Container()
                    //     : Padding(
                    //         padding: EdgeInsets.only(bottom: width * 0.175),
                    //         child: MembershipCard(
                    //           isSelected: isPremiumSelected,
                    //           selectedColor:
                    //               const Color.fromARGB(255, 202, 226, 238),
                    //           selectedBorderColor: Colors.blueGrey.shade600,
                    //           name: 'Premium',
                    //           originalPrice: showPrices('Premium'),
                    //           discountPrice: showDiscount('Premium'),
                    //           discount:
                    //               membershipDetails['Premium']!['discount'],
                    //           textColor:
                    //               const Color.fromARGB(255, 43, 72, 87),
                    //           priceTextColor:
                    //               const Color.fromARGB(255, 67, 92, 106),
                    //           benefitBackSelectedColor:
                    //               const Color.fromARGB(255, 112, 140, 157),
                    //           benefit1: showBenefits('Premium', 'benefit1'),
                    //           benefit2: showBenefits('Premium', 'benefit2'),
                    //           benefit3: showBenefits('Premium', 'benefit3'),
                    //           benefit4: showBenefits('Premium', 'benefit4'),
                    //           benefit5: showBenefits('Premium', 'benefit5'),
                    //           // storageSize: 5,
                    //           onTap: () {
                    //             setState(() {
                    //               isAvailingOffer = false;
                    //               selectedMembership = 'Premium';
                    //               currentPrice =
                    //                   showDiscount('Premium') == null
                    //                       ? null
                    //                       : showDiscount('Premium')!.toInt();
                    //             });
                    //           },
                    //         ),
                    //       ),
                  ],
                ),
              ),
            ),
    );
  }
}
