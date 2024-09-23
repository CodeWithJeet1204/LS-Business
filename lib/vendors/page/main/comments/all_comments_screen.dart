// import 'package:Localsearch/vendors/utils/colors.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:feedback/feedback.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'package:path_provider/path_provider.dart';

// class AllCommentPage extends StatelessWidget {
//   const AllCommentPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: primary,
//       appBar: AppBar(
//         title: const Text(
//           'COMMENTS',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               BetterFeedback.of(context).show((feedback) async {
//                 Future<String> writeImageToStorage(
//                     Uint8List feedbackScreenshot) async {
//                   final Directory output = await getTemporaryDirectory();
//                   final String screenshotFilePath =
//                       '${output.path}/feedback.png';
//                   final File screenshotFile = File(screenshotFilePath);
//                   await screenshotFile.writeAsBytes(feedbackScreenshot);
//                   return screenshotFilePath;
//                 }

//                 final screenshotFilePath =
//                     await writeImageToStorage(feedback.screenshot);

//                 final Email email = Email(
//                   body: feedback.text,
//                   subject: 'LS Business Feedback',
//                   recipients: ['infinitylab1204@gmail.com'],
//                   attachmentPaths: [screenshotFilePath],
//                   isHTML: false,
//                 );
//                 await FlutterEmailSender.send(email);
//               });
//             },
//             icon: const Icon(
//               Icons.bug_report_outlined,
//             ),
//             tooltip: 'Report Problem',
//           ),
//         ],
//       ),
//       body: const Center(
//         child: Text(
//           'All Comments',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }
