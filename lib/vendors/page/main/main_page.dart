import 'package:ls_business/auth/sign_in_page.dart';
import 'package:ls_business/under_development_page.dart';
import 'package:ls_business/vendors/provider/main_page_provider.dart';
import 'package:ls_business/vendors/page/register/business_select_categories_page.dart';
import 'package:ls_business/vendors/page/register/business_select_products_page.dart';
import 'package:ls_business/vendors/page/register/business_social_media_page.dart';
import 'package:ls_business/vendors/page/register/business_timings_page.dart';
import 'package:ls_business/vendors/page/register/get_location_page.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/page/main/add/add_page.dart';
import 'package:ls_business/vendors/page/main/analytics/analytics_page.dart';
import 'package:ls_business/vendors/page/main/discount/add_discount_page.dart';
import 'package:ls_business/vendors/page/main/profile/profile_page.dart';
import 'package:ls_business/vendors/page/register/business_select_shop_types_page.dart';
import 'package:ls_business/vendors/page/register/business_register_details_page.dart';
import 'package:ls_business/vendors/page/register/membership_page.dart';
import 'package:ls_business/vendors/page/register/owner_register_details_page.dart';
import 'package:ls_business/auth/verify/email_verify.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Widget? detailsPage;

  // INIT STATE
  @override
  void initState() {
    detailsAdded();
    super.initState();
  }

  // DETAILS ADDED
  Future<void> detailsAdded() async {
    try {
      final developmentSnap =
          await store.collection('Development').doc('Under Development').get();

      final developmentData = developmentSnap.data()!;

      final businessUnderDevelopment =
          developmentData['businessUnderDevelopment'];

      if (businessUnderDevelopment) {
        detailsPage = const UnderDevelopmentPage();
      } else {
        final getUserDetailsAdded = await store
            .collection('Business')
            .doc('Owners')
            .collection('Users')
            .doc(auth.currentUser!.uid)
            .get();

        if (!getUserDetailsAdded.exists) {
          await auth.signOut();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => SignInPage(),
            ),
            (route) => false,
          );
          return mySnackBar(context, 'Signed Out');
        }

        final getUserDetailsAddedData = getUserDetailsAdded.data()!;

        final getBusinessDetailsAdded = await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid)
            .get();

        final getBusinessDetailsAddedData = getBusinessDetailsAdded.data()!;

        if (getUserDetailsAdded.exists && getBusinessDetailsAdded.exists) {
          if (getUserDetailsAddedData['Email'] == null ||
              getUserDetailsAddedData['Phone Number'] == null) {
            detailsPage = const OwnerRegisterDetailsPage(
              fromMainPage: true,
            );
          } else if (getUserDetailsAddedData['Image'] == null) {
            detailsPage = const OwnerRegisterDetailsPage(
              fromMainPage: true,
            );
          } /* else if (getUserDetailsAddedData['Registration'] ==
                  'phone number' &&
              getUserDetailsAddedData['numberVerified'] == false) {
            detailsPage = NumberVerifyPage(
              phoneNumber: getUserDetailsAddedData['Phone Number'],
              fromMainPage: true,
              isLogging: false,
            );
          }*/
          else if (auth.currentUser!.email != null &&
              !auth.currentUser!.emailVerified) {
            detailsPage = const EmailVerifyPage(
              // mode: 'vendor',
              fromMainPage: true,
            );
          } else if (getBusinessDetailsAddedData['Name'] == null ||
              getBusinessDetailsAddedData['Latitude'] == null ||
              getBusinessDetailsAddedData['Description'] == null) {
            detailsPage = const BusinessRegisterDetailsPage(
              fromMainPage: true,
            );
          } else if (getBusinessDetailsAddedData['Instagram'] == null ||
              getBusinessDetailsAddedData['Facebook'] == null ||
              getBusinessDetailsAddedData['Website'] == null) {
            detailsPage = BusinessSocialMediaPage(
              isChanging: true,
              instagram: getBusinessDetailsAddedData['Instagram'],
              facebook: getBusinessDetailsAddedData['Facebook'],
              website: getBusinessDetailsAddedData['Website'],
              fromMainPage: true,
            );
          } else if (getBusinessDetailsAddedData['Instagram'] != null &&
              getBusinessDetailsAddedData['Type'] == null) {
            detailsPage = const BusinessChooseShopTypesPage(
              isEditing: true,
            );
          } else if (getBusinessDetailsAddedData['Type'] != null &&
              getBusinessDetailsAddedData['Categories'] == null) {
            detailsPage = BusinessChooseCategoriesPage(
              selectedTypes: getBusinessDetailsAddedData['Type'],
              isEditing: true,
            );
          } else if (getBusinessDetailsAddedData['Categories'] != null &&
              getBusinessDetailsAddedData['Products'] == null) {
            detailsPage = BusinessChooseProductsPage(
              selectedTypes: getBusinessDetailsAddedData['Type'],
              selectedCategories: getBusinessDetailsAddedData['Categories'],
              isEditing: true,
            );
          } else if (getBusinessDetailsAddedData['City'] == null ||
              getBusinessDetailsAddedData['Latitude'] == null) {
            detailsPage = const GetLocationPage();
          } else if (getBusinessDetailsAddedData['weekdayStartTime'] == null ||
              getBusinessDetailsAddedData['weekdayEndTime'] == null) {
            detailsPage = const SelectBusinessTimingsPage(
              fromMainPage: true,
            );
          } else if (getUserDetailsAddedData['Image'] != null &&
              getUserDetailsAddedData['AadhaarNumber'] != null &&
              (getBusinessDetailsAddedData['MembershipName'] == null ||
                  getBusinessDetailsAddedData['MembershipEndDateTime'] ==
                      null)) {
            detailsPage = const SelectMembershipPage(
              hasAvailedLaunchOffer: false,
            );
          } else if (DateTime.now().isAfter(
              (getBusinessDetailsAddedData['MembershipEndDateTime']
                      as Timestamp)
                  .toDate())) {
            detailsPage = const SelectMembershipPage(
              hasAvailedLaunchOffer: true,
            );
            if (mounted) {
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Your Membership Has Expired'),
                    content: const Text('Select New Membership to continue'),
                    actions: [
                      MyTextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        text: 'OK',
                        textColor: Colors.green,
                      ),
                    ],
                  );
                },
              );
            }
          } else {
            detailsPage = null;
          }
          // }
        } else {
          await auth.signOut();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const SignInPage(),
              ),
              (route) => false,
            );
            return mySnackBar(
              context,
              'This account was created in User app, use another account to use here',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mainPageProvider = Provider.of<MainPageProvider>(context);
    final loadedPages = mainPageProvider.loadedPages;
    final current = mainPageProvider.index;

    List<Widget> allPages = [
      loadedPages.contains(0) ? const AnalyticsPage() : Container(),
      loadedPages.contains(1) ? const AddPage() : Container(),
      loadedPages.contains(2) ? const AddDiscountPage() : Container(),
      const ProfilePage(),
    ];

    return detailsPage ??
        Scaffold(
          body: IndexedStack(
            index: current,
            children: allPages,
          ),
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            backgroundColor: white,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: primaryDark,
            ),
            useLegacyColorScheme: false,
            type: BottomNavigationBarType.fixed,
            selectedIconTheme: const IconThemeData(
              size: 24,
              color: primaryDark,
            ),
            unselectedIconTheme: IconThemeData(
              size: 24,
              color: black.withOpacity(0.5),
            ),
            currentIndex: current,
            onTap: (index) {
              mainPageProvider.changeIndex(index);
            },
            items: const [
              BottomNavigationBarItem(
                activeIcon: Icon(
                  FeatherIcons.barChart,
                ),
                icon: Icon(
                  FeatherIcons.barChart2,
                ),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  FeatherIcons.plusSquare,
                ),
                icon: Icon(
                  FeatherIcons.plusCircle,
                ),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  FeatherIcons.percent,
                ),
                icon: Icon(
                  Icons.percent_rounded,
                ),
                label: 'Discount',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  FeatherIcons.user,
                ),
                icon: Icon(
                  FeatherIcons.user,
                ),
                label: 'Profile',
              ),
            ],
          ),
        );
  }
}
