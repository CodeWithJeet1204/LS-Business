import 'package:find_easy/vendors/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageTextContainer extends StatefulWidget {
  const ImageTextContainer({
    super.key,
    required this.imageUrl,
    required this.text,
  });

  final String text;
  final String imageUrl;

  @override
  State<ImageTextContainer> createState() => _ImageTextContainerState();
}

void selectCategory(text) {
  selectedCategory = text;
}

String selectedCategory = "Select Category";

class _ImageTextContainerState extends State<ImageTextContainer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          selectCategory(widget.text);
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.of(context).pop();
        },
        child: SizedBox(
          height: double.infinity,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: primary2,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  widget.imageUrl,
                  height: 60,
                ),
                const SizedBox(height: 24),
                Text(
                  overflow: TextOverflow.ellipsis,
                  widget.text,
                  // overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
