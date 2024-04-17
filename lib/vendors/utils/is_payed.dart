import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveIsPayed(bool isDetailsAdded) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isDetailsAdded', isDetailsAdded);
}

Future<bool> getIsPayed() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isDetailsAdded') ?? false;
}
