import 'package:flutter/material.dart';

class ServicesPage2 extends StatefulWidget {
  const ServicesPage2({super.key});

  @override
  State<ServicesPage2> createState() => _ServicesPage2State();
}

class _ServicesPage2State extends State<ServicesPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.0125,
        ),
        child: LayoutBuilder(builder: ((context, constraints) {
          // final width = constraints.maxWidth;

          return const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
            ),
          );
        })),
      ),
    );
  }
}
