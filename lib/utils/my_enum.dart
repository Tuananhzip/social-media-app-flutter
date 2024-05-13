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

extension NotificationTypeExtension on NotificationTypeEnum {
  String get getString {
    switch (this) {
      case NotificationTypeEnum.friendRequest:
        return 'Friend request';
      case NotificationTypeEnum.comment:
        return 'Comment';
      case NotificationTypeEnum.acceptFriend:
        return 'Accepted friend';
      default:
        return '';
    }
  }
}

enum MediaTypeEnum { image, video, other }

enum MenuPostEnum { edit, delete, report }

extension MenuPostExtension on MenuPostEnum {
  String get getString {
    switch (this) {
      case MenuPostEnum.edit:
        return 'Edit';
      case MenuPostEnum.delete:
        return 'Delete';
      case MenuPostEnum.report:
        return 'Report';
      default:
        return '';
    }
  }
}
