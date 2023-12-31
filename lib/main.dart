import 'package:find_easy/first_launch_detection.dart';
import 'package:find_easy/page/intro/intro_page_view.dart';
import 'package:find_easy/page/register/login_page.dart';
import 'package:find_easy/page/profile_page.dart';
import 'package:find_easy/page/register/register_cred.dart';
import 'package:find_easy/page/register/register_pay.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyA-CD3MgDBzAsjmp_FlDbofynMMmW6fPsU',
      appId: '1:851488762803:android:eb89214a6ee6397b3979c6',
      messagingSenderId: '851488762803',
      projectId: 'find-easy-1204',
      storageBucket: 'find-easy-1204.appspot.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 10, 217, 213),
        ),
        useMaterial3: true,
      ),
      routes: {
        '/profile': (context) => ProfilePage(),
        '/login': (context) => LoginPage(),
        '/registerPay': (context) => RegisterPayPage(),
        '/registerCred': (context) => RegisterCredPage(),
      },
      debugShowCheckedModeBanner: false,
      home: isFirstLaunch
          ? IntroPageView()
          : StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    return ProfilePage();
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
                  return Center(
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
