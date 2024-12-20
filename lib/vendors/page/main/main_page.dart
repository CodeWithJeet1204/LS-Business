import 'dart:async';
import 'package:flutter/services.dart';
import 'package:ls_business/auth/sign_in_page.dart';
import 'package:ls_business/under_development_page.dart';
import 'package:ls_business/vendors/page/main/add/share/share_page.dart';
import 'package:ls_business/vendors/page/main/update_page.dart';
import 'package:ls_business/vendors/provider/main_page_provider.dart';
import 'package:ls_business/vendors/page/register/select_categories_page.dart';
import 'package:ls_business/vendors/page/register/select_products_page.dart';
import 'package:ls_business/vendors/page/register/business_social_media_page.dart';
import 'package:ls_business/vendors/page/register/business_timings_page.dart';
import 'package:ls_business/vendors/page/register/get_location_page.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/page/main/add/add_page.dart';
import 'package:ls_business/vendors/page/main/analytics/analytics_page.dart';
import 'package:ls_business/vendors/page/main/discount/add_discount_page.dart';
import 'package:ls_business/vendors/page/main/profile/profile_page.dart';
import 'package:ls_business/vendors/page/register/select_shop_types_page.dart';
import 'package:ls_business/vendors/page/register/business_register_details_page.dart';
import 'package:ls_business/vendors/page/register/membership_page.dart';
import 'package:ls_business/vendors/page/register/owner_register_details_page.dart';
import 'package:ls_business/auth/verify/email_verify.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  static const platform = MethodChannel('com.ls_business.share');
  List<String> imagePaths = [];
  // late StreamSubscription _intentSub;
  Widget? detailsPage;
  bool isGettingData = true;

  // INIT STATE
  @override
  void initState() {
    detailsAdded();
    platform.setMethodCallHandler(handleMethod);
    super.initState();
  }

  // DISPOSE
  // @override
  // void dispose() {
  //   _intentSub.cancel();
  //   super.dispose();
  // }

  // CHECK AND SAVE VIDEO
  Future<String?> checkAndSaveVideo(String contentUri) async {
    const platform = MethodChannel('com.ls_business.share');

    if (await Permission.videos.request().isGranted) {
      try {
        final dir = await getExternalStorageDirectory();
        final filePath = await platform.invokeMethod(
          'copyVideoFromUri',
          {
            "uri": contentUri,
            "destinationPath": '${dir!.path}/shared_video.mp4'
          },
        );

        if (filePath != null) {
          return filePath;
        }
      } catch (e) {
        if (mounted) {
          mySnackBar(context, 'Some error occured');
        }
      }
    }
    return null;
  }

  // HANDLE METHOD
  Future<void> handleMethod(MethodCall call) async {
    if (call.method == "shareImage") {
      setState(() {
        imagePaths = List<String>.from(call.arguments);
      });
      if (imagePaths.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SharePage(
              imagePaths: imagePaths,
            ),
          ),
        );
      }
    } /*else if (call.method == "shareVideo") {
      if (call.arguments.isNotEmpty) {
        if (call.arguments.length > 1) {
          mySnackBar(context, 'Only First video is taken');
        }
        final videoPath = await checkAndSaveVideo(
          call.arguments[0],
        );

        if (videoPath != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ConfirmShortsPage(
                videoFile: File(videoPath),
                videoPath: call.arguments[0],
                isShared: true,
              ),
            ),
          );
        } else {
          mySnackBar(context, 'Some error occured');
        }
      }
    } else if (call.method == "videoTooLong") {
      mySnackBar(context, 'Select video less than 60 seconds long');
    }*/
  }

  // DETAILS ADDED
  Future<void> detailsAdded() async {
    bool isPlayStoreVersionNewer(
      String currentVersion,
      String playStoreVersion,
    ) {
      List<int> currentParts =
          currentVersion.split('.').map(int.parse).toList();
      List<int> playStoreParts =
          playStoreVersion.split('.').map(int.parse).toList();

      for (int i = 0; i < playStoreParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (playStoreParts[i] > currentParts[i]) return true;
        if (playStoreParts[i] < currentParts[i]) return false;
      }
      return false;
    }

    Future<bool> checkLatestVersion() async {
      try {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;

        final latestVersionSnap =
            await store.collection('Information').doc('LS Business').get();

        final latestVersionData = latestVersionSnap.data()!;

        String playStoreVersion = latestVersionData['latest_version'];

        if (playStoreVersion.isEmpty) {
          return false;
        }

        return isPlayStoreVersionNewer(currentVersion, playStoreVersion);
      } catch (e) {
        if (mounted) {
          mySnackBar(context, 'Some error occured');
        }
      }
      return false;
    }

    try {
      final isUpdateAvailable = await checkLatestVersion();

      if (isUpdateAvailable) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const UpdatePage(),
            ),
            (route) => false,
          );
          setState(() {
            isGettingData = false;
          });
        }
      }

      final developmentSnap =
          await store.collection('Development').doc('Under Development').get();

      final developmentData = developmentSnap.data()!;

      final businessUnderDevelopment =
          developmentData['businessUnderDevelopment'];

      if (businessUnderDevelopment) {
        detailsPage = const UnderDevelopmentPage();
        setState(() {
          isGettingData = false;
        });
      } else {
        final getUserDetailsAdded = await store
            .collection('Business')
            .doc('Owners')
            .collection('Users')
            .doc(auth.currentUser!.uid)
            .get();

        if (!getUserDetailsAdded.exists) {
          await auth.signOut();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const SignInPage(),
              ),
              (route) => false,
            );
            setState(() {
              isGettingData = false;
            });
            return mySnackBar(context, 'Signed Out');
          }
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
            setState(() {
              isGettingData = false;
            });
          } else if (getUserDetailsAddedData['Image'] == null) {
            detailsPage = const OwnerRegisterDetailsPage(
              fromMainPage: true,
            );
            setState(() {
              isGettingData = false;
            });
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
            setState(() {
              isGettingData = false;
            });
          } else if (getBusinessDetailsAddedData['Name'] == null ||
              getBusinessDetailsAddedData['Latitude'] == null ||
              getBusinessDetailsAddedData['Description'] == null) {
            detailsPage = const BusinessRegisterDetailsPage(
              fromMainPage: true,
            );
            setState(() {
              isGettingData = false;
            });
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
            setState(() {
              isGettingData = false;
            });
          } else if (getBusinessDetailsAddedData['Instagram'] != null &&
              getBusinessDetailsAddedData['Type'] == null) {
            detailsPage = const SelectShopTypesPage(
              isEditing: true,
            );
            setState(() {
              isGettingData = false;
            });
          } else if (getBusinessDetailsAddedData['Type'] != null &&
              getBusinessDetailsAddedData['Categories'] == null) {
            detailsPage = SelectCategoriesPage(
              selectedTypes: getBusinessDetailsAddedData['Type'],
              isEditing: true,
            );
            setState(() {
              isGettingData = false;
            });
          } else if (getBusinessDetailsAddedData['Categories'] != null &&
              getBusinessDetailsAddedData['Products'] == null) {
            detailsPage = SelectProductsPage(
              selectedTypes: getBusinessDetailsAddedData['Type'],
              selectedCategories: getBusinessDetailsAddedData['Categories'],
              isEditing: true,
            );
            setState(() {
              isGettingData = false;
            });
          } else if (getBusinessDetailsAddedData['City'] == null ||
              getBusinessDetailsAddedData['Latitude'] == null) {
            detailsPage = const GetLocationPage();
            setState(() {
              isGettingData = false;
            });
          } else if (getBusinessDetailsAddedData['weekdayStartTime'] == null ||
              getBusinessDetailsAddedData['weekdayEndTime'] == null) {
            setState(() {
              detailsPage = const BusinessTimingsPage(
                fromMainPage: true,
              );
              setState(() {
                isGettingData = false;
              });
            });
          } else if (getUserDetailsAddedData['Image'] != null &&
              getUserDetailsAddedData['AadhaarNumber'] != null &&
              (getBusinessDetailsAddedData['MembershipName'] == null ||
                  getBusinessDetailsAddedData['MembershipEndDateTime'] ==
                      null)) {
            detailsPage = const SelectMembershipPage(
                // hasAvailedLaunchOffer: false,
                );
            setState(() {
              isGettingData = false;
            });
          } else if (DateTime.now().isAfter(
              (getBusinessDetailsAddedData['MembershipEndDateTime']
                      as Timestamp)
                  .toDate())) {
            detailsPage = const SelectMembershipPage(
                // hasAvailedLaunchOffer: true,
                );
            setState(() {
              isGettingData = false;
            });
            if (mounted) {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Your Membership Has Expired'),
                    content: const Text('Select New Membership to continue'),
                    actions: [
                      MyTextButton(
                        onTap: () {
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
            setState(() {
              detailsPage = null;
              isGettingData = false;
            });
            // _intentSub =
            //     ReceiveSharingIntent.instance.getMediaStream().listen((value) {
            //   setState(() {
            //     _sharedFiles.clear();
            //     _sharedFiles.addAll(value.where(
            //         (file) => file.type.toString().startsWith('image/')));
            //   });
            // }, onError: (err) {});

            // ReceiveSharingIntent.instance.getInitialMedia().then((value) {
            //   setState(() {
            //     _sharedFiles.clear();
            //     _sharedFiles.addAll(value.where(
            //         (file) => file.type.toString().startsWith('image/')));
            //     ReceiveSharingIntent.instance.reset();
            //   });
            // });

            // if (_sharedFiles.isNotEmpty) {
            //   List<String> imagePaths = _sharedFiles
            //       .where((file) => file.type == 'image')
            //       .map((file) => file.path)
            //       .toList();

            //   setState(() {
            //     detailsPage = SharePage(imagePaths: imagePaths);
            //   });
            // }
          }
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

    return isGettingData
        ? const Scaffold(
            body: Center(
              child: LoadingIndicator(),
            ),
          )
        : detailsPage ??
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
