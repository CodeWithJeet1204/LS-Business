import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/events/events_main_page.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventsRegisterDetailsPage2 extends StatefulWidget {
  const EventsRegisterDetailsPage2({super.key});

  @override
  State<EventsRegisterDetailsPage2> createState() =>
      _EventsRegisterDetailsPage2State();
}

class _EventsRegisterDetailsPage2State
    extends State<EventsRegisterDetailsPage2> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final registerKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  bool isDone = false;

  // DONE
  Future<void> done() async {
    if (registerKey.currentState!.validate()) {
      setState(() {
        isDone = true;
      });
      await store.collection('Organizers').doc(auth.currentUser!.uid).update({
        'Description': descriptionController.text,
        'workImages': [],
      });
      setState(() {
        isDone = false;
      });

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: ((context) => EventsMainPage()),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Description'),
      ),
      body: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.0125,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: registerKey,
            child: Column(
              children: [
                TextFormField(
                  autofocus: true,
                  controller: descriptionController,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  minLines: 5,
                  maxLines: 100,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.cyan.shade700,
                      ),
                    ),
                    hintText:
                        'Description (How it started, Mission, Achievements)',
                  ),
                  validator: (value) {
                    if (value != null) {
                      if (value.isNotEmpty) {
                        return null;
                      } else {
                        return 'Pls enter Description';
                      }
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // DONE
                MyButton(
                  text: 'DONE',
                  onTap: () async {
                    await done();
                  },
                  isLoading: isDone,
                  horizontalPadding: MediaQuery.of(context).size.width * 0.1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
