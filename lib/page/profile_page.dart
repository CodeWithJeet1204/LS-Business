import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void signOut() {
    FirebaseAuth.instance.signOut();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    Navigator.of(context).popAndPushNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MyTextButton(
          onPressed: signOut,
          text: "LOGOUT",
          textColor: primary2,
        ),
      ),
    );
  }
}
