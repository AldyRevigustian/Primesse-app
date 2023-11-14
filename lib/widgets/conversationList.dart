import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:primesse_app/screens/chatDetailPage.dart';
import 'package:primesse_app/utils/constant.dart';

class ConversationList extends StatefulWidget {
  final String name;
  final String messageText;
  final String imageUrl;
  ConversationList(
      {required this.name, required this.messageText, required this.imageUrl});
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
      borderRadius: BorderRadius.circular(25),
        splashColor: CustColors.tersierColor.withOpacity(0.3),
        highlightColor: CustColors.tersierColor.withOpacity(0.2),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChatDetailPage(
                name: widget.name,
                generasi: widget.messageText,
                image: widget.imageUrl);
          }));
        },
        child: Container(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Container(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(widget.imageUrl),
                            maxRadius: 27,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.name,
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 0,
                                ),
                                Text(
                                  widget.messageText,
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Container(
                            child: Icon(
                              FluentIcons.chevron_right_20_filled,
                              size: 25,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
