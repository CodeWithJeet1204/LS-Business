import 'package:flutter/material.dart';

class ServicesProfilePage extends StatefulWidget {
  const ServicesProfilePage({super.key});

  @override
  State<ServicesProfilePage> createState() => _ServicesProfilePageState();
}

class _ServicesProfilePageState extends State<ServicesProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.0125,
        ),
        child: LayoutBuilder(builder: ((context, constraints) {
          final width = constraints.maxWidth;

          return SingleChildScrollView(
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
