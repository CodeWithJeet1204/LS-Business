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
    checkForImmediateUpdate();
    super.initState();
  }

  // CHECK FOR IMMEDIATE UPDATE
  Future<void> checkForImmediateUpdate() async {
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();
      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        if (_updateInfo?.immediateUpdateAllowed == true) {
          setState(() {
            isUpdating = true;
          });
          await InAppUpdate.performImmediateUpdate().catchError((e) async {
            setState(() {
              isUpdating = false;
            });
            await launchPlayStore();
            return AppUpdateResult.userDeniedUpdate;
          });
        } else {
          launchPlayStore();
        }
      }
    } catch (e) {
      mySnackBar(context, 'Failed to check for update');
    }
  }

  // LAUNCH PLAY STORE
  Future<void> launchPlayStore() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.lsbusiness.package';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      mySnackBar(context, 'Some error occurred, Try Again Later');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Update This App'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isUpdating
                  ? 'Updating the App\nPls Wait'
                  : 'Please update this app to the latest version to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryDark,
                fontSize: width * 0.05,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 18),
            isUpdating
                ? LinearProgressIndicator()
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
    );
  }
}
