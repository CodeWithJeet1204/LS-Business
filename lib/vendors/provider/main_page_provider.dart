import 'package:flutter/material.dart';

class MainPageProvider with ChangeNotifier {
  int _index = 3;
  int get index => _index;
  List<int> myloadedPages = [3];
  List<int> get loadedPages => myloadedPages;

  // CHANGE INDEX
  void changeIndex(int newIndex) {
    if (!myloadedPages.contains(newIndex)) {
      myloadedPages.add(newIndex);
    }
    _index = newIndex;

    notifyListeners();
  }

  // GO TO HOME PAGE
  void goToHomePage() {
    _index = 3;

    notifyListeners();
  }
}
