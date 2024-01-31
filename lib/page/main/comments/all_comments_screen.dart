import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class AllCommentPage extends StatelessWidget {
  const AllCommentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: Text('COMMENTS'),
      ),
      body: Center(
        child: Text('All Comments'),
      ),
    );
  }
}
