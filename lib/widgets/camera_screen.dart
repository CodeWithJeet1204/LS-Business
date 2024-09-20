// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';

// class CameraScreen extends StatefulWidget {
//   final Function(XFile?) onImageCaptured;

//   CameraScreen({required this.onImageCaptured});

//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController cameraController;
//   late List<CameraDescription> cameras;

//   // INIT STATE
//   @override
//   void initState() {
//     initializeCamera();
//     super.initState();
//   }

//   // DISPOSE
//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }

//   // INITIALIZE CAMERAS
//   Future<void> initializeCamera() async {
//     cameras = await availableCameras();
//     cameraController = CameraController(
//       cameras[0],
//       ResolutionPreset.high,
//       imageFormatGroup: ImageFormatGroup.jpeg,
//     );
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Camera')),
//       body: AspectRatio(
//         aspectRatio: 1,
//         child: CameraPreview(cameraController),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           try {
//             await cameraController.initialize();
//             final image = await cameraController.takePicture();

//             widget.onImageCaptured(image);
//             Navigator.pop(context);
//           } catch (e) {
//             print(e);
//           }
//         },
//         child: Icon(Icons.camera),
//       ),
//     );
//   }
// }
