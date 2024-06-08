import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/components/loading/shimmer_comment.component.dart';
import 'package:social_media_app/models/post_comments.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/config.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentPostComponent extends StatefulWidget {
  const CommentPostComponent({
    super.key,
    required this.uid,
    required this.comments,
  });
  final String uid;
  final PostComments comments;

  @override
  State<CommentPostComponent> createState() => _CommentPostComponentState();
}

class _CommentPostComponentState extends State<CommentPostComponent> {
  Future<Users?>? _userDetailsFuture;
  final UserServices _userServices = UserServices();

  @override
  void initState() {
    super.initState();
    _userDetailsFuture = _userServices.getUserDetailsByID(widget.uid);
  }

  String _dateFormat(Timestamp timestamp, {bool useTimeAgo = false}) {
    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (useTimeAgo && difference.inDays <= 7) {
      return timeago.format(dateTime);
    } else {
      if (dateTime.year == now.year) {
        return DateFormat('MMMM dd,').add_jm().format(dateTime);
      } else {
        return DateFormat.yMMMMEEEEd().format(dateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Users?>(
      future: _userDetailsFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerCommentComponent();
        } else if (userSnapshot.hasError) {
          return Center(
            child: Text('Error loading comments ---> ${userSnapshot.error}'),
          );
        }
        final Users? user = userSnapshot.data;
        return ListTile(
          leading: SizedBox(
            height: 40.0,
            width: 40.0,
            child: CachedNetworkImage(
              imageUrl: user?.imageProfile ?? imageProfileExample,
              imageBuilder: (context, imageProvider) {
                return CircleAvatar(
                  backgroundImage: imageProvider,
                );
              },
            ),
          ),
          title: Text(user?.username ?? 'Unknown'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.comments.commentText,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                _dateFormat(widget.comments.commentCreatedTime),
                style: Theme.of(context).textTheme.labelSmall,
              )
            ],
          ),
        );
      },
    );
  }
}
