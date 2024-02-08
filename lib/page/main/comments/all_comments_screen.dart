import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class AllCommentPage extends StatelessWidget {
  const AllCommentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('COMMENTS'),
      ),
      body: const Center(
        child: Text('All Comments'),
      ),
    );
  }
}
