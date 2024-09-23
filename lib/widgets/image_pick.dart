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
        // final isBlurred = await checkIfImageIsBlurred(File(im.path));
        // if (isBlurred) {
        //   if (context.mounted) {
        //     mySnackBar(
        //       context,
        //       'The captured image is blurred and will be skipped.',
        //     );
        //   }
        //   return [];
        // }
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
        // Check if the image is blurred
        // final isBlurred = await checkIfImageIsBlurred(File(image.path));

        // if (isBlurred) {
        //   if (context.mounted) {
        //     mySnackBar(context, 'An image is blurred and will be skipped.');
        //   }
        //   continue;
        // }

        // Compress the image if it's not blurred
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
    if (context.mounted) {
      mySnackBar(context, e.toString());
    }
    return [];
  }
}

// Manually apply the Laplacian filter for edge detection
// Future<bool> checkIfImageIsBlurred(File imageFile) async {
//   final image = img.decodeImage(imageFile.readAsBytesSync());
//   if (image == null) return false;
//   final grayscale = img.grayscale(image);
//   List<List<int>> laplacianKernel = [
//     [0, 1, 0],
//     [1, -4, 1],
//     [0, 1, 0]
//   ];
//   double sum = 0;
//   double sumSquared = 0;
//   int pixelCount = 0;
//   for (int y = 1; y < grayscale.height - 1; y++) {
//     for (int x = 1; x < grayscale.width - 1; x++) {
//       int laplacianValue = 0;
//       for (int ky = -1; ky <= 1; ky++) {
//         for (int kx = -1; kx <= 1; kx++) {
//           img.Pixel pixelValue = grayscale.getPixel(x + kx, y + ky);
//           int intensity = pixelValue.r.toInt(); // Use the red channel intensity
//           laplacianValue += intensity * laplacianKernel[ky + 1][kx + 1];
//         }
//       }
//       sum += laplacianValue;
//       sumSquared += laplacianValue * laplacianValue;
//       pixelCount++;
//     }
//   }
//   double mean = sum / pixelCount;
//   double variance = (sumSquared / pixelCount) - (mean * mean);
//   return variance < 25; // Threshold: adjust for stricter blur detection
// }

// Future<bool> checkIfImageIsBlurred(File imageFile) async {
//   final conditions = FirebaseModelDownloadConditions(
//     androidWifiRequired: false,
//   );

//   final model = await FirebaseModelDownloader.instance.getModel(
//     'Image_Blur_Detection',
//     FirebaseModelDownloadType.localModelUpdateInBackground,
//     conditions,
//   );

//   final modelFile = model.file;

//   final interpreter = await Interpreter.fromFile(modelFile);

//   final image = img.decodeImage(imageFile.readAsBytesSync());

//   if (image == null) {
//     return false;
//   }

//   final inputImage = img.copyResize(image, width: 224, height: 224);

//   var input = List.generate(
//     1, // Batch size
//     (b) => List.generate(
//       224,
//       (y) => List.generate(
//         224,
//         (x) {
//           var pixel = inputImage.getPixel(x, y);
//           return [
//             pixel.r,
//             pixel.g,
//             pixel.b,
//           ];
//         },
//       ),
//     ),
//   );

//   var output = List.filled(1, 0).reshape([1, 1]);

//   interpreter.run(input, output);

//   return output[0][0] > 0.3;
// }
