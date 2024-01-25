// ignore_for_file: avoid_print

import 'package:find_easy/first_launch_detection.dart';
import 'package:find_easy/page/intro/intro_page_view.dart';
import 'package:find_easy/page/main/add/add_category.dart';
import 'package:find_easy/page/main/main_page.dart';
import 'package:find_easy/page/main/profile/business_details_page.dart';
import 'package:find_easy/page/main/profile/categories_page.dart';
import 'package:find_easy/page/main/profile/owner_details_page.dart';
import 'package:find_easy/page/register/login_page.dart';
import 'package:find_easy/page/main/profile/profile_page.dart';
import 'package:find_easy/page/register/register_cred.dart';
import 'package:find_easy/page/register/register_pay.dart';
import 'package:find_easy/provider/category_provider.dart';
import 'package:find_easy/utils/colors.dart';
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
          create: (_) => CategoryProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
  if (FirebaseAuth.instance.currentUser == null) {
    print("Not signed in");
  } else {
    print(FirebaseAuth.instance.currentUser!.email);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Easy',
      theme: ThemeData(
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
        '/categoriesPage': (context) => const CategoriesPage(),
      },
      debugShowCheckedModeBanner: false,
      home: isFirstLaunch
          ? const IntroPageView()
          : StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    return const MainPage();
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                          "Some error occured\nClose & Open the app again"),
                    );
                  } else {
                    return const LoginPage();
                  }
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryDark,
                    ),
                  );
                } else {
                  return const LoginPage();
                }
              }),
            ),
    );
  }
}
