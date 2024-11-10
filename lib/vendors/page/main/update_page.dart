import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  AppUpdateInfo? _updateInfo;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    checkForImmediateUpdate();
  }

  Future<void> checkForImmediateUpdate() async {
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();
      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        if (_updateInfo?.immediateUpdateAllowed == true) {
          setState(() {
            isUpdating = true;
          });
          // ignore: body_might_complete_normally_catch_error
          await InAppUpdate.performImmediateUpdate().catchError((e) async {
            setState(() {
              isUpdating = false;
            });
            await launchPlayStore();
          });
        } else {
          launchPlayStore();
        }
      }
    } catch (e) {
      if (mounted) {
        mySnackBar(context, 'Failed to check for update');
      }
    }
  }

  Future<void> launchPlayStore() async {
    Uri url = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.infinitylab.ls_business',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          mySnackBar(context, 'Failed to open Play Store. Try again later.');
        }
      }
    } catch (e) {
      if (mounted) {
        mySnackBar(context, 'Some error occurred, Try Again Later');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update This App'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(width * 0.0225),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isUpdating
                    ? 'Updating the App\nPlease Wait'
                    : 'Please update this app to the latest version to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryDark,
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              isUpdating
                  ? const LinearProgressIndicator()
                  : MyButton(
                      onTap: () async {
                        await launchPlayStore();
                      },
                      text: 'UPDATE',
                      horizontalPadding: 0,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
