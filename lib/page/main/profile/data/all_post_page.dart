import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class AllPostsPage extends StatelessWidget {
  const AllPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 21,
      physics: const ClampingScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: ((context, index) {
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              color: primary2.withOpacity(0.6),
            ),
          ),
        );
      }),
    );
  }
}
