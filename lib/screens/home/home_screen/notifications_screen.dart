import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/components/list/list_friend_request.component.dart';
import 'package:social_media_app/components/loading/overlay_loading.component.dart';
import 'package:social_media_app/models/notifications.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home/home_screen/list_friend_request_screen.dart';
import 'package:social_media_app/services/notifications/notifications.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/my_enum.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationServices notificationServices = NotificationServices();
  final UserServices userServices = UserServices();

  void onNavigateToListFriendRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ListFriendRequestScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            child: StreamBuilder<List<Notifications>>(
              stream: notificationServices.getNotificationsForFriendRequest(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('ERROR : ---> ${snapshot.error}'),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const OverlayLoadingWidget();
                } else {
                  final List<Notifications> dataNotifications =
                      snapshot.data ?? [];
                  if (dataNotifications.isNotEmpty) {
                    final countFriendRequest = dataNotifications
                        .where((element) =>
                            element.notificationType ==
                            NotificationTypeEnum.friendRequest.getString)
                        .toList();
                    final userFirst =
                        dataNotifications.first.notificationReferenceId;
                    final userLast =
                        dataNotifications.last.notificationReferenceId;
                    if (dataNotifications.isNotEmpty &&
                        countFriendRequest.length > 1) {
                      return FutureBuilder<List<Users?>>(
                        future: Future.wait([
                          userServices.getUserDetailsByID(userFirst!),
                          userServices.getUserDetailsByID(userLast!)
                        ]),
                        builder: (context, usersSnapshot) {
                          final dataUsers = usersSnapshot.data;
                          return GestureDetector(
                            onTap: onNavigateToListFriendRequests,
                            child: ListTileFriendRequestComponent(
                              title: dataNotifications.first.notificationType,
                              subtitle:
                                  '${dataUsers?.first?.username} + ${countFriendRequest.length - 1} others',
                              listImages: [
                                dataUsers?.first?.imageProfile,
                                dataUsers?.last?.imageProfile,
                              ],
                              listTrailing: const [
                                Icon(Icons.keyboard_arrow_right_rounded)
                              ],
                            ),
                          );
                        },
                      );
                    } else if (countFriendRequest.isNotEmpty) {
                      return FutureBuilder<Users?>(
                        future: userServices
                            .getUserDetailsByID(userLast ?? userFirst!),
                        builder: (context, usersSnapshot) {
                          final dataUsers = usersSnapshot.data;
                          return GestureDetector(
                            onTap: onNavigateToListFriendRequests,
                            child: ListTileFriendRequestComponent(
                              title: dataNotifications.first.notificationType,
                              subtitle: dataUsers?.username,
                              listImages: [
                                dataUsers?.imageProfile,
                              ],
                              listTrailing: const [
                                Icon(Icons.keyboard_arrow_right_rounded)
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  } else {
                    return const SizedBox();
                  }
                }
              },
            ),
          ),
          Flexible(
            child: StreamBuilder<List<Notifications>>(
              stream: notificationServices
                  .getNotificationsForAcceptedFriendRequest(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('ERROR : ---> ${snapshot.error}'),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const OverlayLoadingWidget();
                } else {
                  final List<Notifications> dataNotifications =
                      snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: dataNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = dataNotifications[index];
                      if (notification.notificationType ==
                          NotificationTypeEnum.acceptFriend.getString) {
                        DateFormat dateFormat =
                            DateFormat('dd/MM/yyyy HH:mm:ss');
                        String formattedDateTime = dateFormat.format(
                            notification.notificationCreatedDate!.toDate());
                        return FutureBuilder(
                          future: userServices
                              .getUserDetailsByID(notification.uid!),
                          builder: (context, userSnapshot) {
                            final dataUser = userSnapshot.data;
                            return ListTileFriendRequestComponent(
                              title: notification.notificationType,
                              subtitle:
                                  '${notification.notificationContent?.substring(5)} by ${dataUser?.username?.toUpperCase()} $formattedDateTime',
                              listImages: [
                                dataUser?.imageProfile,
                              ],
                            );
                          },
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
