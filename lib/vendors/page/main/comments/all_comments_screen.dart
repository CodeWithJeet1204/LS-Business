import 'package:find_easy/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class AllCommentPage extends StatelessWidget {
  const AllCommentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'COMMENTS',
        ),
      ),
      body: const Center(
        child: Text(
          overflow: TextOverflow.ellipsis,
          'All Comments',
        ),
      ),
    );
  }
}
