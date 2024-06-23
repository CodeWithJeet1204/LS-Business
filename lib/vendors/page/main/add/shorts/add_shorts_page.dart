import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:localy/vendors/page/main/add/shorts/confirm_shorts_page.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image_picker/image_picker.dart';

class AddShortsPage extends StatefulWidget {
  const AddShortsPage({super.key});

  @override
  AddShortsPageState createState() => AddShortsPageState();
}

class AddShortsPageState extends State<AddShortsPage> {
  // late CameraController cameraController;
  // late VideoPlayerController videoPlayerController;
  bool isRecording = false;
  bool isInitialized = false;
  int recordingDuration = 0;
  Timer? recordingTimer;
  File? selectedVideo;
  final _flutterFFmpeg = FlutterFFprobe();

  // INIT STATE
  @override
  void initState() {
    // initializeCamera();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    // cameraController.dispose();
    // videoPlayerController.dispose();
    super.dispose();
  }

  // INITIALIZE CAMERA
  // Future<void> initializeCamera() async {
  //   final cameras = await availableCameras();
  //   final firstCamera = cameras.first;
  //   cameraController = CameraController(
  //     firstCamera,
  //     ResolutionPreset.medium,
  //   );
  //   await cameraController.initialize();
  //   setState(() {
  //     isInitialized = true;
  //   });
  // }

  // START RECORDING
  // Future<void> startRecording() async {
  //   try {
  //     await cameraController.startVideoRecording();
  //     setState(() {
  //       isRecording = true;
  //     });
  //     recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  //       setState(() {
  //         recordingDuration++;
  //       });
  //     });
  //     await Timer(
  //       Duration(seconds: 15),
  //       () async {
  //         if (isRecording) {
  //           await stopRecording();
  //         }
  //       },
  //     );
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // STOP RECORDING
  // Future<void> stopRecording() async {
  //   try {
  //     recordingTimer.cancel();
  //     final videoPath = await cameraController.stopVideoRecording();
  //     videoPlayerController = VideoPlayerController.file(File(videoPath.path));
  //     await videoPlayerController.initialize();
  //     setState(() {
  //       isRecording = false;
  //       recordingDuration = 0;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // SELECT VIDEO
  Future<void> selectVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'avi', 'mov'],
    );

    if (result != null) {
      setState(() {
        selectedVideo = File(result.files.single.path!);
      });

      var mediaInfo =
          await _flutterFFmpeg.getMediaInformation(selectedVideo!.path);

      final mediaData = mediaInfo.getAllProperties();

      var format = mediaData['format'];

      double durationDouble = double.parse(format['duration']);
      int durationInSeconds = durationDouble.toInt();

      if (durationInSeconds > 15) {
        await trimVideo();
      } else {
        String directory = '/storage/emulated/0/MyAppVideos';

        Directory(directory).createSync(recursive: true);

        String outputPath = '$directory/trimmed_video.mp4';
        setState(() {
          selectedVideo = File(outputPath);
        });
      }
    }
  }

  // TRIM VIDEO
  Future<void> trimVideo() async {
    String outputPath = '/path/to/output/trimmed_video.mp4';
    String command =
        '-i ${selectedVideo!.path} -ss 0 -to 15 -c copy $outputPath';
    await _flutterFFmpeg.execute(command);

    setState(() {
      selectedVideo = File(outputPath);
    });
  }

  // SHOW OPTIONS DIALOG
  Future<void> showOptionsDialog(BuildContext context, double width) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  await pickVideo(ImageSource.camera, context);
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
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(27),
                      topRight: Radius.circular(27),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      'Choose Camera',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await pickVideo(ImageSource.gallery, context);
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
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(27),
                      bottomRight: Radius.circular(27),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      'Choose from Gallery',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
  }

  // PICK VIDEO
  Future<void> pickVideo(ImageSource src, BuildContext context) async {
    final video = await ImagePicker().pickVideo(source: src);

    if (video != null) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ConfirmShortsPage(
              videoFile: File(video.path),
              videoPath: video.path,
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        return mySnackBar(context, 'Select Video');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Recorder'),
      ),
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       GestureDetector(
      //         onTap: () async {
      //           await selectVideo();
      //         },
      //         child: Container(
      //           decoration: BoxDecoration(
      //             color: primary2,
      //             borderRadius: BorderRadius.circular(12),
      //           ),
      //           padding: EdgeInsets.all(
      //             MediaQuery.of(context).size.width * 0.033,
      //           ),
      //           child: Text(
      //             selectedVideo != null ? 'abc' : 'Select Video',
      //             style: TextStyle(
      //               fontSize: MediaQuery.of(context).size.width * 0.05,
      //               fontWeight: FontWeight.w500,
      //             ),
      //           ),
      //         ),
      //       ),
      //       SizedBox(height: 20),
      //       selectedVideo != null
      //           ? AspectRatio(
      //               aspectRatio: 16 / 9,
      //               child: FutureBuilder(
      //                 future: VideoPlayerController.file(selectedVideo!)
      //                     .initialize(),
      //                 builder: (context, snapshot) {
      //                   if (snapshot.connectionState == ConnectionState.done) {
      //                     return VideoPlayer(
      //                       VideoPlayerController.file(selectedVideo!),
      //                     );
      //                   } else {
      //                     return CircularProgressIndicator();
      //                   }
      //                 },
      //               ),
      //             )
      //           : SizedBox(),
      //     ],
      //   ),
      // ),
      body: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.006125,
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;

          return Center(
            child: GestureDetector(
              onTap: () async {
                await showOptionsDialog(context, width);
              },
              child: Container(
                width: 190,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Add Video',
                  style: TextStyle(
                    color: black,
                    fontWeight: FontWeight.w500,
                    fontSize: width * 0.055,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
