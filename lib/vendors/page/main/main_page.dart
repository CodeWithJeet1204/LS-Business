import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:ls_business/auth/sign_in_page.dart';
import 'package:ls_business/under_development_page.dart';
import 'package:ls_business/vendors/page/main/update_page.dart';
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
import 'package:package_info_plus/package_info_plus.dart';
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
  // static const platform = MethodChannel('com.ls_business.share');
  // List<String> imagePaths = [];
  // late StreamSubscription _intentSub;
  // final List<SharedMediaFile> _sharedFiles = [];
  Widget? detailsPage;

  // INIT STATE
  @override
  void initState() {
    detailsAdded();
    // platform.setMethodCallHandler(handleMethod);
    super.initState();
  }

  // DISPOSE
  // @override
  // void dispose() {
  //   _intentSub.cancel();
  //   super.dispose();
  // }

  // // HANDLE METHOD
  // Future<void> handleMethod(MethodCall call) async {
  //   if (call.method == "openSharePage") {
  //     setState(() {
  //       imagePaths = List<String>.from(call.arguments);
  //     });
  //     await requestStoragePermission();
  //     var status = await Permission.photos.status;
  //     if (!status.isGranted) {
  //       return;
  //     }
  //     List<String> localImagePaths = [];
  //     for (var uri in imagePaths) {
  //       String? localPath = await checkAndSaveFile(Uri.parse(uri));
  //       if (localPath != null) {
  //         localImagePaths.add(localPath);
  //       } else {
  //       }
  //     }
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => SharePage(
  //           imagePaths: localImagePaths,
  //         ),
  //       ),
  //     );
  //   }
  // }

  // // REQUEST STORAGE PERMISSION
  // Future<void> requestStoragePermission() async {
  //   var statusImages = await Permission.photos.status;
  //   var statusVideos = await Permission.videos.status;
  //   if (!statusImages.isGranted) {
  //     await Permission.photos.request();
  //   }
  //   if (!statusVideos.isGranted) {
  //     await Permission.videos.request();
  //   }
  //   if (await Permission.photos.isGranted &&
  //       await Permission.videos.isGranted) {
  //   } else {
  //   }
  // }

  // // CHECK AND SAVE FILE
  // Future<String?> checkAndSaveFile(Uri fileUri) async {
  //   if (fileUri.scheme == 'content') {
  //     String? localPath = await saveContentUriToFile(fileUri);
  //     return localPath;
  //   }
  //   String? path = fileUri.toFilePath();
  //   if (await File(path).exists()) {
  //     return path;
  //   }
  //   return null;
  // }

  // // SAVE CONTENT URI TO FILE
  // Future<String?> saveContentUriToFile(Uri contentUri) async {
  //   if (await Permission.storage.request().isGranted) {
  //     try {
  //       Directory tempDir = await getTemporaryDirectory();
  //       String newPath = '${tempDir.path}/downloaded_file.jpg';
  //       Response response =
  //           await Dio().download(contentUri.toString(), newPath);
  //       if (response.statusCode == 200) {
  //         return newPath;
  //       } else {
  //       }
  //     } catch (e) {
  //     }
  //   } else {
  //   }
  //   return null;
  // }

  // DETAILS ADDED
  Future<void> detailsAdded() async {
    bool isPlayStoreVersionNewer(
        String currentVersion, String playStoreVersion) {
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
        FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
        await remoteConfig.ensureInitialized();
        await remoteConfig.fetchAndActivate();
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;

        String? playStoreVersion = remoteConfig.getString('latest_version');

        // ignore: unnecessary_null_comparison
        if (playStoreVersion == null || playStoreVersion.isEmpty) {
          return false;
        }

        return isPlayStoreVersionNewer(currentVersion, playStoreVersion);
      } catch (e) {}
      return false;
    }

    try {
      final isUpdateAvailable = await checkLatestVersion();

      if (isUpdateAvailable) {
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const UpdatePage(),
            ),
            (route) => false,
          );
        }
      }

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
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const SignInPage(),
              ),
              (route) => false,
            );
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
            //   _intentSub =
            //       ReceiveSharingIntent.instance.getMediaStream().listen((value) {
            //     setState(() {
            //       _sharedFiles.clear();
            //       _sharedFiles.addAll(value.where(
            //           (file) => file.type.toString().startsWith('image/')));
            //     });
            //   }, onError: (err) {
            //   });

            //   ReceiveSharingIntent.instance.getInitialMedia().then((value) {
            //     setState(() {
            //       _sharedFiles.clear();
            //       _sharedFiles.addAll(value.where(
            //           (file) => file.type.toString().startsWith('image/')));
            //       ReceiveSharingIntent.instance.reset();
            //     });
            //   });

            //   if (_sharedFiles.isNotEmpty) {
            //     List<String> imagePaths = _sharedFiles
            //         .where((file) => file.type == 'image')
            //         .map((file) => file.path)
            //         .toList();

            //     setState(() {
            //       detailsPage = SharePage(imagePaths: imagePaths);
            //     });
            //   }
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
