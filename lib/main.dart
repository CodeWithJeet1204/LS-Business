import 'package:ls_business/firebase_options.dart';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/vendors/provider/add_product_provider.dart';
import 'package:ls_business/vendors/provider/change_category_provider.dart';
import 'package:ls_business/vendors/provider/discount_brand_provider.dart';
import 'package:ls_business/vendors/provider/discount_category_provider.dart';
import 'package:ls_business/vendors/provider/discount_products_provider.dart';
import 'package:ls_business/vendors/provider/main_page_provider.dart';
import 'package:ls_business/vendors/provider/product_change_category_provider.dart';
import 'package:ls_business/vendors/provider/products_added_to_brand.dart';
import 'package:ls_business/vendors/provider/products_added_to_category_provider.dart';
import 'package:ls_business/vendors/provider/shop_type_provider.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'localsearch',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.playIntegrity,
  // );

  // await Messaging().initNotifications();

  runApp(
    MultiProvider(
      providers: [
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
        // ChangeNotifierProvider(
        //   create: (_) => SelectProductForPostProvider(),
        // ),
        ChangeNotifierProvider(
          create: (_) => SelectProductForDiscountProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SelectCategoryForDiscountProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SelectBrandForDiscountProvider(),
        ),
        // ChangeNotifierProvider(
        //   create: (_) => SelectBrandForProductProvider(),
        // ),
        // ChangeNotifierProvider(
        //   create: (_) => PickLocationProvider(),
        // ),
        ChangeNotifierProvider(
          create: (_) => MainPageProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductChangeCategoryProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// GET SELECTED MODE
// Future<String> getSelectedMode() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   String selectedMode = prefs.getString('selectedText') ?? '';
//   return selectedMode;
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LS Business',
      theme: ThemeData(
        scaffoldBackgroundColor: primary,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryDark2,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: primaryDark,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
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
            iconColor: WidgetStatePropertyAll(
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
      // TODO: PRICE COMPULSORY FOR POSTS
      debugShowCheckedModeBanner: false,
      // home: Stack(
      //   children: [
      //     /*isFirstLaunch
      //         ? const IntroPageView()
      //         : */
      //     StreamBuilder<User?>(
      //       stream: FirebaseAuth.instance.authStateChanges(),
      //       builder: (context, authSnapshot) {
      //         // if (snapshot.hasData) {
      //         // if (snapshot.data == 'vendor') {
      //         if (authSnapshot.hasData) {
      //           if (FirebaseAuth.instance.currentUser != null) {
      //             return const MainPage();
      //           } else {
      //             mySnackBar(context, 'Signed out');
      //             return SignInPage();
      //           }
      //         } else {
      //           return const SignInPage(
      //               // mode: 'vendor',
      //               );
      //         }
      //         // } else if (snapshot.data == 'services') {
      //         //   if (authSnapshot.hasData) {
      //         //     if (authSnapshot.data!.email != null) {
      //         //       if (authSnapshot.data!.emailVerified) {
      //         //         return const ServicesMainPage();
      //         //       } else {
      //         //         return const EmailVerifyPage(
      //         //           mode: 'services',
      //         //           isLogging: true,
      //         //         );
      //         //       }
      //         //     } else {
      //         //       return const LoginPage(mode: 'services');
      //         //     }
      //         //   } else {
      //         //     return const LoginPage(
      //         //       mode: 'services',
      //         //     );
      //         //   }
      //         // } else if (snapshot.data == 'events') {
      //         //   if (authSnapshot.hasData) {
      //         //     if (authSnapshot.data!.emailVerified) {
      //         //       return const EventsMainPage();
      //         //     } else {
      //         //       return const EmailVerifyPage(
      //         //         mode: 'events',
      //         //         isLogging: true,
      //         //       );
      //         //     }
      //         // } else {
      //         //   return const LoginPage(
      //         //     mode: 'events',
      //         //   );
      //         // }
      //         // } else {
      //         //   return const SelectModePage();
      //         // }
      //         // } else {
      //         //   return const SelectModePage();
      //         // }
      //       },
      //     ),
      //     const ConnectivityNotificationWidget(),
      //   ],
      // ),
      home: const MainPage(),
    );
  }
}

// Idea: Paper print that available on LS Business
