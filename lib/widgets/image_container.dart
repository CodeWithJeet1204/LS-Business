import 'package:find_easy/models/business_categories.dart';
import 'package:find_easy/models/household_categories.dart';
import 'package:find_easy/widgets/image_text_container.dart';
import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  const ImageContainer({
    super.key,
    required this.isShop,
  });

  final bool isShop;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 200, 238, 255),
          borderRadius: BorderRadius.circular(16),
        ),
        child: GridView.builder(
          itemCount: businessCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemBuilder: ((context, index) {
            return ImageTextContainer(
              imageUrl: isShop
                  ? businessCategories[index][1]
                  : householdCategories[index][1],
              text: isShop
                  ? businessCategories[index][0]
                  : householdCategories[index][1],
            );
          }),
        ),
      ),
    );
  }
}
