import 'package:Localsearch/vendors/page/main/analytics/products_analytics_page.dart';
import 'package:Localsearch/vendors/page/main/analytics/shop_analytics_page.dart';
import 'package:Localsearch/vendors/provider/main_page_provider.dart';
import 'package:Localsearch/vendors/page/register/membership_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool? isRegistration;

  // INIT STATE
  @override
  void initState() {
    getVendorData();
    super.initState();
  }

  // GET VENDOR DATA
  Future<void> getVendorData() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final membershipName = vendorData['MembershipName'];

    setState(() {
      if (membershipName == 'Registration') {
        isRegistration = true;
      } else {
        isRegistration = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainPageProvider = Provider.of<MainPageProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final TabController tabController = TabController(
      initialIndex: 1,
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 400),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        mainPageProvider.goToHomePage();
      },
      child: isRegistration == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : isRegistration!
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'You are currently using \'FREE Registration\' Membership\nThis membership allows you to register your shop details & catalogue only\nThis does not allows you to see analytics\nGet a paid membership to get benefits',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    MyTextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SelectMembershipPage(
                              hasAvailedLaunchOffer: true,
                            ),
                          ),
                        );
                      },
                      text: 'CHANGE',
                    ),
                  ],
                )
              : Scaffold(
                  backgroundColor: primary,
                  appBar: AppBar(
                    title: const Text(
                      'ANALYTICS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          BetterFeedback.of(context).show((feedback) async {
                            Future<String> writeImageToStorage(
                                Uint8List feedbackScreenshot) async {
                              final Directory output =
                                  await getTemporaryDirectory();
                              final String screenshotFilePath =
                                  '${output.path}/feedback.png';
                              final File screenshotFile =
                                  File(screenshotFilePath);
                              await screenshotFile
                                  .writeAsBytes(feedbackScreenshot);
                              return screenshotFilePath;
                            }

                            final screenshotFilePath =
                                await writeImageToStorage(feedback.screenshot);

                            final Email email = Email(
                              body: feedback.text,
                              subject: 'LS Business Feedback',
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
                    forceMaterialTransparency: true,
                    bottom: PreferredSize(
                      preferredSize: Size(
                        width,
                        width * 0.1,
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: primary2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primaryDark.withOpacity(0.8),
                          ),
                        ),
                        isScrollable: false,
                        indicatorPadding: EdgeInsets.only(
                          bottom: width * 0.0266,
                          top: width * 0.0225,
                          left: -width * 0.045,
                          right: -width * 0.045,
                        ),
                        automaticIndicatorColorAdjustment: false,
                        indicatorWeight: 2,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: primaryDark,
                        labelStyle: const TextStyle(
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                        ),
                        dividerColor: primary,
                        indicatorColor: primaryDark,
                        controller: tabController,
                        tabs: const [
                          Tab(
                            text: 'SHOP',
                          ),
                          Tab(
                            text: 'PRODUCTS',
                          ),
                        ],
                      ),
                    ),
                  ),
                  body: TabBarView(
                    controller: tabController,
                    children: const [
                      ShopAnalyticsPage(),
                      ProductAnalyticsPage(),
                    ],
                  ),
                ),
    );
  }
}
