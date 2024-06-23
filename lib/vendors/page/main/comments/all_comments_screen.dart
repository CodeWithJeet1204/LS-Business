import 'package:localy/vendors/utils/colors.dart';
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
          'COMMENTS',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: const Center(
        child: Text(
          'All Comments',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
