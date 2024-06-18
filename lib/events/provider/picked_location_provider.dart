import 'package:flutter/material.dart';

class PickLocationProvider with ChangeNotifier {
  double? _latitude;
  double? _longitude;
  Map<String, dynamic>? _address;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  Map<String, dynamic>? get address => _address;

  void setLocation(double lat, double long, Map<String, dynamic> add) {
    _latitude = lat;
    _longitude = long;
    _address = add;

    notifyListeners();
  }
}
