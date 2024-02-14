import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/first_launch_detection.dart';
import 'package:find_easy/page/intro/intro_page_view.dart';
import 'package:find_easy/page/main/add/brand/add_brand_page.dart';
import 'package:find_easy/page/main/add/category/add_category_page.dart';
import 'package:find_easy/page/main/analytics/analaytics_page.dart';
import 'package:find_easy/page/main/main_page.dart';
import 'package:find_easy/page/main/profile/data/all_brand_page.dart';
import 'package:find_easy/page/main/profile/data/all_post_page.dart';
import 'package:find_easy/page/main/profile/data/all_product_page.dart';
import 'package:find_easy/page/main/profile/details/business_details_page.dart';
import 'package:find_easy/page/main/profile/data/all_categories_page.dart';
import 'package:find_easy/page/main/profile/details/owner_details_page.dart';
import 'package:find_easy/page/register/login_page.dart';
import 'package:find_easy/page/main/profile/profile_page.dart';
import 'package:find_easy/page/register/register_cred.dart';
import 'package:find_easy/page/register/register_pay.dart';
import 'package:find_easy/page/register/verify/email_verify.dart';
import 'package:find_easy/provider/add_product_provider.dart';
import 'package:find_easy/provider/change_category_provider.dart';
import 'package:find_easy/provider/discount_brand_provider.dart';
import 'package:find_easy/provider/discount_category_provider.dart';
import 'package:find_easy/provider/discount_products_provider.dart';
import 'package:find_easy/provider/products_added_to_brand.dart';
import 'package:find_easy/provider/products_added_to_category_provider.dart';
import 'package:find_easy/provider/select_brand_for_product_provider.dart';
import 'package:find_easy/provider/select_product_for_post_provider.dart';
import 'package:find_easy/provider/shop_type_provider.dart';
import 'package:find_easy/provider/sign_in_method_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/utils/network_connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyA-CD3MgDBzAsjmp_FlDbofynMMmW6fPsU',
      appId: '1:851488762803:android:eb89214a6ee6397b3979c6',
      messagingSenderId: '851488762803',
      projectId: 'find-easy-1204',
      storageBucket: 'find-easy-1204.appspot.com',
    ),
  );
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
  if (FirebaseAuth.instance.currentUser == null) {
  } else {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isDetailsAdded() async {
    final userDocSnap = await FirebaseFirestore.instance
        .collection('Business')
        .doc("Owners")
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    bool isAdded = userDocSnap['detailsAdded'];
    return isAdded;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Easy Business',
      theme: ThemeData(
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
          seedColor: const Color.fromARGB(255, 10, 217, 213),
        ),
        useMaterial3: true,
      ),
      routes: {
        '/profile': (context) => const ProfilePage(),
        '/login': (context) => const LoginPage(),
        '/registerPay': (context) => const RegisterPayPage(),
        '/registerCred': (context) => const RegisterCredPage(),
        '/ownerDetails': (context) => const OwnerDetailsPage(),
        '/businessDetails': (context) => const BusinessDetailsPage(),
        '/addCategory': (context) => const AddCategoryPage(),
        '/addBrand': (context) => const AddBrandPage(),
        '/postsPage': (context) => const AllPostsPage(),
        '/categoriesPage': (context) => const AllCategoriesPage(),
        '/productsPage': (context) => const AllProductsPage(),
        '/brandPage': (context) => const AllBrandPage(),
        '/analyticsPage': (context) => const AnalyticsPage(),
      },
      debugShowCheckedModeBanner: false,
      home: isFirstLaunch
          ? const IntroPageView()
          : StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    return Stack(
                      children: [
                        const MainPage(),
                        ConnectivityNotificationWidget(),
                      ],
                    );
                  } else if (snapshot.hasData &&
                      FirebaseAuth.instance.currentUser!.email != null &&
                      !FirebaseAuth.instance.currentUser!.emailVerified) {
                    return const EmailVerifyPage();
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Some error occured\nClose & Open the app again",
                      ),
                    );
                  } else {
                    return Stack(
                      children: [
                        const LoginPage(),
                        ConnectivityNotificationWidget(),
                      ],
                    );
                  }
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryDark,
                    ),
                  );
                } else {
                  return Stack(
                    children: [
                      const LoginPage(),
                      ConnectivityNotificationWidget(),
                    ],
                  );
                }
              }),
            ),
    );
  }
}


// TODO: No of Text Posts and Images Post
// TODO: Shorts
// TODO: Analytics
// TODO: Comments