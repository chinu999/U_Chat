import 'package:flutter/material.dart';
import 'package:u_chat/login/ui/login_page.dart';
import 'package:u_chat/screens/chat_screen.dart';

void main() => runApp(Uchat());

class Uchat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uchat',
      initialRoute: LoginPage.id,
      routes: {
        ChatScreen.id: (context) => ChatScreen(),
        LoginPage.id: (context) => LoginPage(),
      },
    );
  }
}
