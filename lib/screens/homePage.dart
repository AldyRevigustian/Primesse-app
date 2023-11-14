import 'package:flutter/material.dart';
import 'package:primesse_app/screens/chatPage.dart';

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ChatPage(),
    );
  }
}