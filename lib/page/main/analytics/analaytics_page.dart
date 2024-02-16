import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text("ANALYTICS"),
      ),
      body: const Center(
        child: Text('Analytics'),
      ),
    );
  }
}
