import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/image_pick.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<List<XFile>> showImagePickDialog(
  BuildContext context,
  bool max1,
) async {
  List<XFile> im = [];
  bool isLoading = false;

  await showDialog(
    context: context,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: isLoading
                  ? const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text('Checking Image Quality'),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            final image = await pickCompressedImage(
                              ImageSource.camera,
                              context,
                              max1,
                            );
                            im = image;
                            if (context.mounted) {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.of(context).pop();
                            }
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
                            setState(() {
                              isLoading = true;
                            });
                            final image = await pickCompressedImage(
                              ImageSource.gallery,
                              context,
                              max1,
                            );
                            im = image;
                            if (context.mounted) {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.of(context).pop();
                            }
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
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
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
                                'Cancel',
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
        ),
      );
    },
  );

  return im;
}
