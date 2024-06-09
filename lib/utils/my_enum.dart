enum Fragments {
  homeScreen,
  searchScreen,
  createPostScreen,
  listVideoScreen,
  profileScreen
}

enum Genders { male, female }

enum NotificationTypeEnum {
  friendRequest,
  acceptFriend,
  comment,
  message,
}

extension NotificationTypeEnumExtension on NotificationTypeEnum {
  String get name {
    switch (this) {
      case NotificationTypeEnum.friendRequest:
        return 'Friend Request';
      case NotificationTypeEnum.acceptFriend:
        return 'Accepted Friend';
      case NotificationTypeEnum.comment:
        return 'Comment Post';
      case NotificationTypeEnum.message:
        return 'Message';
    }
  }
}

enum MediaTypeEnum { image, video, other }

enum MenuPostEnum { edit, delete, report }
