import 'package:flutter/material.dart';
import 'package:primesse_app/screens/chatPage.dart';
import 'package:primesse_app/utils/constant.dart';

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustColors.secondaryColor,
      body: ChatPage(),
    );
  }
}