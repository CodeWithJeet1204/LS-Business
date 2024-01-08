import 'dart:typed_data';

import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Uint8List? showImagePickDialog(BuildContext context) {
  Uint8List? im;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                Uint8List? image = await pickImage(ImageSource.camera);
                im = image;
              },
              child: Container(
                alignment: Alignment.centerLeft,
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: primaryDark2,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(27),
                    topRight: Radius.circular(27),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    "Choose Camera",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                Uint8List? image = await pickImage(ImageSource.gallery);
                im = image;
              },
              child: Container(
                alignment: Alignment.centerLeft,
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: primaryDark2,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(27),
                    bottomRight: Radius.circular(27),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    "Choose from Gallery",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  return im;
}
