import 'package:flutter/material.dart';
import 'package:social_media_app/components/button/outline_button_login.dart';
import 'package:social_media_app/utils/app_colors.dart';

class DialogScreen extends StatelessWidget {
  const DialogScreen({
    super.key,
    required this.title,
    this.content,
    required this.labelStatusStop,
    required this.labelStatusContinue,
    required this.onPressedStop,
    required this.onPressedContinue,
    required this.typeDialogButtonBack,
  });

  final void Function() onPressedStop;
  final void Function() onPressedContinue;
  final String title;
  final Text? content;
  final String labelStatusStop;
  final String labelStatusContinue;
  final bool typeDialogButtonBack;

  @override
  Widget build(BuildContext context) {
    if (!typeDialogButtonBack) {
      return OutlineButtonLogin(
        text: "Already have an account?",
        onTap: () => dialogBuilder(context),
      );
    } else {
      return InkWell(
          onTap: () => dialogBuilder(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded));
    }
  }

  Future<void> dialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.center,
          title: Text(title),
          content: content,
          actions: [
            Column(
              children: [
                const Divider(
                  height: 1.0,
                ),
                InkWell(
                  onTap: onPressedStop,
                  child: Container(
                    width: double.infinity,
                    height: 55.0,
                    alignment: Alignment.center,
                    child: Text(
                      labelStatusStop,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.dangerColor,
                          fontSize: 16.0),
                    ),
                  ),
                ),
                const Divider(
                  height: 1.0,
                ),
                InkWell(
                  onTap: onPressedContinue,
                  child: Container(
                    width: double.infinity,
                    height: 55.0,
                    alignment: Alignment.center,
                    child: Text(
                      labelStatusContinue,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.infoColor,
                          fontSize: 16.0),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
