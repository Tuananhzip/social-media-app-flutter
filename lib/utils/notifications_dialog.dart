import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';

class DialogNotifications {
  static void notificationSuccess(
      BuildContext context, String title, String description) {
    ElegantNotification.success(
      background: Theme.of(context).colorScheme.background,
      title: Text(title),
      description: Text(description),
      toastDuration: const Duration(seconds: 3),
    )
        // ignore: use_build_context_synchronously
        .show(context);
  }

  static void notificationError(
      BuildContext context, String title, String description) {
    ElegantNotification.error(
      background: Theme.of(context).colorScheme.background,
      title: Text(title),
      description: Text(description),
      toastDuration: const Duration(seconds: 3),
    )
        // ignore: use_build_context_synchronously
        .show(context);
  }

  static void notificationInfo(
      BuildContext context, String title, String description) {
    ElegantNotification.info(
      background: Theme.of(context).colorScheme.background,
      title: Text(title),
      description: Text(description),
      toastDuration: const Duration(seconds: 3),
    )
        // ignore: use_build_context_synchronously
        .show(context);
  }
}
