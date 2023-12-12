import 'package:flutter/material.dart';
import 'package:flash_chat/Constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Registration_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
late User LoggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'Chat_Screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  late String messageText;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      // Future:
      // Firebase.initializeApp();
      final user = _auth.currentUser;
      if (user != null) {
        LoggedInUser = user;
        // print(LoggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _fireStore.collection('messages').get();
  //   for (var message in messages.docs) {
  //     print(message.data);
  //   }
  // }

  void messagesStream() async {
    await for (var snapshot in _fireStore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffCEC29C),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                // messagesStream();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: const Text('🐝Chat'),
        backgroundColor: const Color(0xFF5C3600),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //messageText +LoggedInUser.email
                      // _auth.signOut();
                      // Navigator.pop(context);
                      messageTextController.clear();
                      _fireStore.collection('messages').add({
                        'text': messageText,
                        'sender': LoggedInUser.email,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          // if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.brown,
            ),
          );
          // }
        }

        final messages = snapshot?.data.docs;

        return Expanded(
          child: ListView.builder(
            reverse: true,
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            itemBuilder: (context, position) {
              final messageText = messages[position].data()['text'];
              final messageSender = messages[position].data()['sender'];
              final currentUser = LoggedInUser.email;

              return MessageBubble(
                sender: messageSender,
                text: messageText,
                isMe: currentUser == messageSender,
              );
            },
          ),
        );

        //return Text('');
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({required this.sender, required this.text, required this.isMe});
  final String sender;
  final String text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Image.network(''),
          Text(
            sender,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black,
            ),
          ),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe ? const Color(0xFFE48518) : const Color(0xffF6C221),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    '$text',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
