import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref extends StatefulWidget {
  const SharedPref({super.key});

  @override
  // ignore: library_private_types_in_public_api
  SharedPrefState createState() => SharedPrefState();
}

bool isFirstLaunch = false;

class SharedPrefState extends State<SharedPref> {
  sharedState() {
    MySharedPreferences.instance
        .getBooleanValue('isfirstRun')
        .then((value) => setState(() {
              isFirstLaunch = value;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

class MySharedPreferences {
  MySharedPreferences._privateConstructor();

  static final MySharedPreferences instance =
      MySharedPreferences._privateConstructor();

  setBooleanValue(String key, bool value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setBool(key, value);
  }

  Future<bool> getBooleanValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getBool(key) ?? false;
  }
}
