import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/components/text/chat_bubble.component.dart';
import 'package:social_media_app/models/messages.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/services/message/message.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.recipientId});
  final String recipientId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final MessageServices _messageServices = MessageServices();
  final UserServices _userServices = UserServices();
  final _currentUser = FirebaseAuth.instance.currentUser;
  Users? _recipient;
  Users? _sender;
  late final Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    super.initState();
    _getRecipient();
    _messagesStream =
        _messageServices.getMessages(widget.recipientId, _currentUser!.uid);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _getRecipient() async {
    _recipient = await _userServices.getUserDetailsByID(widget.recipientId);
    _sender = await _userServices.getUserDetailsByID(_currentUser!.uid);
    setState(() {});
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _messageServices.sendMessage(
          widget.recipientId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _recipient != null && _sender != null
        ? Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 16.0,
                    backgroundImage: CachedNetworkImageProvider(
                        _recipient?.imageProfile ?? imageProfileExample),
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
        : const LoadingFlickrComponent();
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('ERROR${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingFlickrComponent();
        }
        return ListView(
          children: snapshot.data!.docs.asMap().entries.map((entry) {
            int idx = entry.key;
            DocumentSnapshot document = entry.value;
            DocumentSnapshot? previousDocument =
                idx > 0 ? snapshot.data!.docs[idx - 1] : null;
            return _buildMessageItem(
              document,
              previousDocument,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(
      DocumentSnapshot document, DocumentSnapshot? previousDocument) {
    final Messages message =
        Messages.fromMap(document.data() as Map<String, dynamic>);
    final Messages? previousMessage = previousDocument != null
        ? Messages.fromMap(previousDocument.data() as Map<String, dynamic>)
        : null;
    bool isSender = message.senderId == _currentUser!.uid;
    var aligment = isSender ? Alignment.centerRight : Alignment.centerLeft;
    final shouldDisplayTimestamp = previousMessage == null ||
        message.messageCreatedTime
                .toDate()
                .difference(previousMessage.messageCreatedTime.toDate())
                .inMinutes >
            5;
    final shouldDisplayFullDate = previousMessage == null ||
        message.messageCreatedTime
                .toDate()
                .difference(previousMessage.messageCreatedTime.toDate())
                .inHours >
            24;

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
            if (shouldDisplayTimestamp)
              Center(
                child: Text(
                  shouldDisplayFullDate
                      ? DateFormat('MM/dd/yyyy hh:mm a')
                          .format(message.messageCreatedTime.toDate())
                      : DateFormat('hh:mm a')
                          .format(message.messageCreatedTime.toDate()),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            Text(isSender ? _sender!.username! : _recipient!.username!),
            ChatBubbleComponent(
              message: message.messageContent,
              isSender: isSender,
            )
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
              controller: _messageController,
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
