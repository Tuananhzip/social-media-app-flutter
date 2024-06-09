import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/components/text/chat_bubble.component.dart';
import 'package:social_media_app/models/messages.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/search/profile_users_screen.dart';
import 'package:social_media_app/services/message/message.services.dart';
import 'package:social_media_app/services/notifications/notifications.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/config.dart';
import 'package:social_media_app/utils/navigate.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.recipientId});
  final String recipientId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageTextController = TextEditingController();
  final MessageServices _messageServices = MessageServices();
  final NotificationServices _notificationServices = NotificationServices();
  final UserServices _userServices = UserServices();
  final _currentUser = FirebaseAuth.instance.currentUser;
  late final Stream<QuerySnapshot> _streamMessages;
  Users? _recipient;
  Users? _sender;

  @override
  void initState() {
    super.initState();
    _streamMessages = _messageServices.getMessages(
      _currentUser!.uid,
      widget.recipientId,
    );
    _getRecipient();
  }

  @override
  void dispose() {
    _messageTextController.dispose();
    super.dispose();
  }

  void _getRecipient() async {
    _recipient = await _userServices.getUserDetailsByID(widget.recipientId);
    _sender = await _userServices.getUserDetailsByID(_currentUser!.uid);
    setState(() {});
  }

  void _sendMessage() async {
    if (_messageTextController.text.isNotEmpty) {
      Future.wait([
        _messageServices.sendMessage(
          widget.recipientId,
          _messageTextController.text,
        ),
        _notificationServices.sendNotificationTypeMessage(
          _currentUser!.uid,
          _recipient!.username!,
          widget.recipientId,
        ),
      ]);
      _messageTextController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _sender != null && _recipient != null
        ? Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () => navigateToScreenAnimationRightToLeft(
                        context,
                        ProfileUsersScreen(
                          user: _recipient!,
                          uid: widget.recipientId,
                          isChatScreen: true,
                        )),
                    child: CachedNetworkImage(
                      imageUrl: _recipient?.imageProfile ?? imageProfileExample,
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          radius: 16.0,
                          backgroundImage: imageProvider,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _recipient!.username!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildMessageList(),
                ),
                _buildMessageInput(),
              ],
            ),
          )
        : const Scaffold(body: LoadingFlickrComponent());
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _streamMessages,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('ERROR ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingFlickrComponent();
        }
        final messages = snapshot.data!.docs;
        return messages.isNotEmpty
            ? Stack(
                children: [
                  ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = messages[index];
                      DocumentSnapshot? previousDocument =
                          index > 0 ? messages[index - 1] : null;
                      return _buildMessageItem(document, previousDocument);
                    },
                  ),
                ],
              )
            : Center(child: Text('Say hello to ${_recipient?.username}'));
      },
    );
  }

  Widget _buildMessageItem(
      DocumentSnapshot document, DocumentSnapshot? previousDocument) {
    final Messages message =
        Messages.fromMap(document.data() as Map<String, dynamic>);

    bool isSender = message.senderId == _currentUser!.uid;
    var aligment = isSender ? Alignment.centerRight : Alignment.centerLeft;
    final formatter =
        message.messageCreatedTime.toDate().day == Timestamp.now().toDate().day
            ? DateFormat('HH:mm')
            : DateFormat('MM/dd/yyyy HH:mm');
    final formattedTime = formatter.format(message.messageCreatedTime.toDate());
    return Container(
      alignment: aligment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment:
              isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            isSender
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            _recipient?.imageProfile ?? imageProfileExample,
                        imageBuilder: (context, imageProvider) {
                          return CircleAvatar(
                            radius: 16.0,
                            backgroundImage: imageProvider,
                          );
                        },
                      ),
                      const SizedBox(width: 8.0),
                      Text('${_recipient?.username}'),
                    ],
                  ),
            isSender ? const SizedBox.shrink() : const SizedBox(height: 8.0),
            ChatBubbleComponent(
              message: message.messageContent,
              isSender: isSender,
            ),
            Text(
              formattedTime,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.image),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: () {},
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _messageTextController,
              obscureText: false,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Message...',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _sendMessage,
        ),
      ],
    );
  }
}
