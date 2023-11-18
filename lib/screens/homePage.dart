import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:primesse_app/models/chatUsersMode.dart';
import 'package:primesse_app/utils/constant.dart';
import 'package:primesse_app/widgets/conversationList.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatUsers> allUsers = chatUsers;
  List<ChatUsers> foundUser = [];
  bool isReverse = false;

  void runFilter(String key) {
    List<ChatUsers> result = [];
    if (key.isEmpty) {
      result = allUsers;
    } else {
      result = allUsers
          .where((element) =>
              element.name.toLowerCase().contains(key.toLowerCase()))
          .toList();
    }

    setState(() {
      foundUser = result;
    });
  }

  String history = "";
  Future<List> fetchHistory() async {
    late QuerySnapshot querySnapshot;

    querySnapshot = await FirebaseFirestore.instance
        .collection("History")
        .orderBy('last_update', descending: true)
        .limit(1)
        .get();

    setState(() {
      history = querySnapshot.docs[0]['last_update'];
    });
    return querySnapshot.docs;
  }

  @override
  void initState() {
    fetchHistory();
    foundUser = allUsers;

    super.initState();
  }

  String formatDate(date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        DateFormat('EEEE, dd MMMM yyyy HH:mm').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustColors.secondaryColor,
      appBar: AppBar(
        toolbarHeight: 185,
        elevation: 1,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Column(
            children: [
              Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/PM.png",
                        height: 50,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        history == "" ? "Loading" : formatDate(history),
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      )
                    ]),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      onChanged: (value) => runFilter(value),
                      style: TextStyle(
                          color: CustColors.tersierColor,
                          fontFamily: "Poppins"),
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            FluentIcons.search_20_regular,
                            color: CustColors.tersierColor,
                          ),
                          filled: true,
                          contentPadding: EdgeInsets.all(10),
                          fillColor: CustColors.secondaryColor,
                          hintText: "Search",
                          hintStyle: TextStyle(color: CustColors.tersierColor),
                          border: OutlineInputBorder(
                              gapPadding: 10,
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(50)),
                          focusedBorder: OutlineInputBorder(
                              gapPadding: 10,
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              gapPadding: 10,
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(50))),
                    )),
                    SizedBox(
                      width: 10,
                    ),
                    ClipOval(
                      child: Material(
                        color: CustColors.secondaryColor,
                        child: InkWell(
                          splashColor: CustColors.tersierColor.withOpacity(0.3),
                          highlightColor:
                              CustColors.tersierColor.withOpacity(0.2),
                          onTap: () {
                            setState(() {
                              isReverse = !isReverse;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100)),
                            padding: EdgeInsets.all(13),
                            child: Icon(
                              FluentIcons.arrow_sort_20_regular,
                              color: CustColors.tersierColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: foundUser.length,
              padding: const EdgeInsets.only(
                  bottom: 20, top: 10, left: 20, right: 20),
              physics: const BouncingScrollPhysics(),
              reverse: isReverse,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ConversationList(
                    name: foundUser[index].name,
                    messageText: foundUser[index].messageText,
                    imageUrl: foundUser[index].imageURL,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
