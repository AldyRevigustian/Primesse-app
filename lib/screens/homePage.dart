import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:primesse_app/models/chatUsersMode.dart';
import 'package:primesse_app/screens/chatDetailPage.dart';
import 'package:primesse_app/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String history = "";
  bool isFavOnly = false;
  List<String> favList = [];
  List<ChatUsers> foundUser = [];
  List<ChatUsers> allUsers = chatUsers;
  ScrollController scrollController = ScrollController(
    keepScrollOffset: true,
  );

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

  Future<void> loadList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favListString = prefs.getString('favList');
    if (favListString != null && favListString.isNotEmpty) {
      setState(() {
        favList = favListString.split(',');
      });
    }
    changeFav();
  }

  @override
  void initState() {
    fetchHistory();
    foundUser = allUsers;
    loadList();
    super.initState();
  }

  String formatDate(date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        DateFormat('EEEE, dd MMMM yyyy HH:mm').format(dateTime);
    return formattedDate;
  }

  void changeFav() {
    foundUser.forEach((element) {
      if (favList.contains(element.name)) {
        element.isFav = true;
        foundUser.remove(element);
        foundUser.insert(0, element);
      } else {
        element.isFav = false;
      }
    });
  }

  Future<void> saveList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('favList', favList.join(','));
  }

  Future<void> removeItem(String item) async {
    favList.remove(item);
    await saveList();
  }

  Future<void> addItem(String item) async {
    favList.add(item);
    await saveList();
  }

  void runFilter(String key) {
    List<ChatUsers> result = [];
    if (isFavOnly) {
      if (key.isEmpty) {
        result = allUsers.where((element) => element.isFav).toList();
      } else {
        result = allUsers
            .where((element) =>
                element.name.toLowerCase().contains(key.toLowerCase()))
            .where((element) => element.isFav)
            .toList();
      }
    } else {
      if (key.isEmpty) {
        result = allUsers;
      } else {
        result = allUsers
            .where((element) =>
                element.name.toLowerCase().contains(key.toLowerCase()))
            .toList();
      }
    }

    setState(() {
      foundUser = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustColors.secondaryColor,
      appBar: AppBar(
        toolbarHeight: 185,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)), side: BorderSide.none),
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
                              isFavOnly = !isFavOnly;

                              if (isFavOnly) {
                                foundUser = foundUser
                                    .where((element) => element.isFav)
                                    .toList();
                              } else {
                                foundUser = allUsers;
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100)),
                            padding: EdgeInsets.all(13),
                            child: isFavOnly
                                ? Icon(
                                    FluentIcons.star_20_filled,
                                    color: Colors.yellow[700],
                                  )
                                : Icon(
                                    FluentIcons.star_20_filled,
                                    color: CustColors.tersierColor
                                        .withOpacity(0.3),
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
              controller: scrollController,
              cacheExtent: 9999,
              itemCount: foundUser.length,
              padding: const EdgeInsets.only(
                  bottom: 20, top: 10, left: 20, right: 20),
              physics: const BouncingScrollPhysics(),
              // addAutomaticKeepAlives: true,
              itemBuilder: (context, index) {
                return Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        splashColor: CustColors.tersierColor.withOpacity(0.3),
                        highlightColor:
                            CustColors.tersierColor.withOpacity(0.2),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ChatDetailPage(
                                name: foundUser[index].name);
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: AssetImage(
                                                foundUser[index].imageURL),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  foundUser[index].name,
                                                  style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                SizedBox(
                                                  height: 0,
                                                ),
                                                Text(
                                                  foundUser[index].messageText,
                                                  style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Colors.grey.shade600),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                            child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    foundUser[index].isFav =
                                                        !foundUser[index].isFav;

                                                    ChatUsers item =
                                                        foundUser[index];

                                                    if (item.isFav) {
                                                      chatUsers.removeAt(index);
                                                      chatUsers.insert(0, item);
                                                      addItem(item.name);
                                                    } else {
                                                      chatUsers.removeAt(index);
                                                      chatUsers.add(item);
                                                      removeItem(item.name);
                                                    }

                                                    scrollController.animateTo(
                                                        0.0,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        curve: Curves.easeOut);
                                                  });
                                                },
                                                icon: foundUser[index].isFav
                                                    ? Icon(
                                                        FluentIcons
                                                            .star_20_filled,
                                                        size: 25,
                                                        color:
                                                            Colors.yellow[700],
                                                      )
                                                    : Icon(
                                                        FluentIcons
                                                            .star_20_filled,
                                                        size: 25,
                                                        color: CustColors
                                                            .tersierColor
                                                            .withOpacity(0.3),
                                                      )))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
