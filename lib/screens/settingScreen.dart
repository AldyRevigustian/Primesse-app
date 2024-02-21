import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:primesse_app/utils/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String? _selectedItem;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  List favList = [];

  @override
  void initState() {
    loadList();
    getPref();
    super.initState();
  }

  Future<void> loadList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favListString = prefs.getString('favList');
    if (favListString != null && favListString.isNotEmpty) {
      setState(() {
        favList = favListString.split(',');
      });
      print(favList);
    }
  }

  void getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? isAllNotif = prefs.getString('isAllNotif');

    if (isAllNotif == null || isAllNotif == "" || isAllNotif == "true") {
      setState(() {
        _selectedItem = "All Member";
      });
      setAllMember();
    } else {
      setState(() {
        _selectedItem = "Favorite Member";
      });
      setFavoriteMember();
    }
  }

  void setPref(String isAllNotif) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('isAllNotif', isAllNotif);
    print('success');
  }

  void setFavoriteMember() async {
    await messaging.unsubscribeFromTopic("ALL");
    await Future.wait(favList.map((e) => messaging.subscribeToTopic(e)));
  }

  void setAllMember() async {
    await messaging.subscribeToTopic("ALL");
    await Future.wait(favList.map((e) => messaging.unsubscribeFromTopic(e)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustColors.secondaryColor,
      appBar: AppBar(
        toolbarHeight: 120,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
            side: BorderSide.none),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            children: [
              Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/PM.png",
                        height: 60,
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notification Setting",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline:
                            Container(), // This line disables the underline
                        value: _selectedItem,
                        onChanged: (String? newValue) {
                          if (newValue == "All Member") {
                            setPref("true");
                            setAllMember();
                          } else {
                            setPref("false");
                            setFavoriteMember();
                          }
                          setState(() {
                            _selectedItem = newValue;
                          });
                        },
                        items: <String>["All Member", "Favorite Member"]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
