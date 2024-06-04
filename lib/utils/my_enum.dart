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
    }
  }
}

enum MediaTypeEnum { image, video, other }

enum MenuPostEnum { edit, delete, report }
