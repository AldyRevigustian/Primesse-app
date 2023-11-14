import 'package:flutter/material.dart';
import 'package:primesse_app/models/chatUsersMode.dart';
import 'package:primesse_app/widgets/conversationList.dart';

class ChatPage extends StatefulWidget {
  final bool isReverse;
  final List<ChatUsers> foundUser;
  ChatPage({required this.isReverse, required this.foundUser});
  
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ListView.builder(
                itemCount: widget.foundUser.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 20, top: 10),
                physics: NeverScrollableScrollPhysics(),
                reverse: widget.isReverse,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: ConversationList(
                      name: widget.foundUser[index].name,
                      messageText: widget.foundUser[index].messageText,
                      imageUrl: widget.foundUser[index].imageURL,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
