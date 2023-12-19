// import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flash_chat/Constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

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

  // Future Image() async {
  //   final file = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (file == null) return;
  //   Reference ref = FirebaseStorage.instance.ref().child('images');
  //   try {
  //     await ref.putFile(File(file.path));
  //     String imageUrl = await ref.getDownloadURL();
  //     print(imageUrl);
  //   } catch (error) {
  //     print(error);
  //   }
  // }
  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!);
    String ImageUrl = await uploadTask.ref.getDownloadURL();
    await _fireStore.collection('messages').add({
      'sender': LoggedInUser.email,
      'url': ImageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
    ;
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
                  IconButton(
                      onPressed: () {
                        getImage();
                      },
                      icon: Icon(Icons.photo_sharp)),
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
            itemCount: messages.length,
            itemBuilder: (context, position) {
              final messageText = messages[position].data()['text'];
              final messageSender = messages[position].data()['sender'];
              final currentUser = LoggedInUser.email;
              final Imageurl = messages[position].data()['url'];

              return MessageBubble(
                sender: messageSender,
                text: messageText ?? '',
                imageUrl: Imageurl ?? '',
                isMe: currentUser == messageSender,
              );
            },
          ),
        ); //return Text('');
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.sender,
      required this.text,
      required this.isMe,
      required this.imageUrl});
  final String sender;
  final String text;
  final bool isMe;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      topRight: Radius.circular(30.0)),
              color: isMe ? const Color(0xFFE48518) : const Color(0xffF6C221),
            ),
            child: Column(
              children: [
                if (imageUrl.isEmpty)
                  SizedBox()
                else
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                    ),
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      width: 200,
                    ),
                  ),
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
