import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController categoryController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;
  bool isSaving = false;

  void addCategory(String categoryName) async {
    if (categoryController.text.toString().isNotEmpty) {
      setState(() {
        isSaving = true;
      });
      try {
        store
            .collection('Business')
            .doc('Data')
            .collection('Category')
            .doc(auth.currentUser!.uid)
            .collection(categoryName.toString());
        if (context.mounted) {
          mySnackBar(context, "Added");
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          mySnackBar(context, e.toString());
        }
      }
      setState(() {
        isSaving = false;
      });
    } else {
      mySnackBar(context, "Enter Category Name");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ADD CATEGORY"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            MyTextFormField(
              hintText: "Category Name",
              controller: categoryController,
              borderRadius: 12,
              horizontalPadding: 20,
              autoFillHints: null,
            ),
            const SizedBox(height: 20),
            MyButton(
              text: "SAVE",
              onTap: () {
                addCategory(categoryController.text.toString());
              },
              isLoading: isSaving,
              horizontalPadding: 20,
            ),
          ],
        ),
      ),
    );
  }
}
