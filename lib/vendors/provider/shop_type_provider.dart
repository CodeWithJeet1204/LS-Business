import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShopTypeProvider with ChangeNotifier {
  final Future<String> shopType = FirebaseFirestore.instance
      .collection('Business')
      .doc('Owners')
      .collection('Shops')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    String type = documentSnapshot.get('Type');
    return type;
  });
}
