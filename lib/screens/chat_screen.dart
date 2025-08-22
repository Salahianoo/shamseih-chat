import 'package:flutter/material.dart';

import '../core/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Firebase/firebase_notification.dart';
import '../services/notification_service.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  const ChatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseNotification _firebaseNotification = FirebaseNotification();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? loggedInUser;
  String messageText = '';
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loggedInUser = _auth.currentUser;
    _firebaseNotification.init(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              //Implement logout functionality
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: Text('☂️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data!.docs;
                  List<Widget> messageWidgets = [];
                  for (var message in messages) {
                    final messageText = message['text'];
                    final messageSender = message['sender'];
                    final isMe = loggedInUser?.email == messageSender;
                    messageWidgets.add(
                      Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 12.w,
                              right: 12.w,
                              bottom: 2.h,
                            ),
                            child: Text(
                              messageSender ?? '',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: GestureDetector(
                              onLongPress: isMe
                                  ? () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          // ignore: unused_local_variable
                                          String editedText = messageText ?? '';
                                          return Wrap(
                                            children: [
                                              ListTile(
                                                leading: Icon(Icons.edit),
                                                title: Text('Edit'),
                                                onTap: () async {
                                                  Navigator.pop(context);
                                                  TextEditingController
                                                  editController =
                                                      TextEditingController(
                                                        text: messageText ?? '',
                                                      );
                                                  await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          'Edit Message',
                                                        ),
                                                        content: TextField(
                                                          controller:
                                                              editController,
                                                          autofocus: true,
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            child: Text(
                                                              'Cancel',
                                                            ),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                ),
                                                          ),
                                                          TextButton(
                                                            child: Text('Save'),
                                                            onPressed: () async {
                                                              await message
                                                                  .reference
                                                                  .update({
                                                                    'text':
                                                                        editController
                                                                            .text,
                                                                  });
                                                              Navigator.pop(
                                                                // ignore: use_build_context_synchronously
                                                                context,
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.delete),
                                                title: Text('Unsend'),
                                                onTap: () async {
                                                  await message.reference
                                                      .delete();
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  : null,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 2.h,
                                  horizontal: 8.w,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 10.h,
                                  horizontal: 16.w,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.lightBlueAccent
                                      // ignore: deprecated_member_use
                                      : Colors.deepPurpleAccent.withOpacity(
                                          0.8,
                                        ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.r),
                                    topRight: Radius.circular(12.r),
                                    bottomLeft: isMe
                                        ? Radius.circular(12.r)
                                        : Radius.circular(0),
                                    bottomRight: isMe
                                        ? Radius.circular(0)
                                        : Radius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  messageText ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  // Scroll to bottom when new messages arrive
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });
                  return ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    reverse: false,
                    children: messageWidgets,
                  );
                },
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (messageText.isNotEmpty) {
                        // Add message to Firestore
                        await _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser?.email,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        // Send notification to other users
                        if (loggedInUser?.email != null) {
                          await NotificationService.sendMessageNotification(
                            senderEmail: loggedInUser!.email!,
                            messageText: messageText,
                          );
                        }

                        setState(() {
                          messageText = '';
                          messageController.clear();
                        });
                        // Scroll to bottom after sending
                        Future.delayed(Duration(milliseconds: 100), () {
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent,
                            );
                          }
                        });
                      }
                    },
                    child: Text('Send', style: kSendButtonTextStyle),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
