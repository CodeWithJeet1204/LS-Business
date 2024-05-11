import 'package:find_easy/events/events_main_page.dart';
import 'package:find_easy/firebase_options.dart';
import 'package:find_easy/first_launch_detection.dart';
import 'package:find_easy/select_mode_page.dart';
import 'package:find_easy/services/main/services_main_page.dart';
import 'package:find_easy/vendors/page/intro/intro_page_view.dart';
import 'package:find_easy/vendors/page/main/add/brand/add_brand_page.dart';
import 'package:find_easy/vendors/page/main/add/category/add_category_page.dart';
import 'package:find_easy/vendors/page/main/analytics/shop_analytics_page.dart';
import 'package:find_easy/vendors/page/main/main_page.dart';
import 'package:find_easy/vendors/page/main/profile/data/all_brand_page.dart';
import 'package:find_easy/vendors/page/main/profile/data/all_discounts_page.dart';
import 'package:find_easy/vendors/page/main/profile/data/all_post_page.dart';
import 'package:find_easy/vendors/page/main/profile/data/all_product_page.dart';
import 'package:find_easy/vendors/page/main/profile/details/business_details_page.dart';
import 'package:find_easy/vendors/page/main/profile/details/owner_details_page.dart';
import 'package:find_easy/auth/login_page.dart';
import 'package:find_easy/vendors/page/main/profile/profile_page.dart';
import 'package:find_easy/auth/verify/email_verify.dart';
import 'package:find_easy/vendors/provider/add_product_provider.dart';
import 'package:find_easy/vendors/provider/change_category_provider.dart';
import 'package:find_easy/vendors/provider/discount_brand_provider.dart';
import 'package:find_easy/vendors/provider/discount_category_provider.dart';
import 'package:find_easy/vendors/provider/discount_products_provider.dart';
import 'package:find_easy/vendors/provider/products_added_to_brand.dart';
import 'package:find_easy/vendors/provider/products_added_to_category_provider.dart';
import 'package:find_easy/vendors/provider/select_brand_for_product_provider.dart';
import 'package:find_easy/vendors/provider/select_product_for_post_provider.dart';
import 'package:find_easy/vendors/provider/shop_type_provider.dart';
import 'package:find_easy/vendors/provider/sign_in_method_provider.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/vendors/utils/network_connectivity.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SignInMethodProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AddProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopTypeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductAddedToCategory(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductAddedToBrandProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChangeCategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SelectProductForPostProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SelectProductForDiscountProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SelectCategoryForDiscountProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SelectBrandForDiscountProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SelectBrandForProductProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
  // if (FirebaseAuth.instance.currentUser != null) {
  //   print(FirebaseAuth.instance.currentUser!.email);
  // } else {
  //   print('No Current User');
  // }
}

// GET SELECTED MODE
Future<String> getSelectedMode() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String selectedMode = prefs.getString('selectedText') ?? '';
  return selectedMode;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSelectedMode(),
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Find Easy Business',
            theme: ThemeData(
              scaffoldBackgroundColor: primary,
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: primaryDark2,
              ),
              appBarTheme: const AppBarTheme(
                // toolbarHeight: 50,
                backgroundColor: primary,
                foregroundColor: primaryDark,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: primaryDark,
                  fontSize: 22,
                  letterSpacing: 1,
                ),
                iconTheme: IconThemeData(
                  color: primaryDark,
                  weight: 1,
                ),
              ),
              iconButtonTheme: const IconButtonThemeData(
                style: ButtonStyle(
                  iconColor: MaterialStatePropertyAll(
                    primaryDark,
                  ),
                ),
              ),
              indicatorColor: primaryDark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: primary2,
              ),
              useMaterial3: true,
            ),
            routes: {
              '/profile': (context) => const ProfilePage(),
              '/ownerDetails': (context) => const OwnerDetailsPage(),
              '/businessDetails': (context) => const BusinessDetailsPage(),
              '/addCategory': (context) => const AddCategoryPage(),
              '/addBrand': (context) => const AddBrandPage(),
              '/postsPage': (context) => const AllPostsPage(),
              '/productsPage': (context) => const AllProductsPage(),
              '/discountsPage': (context) => const AllDiscountPage(),
              '/brandsPage': (context) => const AllBrandPage(),
              '/analyticsPage': (context) => const ShopAnalyticsPage(),
            },
            debugShowCheckedModeBanner: false,
            home: Stack(
              children: [
                isFirstLaunch
                    ? const IntroPageView()
                    : StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (context, authSnapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data == 'vendor') {
                              if (authSnapshot.hasData) {
                                if (authSnapshot.data!.emailVerified) {
                                  return const MainPage();
                                } else {
                                  return const EmailVerifyPage(
                                    mode: 'vendor',
                                    isLogging: true,
                                  );
                                }
                              } else {
                                return const LoginPage(
                                  mode: 'vendor',
                                );
                              }
                            } else if (snapshot.data == 'services') {
                              if (authSnapshot.hasData) {
                                if (authSnapshot.data!.emailVerified) {
                                  return const ServicesMainPage();
                                } else {
                                  return const EmailVerifyPage(
                                    mode: 'services',
                                    isLogging: true,
                                  );
                                }
                              } else {
                                return const LoginPage(
                                  mode: 'services',
                                );
                              }
                            } else if (snapshot.data == 'events') {
                              if (authSnapshot.hasData) {
                                if (authSnapshot.data!.emailVerified) {
                                  return const EventsMainPage();
                                } else {
                                  return const EmailVerifyPage(
                                    mode: 'events',
                                    isLogging: true,
                                  );
                                }
                              } else {
                                return const LoginPage(
                                  mode: 'events',
                                );
                              }
                            } else {
                              return const SelectModePage();
                            }
                          } else {
                            return const SelectModePage();
                          }
                        },
                      ),
                const ConnectivityNotificationWidget(),
              ],
            ),
          );
        });
  }
// TODO: Shorts
}
