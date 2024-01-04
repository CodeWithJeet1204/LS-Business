import 'package:find_easy/utils/colors.dart';
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
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: primary,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: CircleAvatar(
                        radius: 44,
                        child: Image.network(
                          'https://yt3.googleusercontent.com/oSx8mAQ3_f9cvlml2wntk2_39M1DYXMDpSzLQOiK4sJOvypCMFjZ1gbiGQs62ZvRNClUN_14Ow=s900-c-k-c0x00ffffff-no-rj',
                        ),
                      ),
                    ),
                    const Column(
                      children: [
                        Text("NAME"),
                        Text("TYPE"),
                        Text("OWNER NAME"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
