import 'package:flutter/material.dart';
import 'package:u_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextContoller = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection("messages").snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
      }
    }
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
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Center(
          child: Hero(
            tag: 'logo',
            child: Container(
              child: Image.asset('images/anchor-point.png'),
              height: 40.0,
            ),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image(
              image: new AssetImage("images/background.jpg"),
              fit: BoxFit.cover,
              color: Colors.black54,
              colorBlendMode: BlendMode.darken,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Form(
                  child: new Theme(
                    data: new ThemeData(
                      brightness: Brightness.dark,
                      primarySwatch: Colors.teal,
                      inputDecorationTheme: new InputDecorationTheme(
                        labelStyle: new TextStyle(
                          color: Colors.teal,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    child: new Container(
                      padding: const EdgeInsets.all(50),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),

                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                MessagesStream(),
                Container(
                  decoration: kMessageContainerDecoration,
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          color: Colors.white70,
                          child: TextField(
                            controller: messageTextContoller,
                            onChanged: (value) {
                              messageText = value;
                            },
                            decoration:
                            kMessageTextFieldDecoration,
                          ),
                        ),
                      ),
                      RaisedButton.icon(
                        color: Colors.transparent,
                        onPressed: () {
                          messageTextContoller.clear();
                          _firestore
                              .collection("messages")
                              .add({
                            "text": messageText,
                            "sender": loggedInUser.email,
                            "time": DateTime.now(),
                          });
                        },
                        label: Text(
                          '',
                          style: TextStyle(
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(
                          Icons.send,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      stream: _firestore.collection("messages").snapshots(),
      // ignore: missing_return
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data['text'];
          final messageSender = message.data["sender"];
          final messageTime = message.data["time"];
          final currentUsser = loggedInUser.email;
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            time: messageTime,
            isMe: currentUsser == messageSender,
          );
          messageBubbles.add(messageBubble);
          messageBubbles.sort((a, b) => b.time.compareTo(a.time));
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final Timestamp time;
  final bool isMe;

  MessageBubble({this.sender, this.text, this.isMe, this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "$sender ${time.toDate()}",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.greenAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
