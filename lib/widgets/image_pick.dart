import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as pp;

Future<List<XFile>> pickCompressedImage(
  ImageSource source,
  BuildContext context,
  bool max1,
) async {
  try {
    List<XFile> images = [];
    List<XFile> results = [];
    if (source == ImageSource.camera) {
      final im = await ImagePicker().pickImage(source: ImageSource.camera);
      if (im != null) {
        images = [im];
      }
    } else {
      if (max1) {
        final im = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (im != null) {
          images = [im];
        } else {
          images = [];
        }
      } else {
        images = await ImagePicker().pickMultiImage();
      }
    }

    if (images.isNotEmpty) {
      for (XFile image in images) {
        final dir = await pp.getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final targetPath = '${dir.absolute.path}/temp_$timestamp.jpg';

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          image.path,
          targetPath,
          quality: 50,
        );

        if (compressedFile != null) {
          results.add(compressedFile);
        }
      }

      return results;
    }
    return [];
  } catch (e) {
    mySnackBar(context, e.toString());
    return [];
  }
}
