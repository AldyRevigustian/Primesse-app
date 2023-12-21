import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:primesse_app/models/chatUsersMode.dart';
import 'package:primesse_app/utils/constant.dart';
import 'package:primesse_app/widgets/audioPlayer.dart';
import 'package:primesse_app/widgets/imagePreview.dart';

class ChatDetailPage extends StatefulWidget {
  final String name;
  ChatDetailPage({required this.name});
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late ChatUsers? member;

  List messages = [];
  bool isLoading = false;
  late ScrollController _scrollController;
  late DocumentSnapshot lastMessage;

  @override
  void initState() {
    super.initState();
    member = chatUsers.firstWhere(
      (user) => user.name == widget.name,
    );
    _scrollController = ScrollController()..addListener(_scrollListener);
    loadMessages();
  }

  Future<void> loadMessages() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      List newMessages = await fetchMessages(
        20,
        messages.isNotEmpty ? lastMessage : null,
      );
      setState(() {
        messages.addAll(newMessages);
        if (newMessages.length != 0) {
          lastMessage = newMessages[newMessages.length - 1];
        }

        isLoading = false;
      });
    }
  }

  Future<void> loadMore() async {
    List newMessages = await fetchMessages(
      20,
      messages.isNotEmpty ? lastMessage : null,
    );
    setState(() {
      messages.addAll(newMessages);
      if (newMessages.length != 0) {
        lastMessage = newMessages[newMessages.length - 1];
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      loadMore();
    }
    // if (_scrollController.offset >=
    //         _scrollController.position.maxScrollExtent &&
    //     !_scrollController.position.outOfRange) {
    //   loadMore();
    // }
  }

  final customCacheManager = CacheManager(Config(
    'customCacheKey',
    stalePeriod: Duration(days: 365),
    maxNrOfCacheObjects: 999999,
    repo: JsonCacheInfoRepository(databaseName: 'customCache'),
  ));

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<List> fetchMessages(int limit, DocumentSnapshot? startAfter) async {
    late QuerySnapshot querySnapshot;
    if (startAfter != null) {
      querySnapshot = await FirebaseFirestore.instance
          .collection(widget.name)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(startAfter)
          .limit(limit)
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection(widget.name)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
    }

    return querySnapshot.docs;
  }

  String formatDate(date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('dd MMMM yyyy HH:mm').format(dateTime);
    return formattedDate;
  }

  String formatName(date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('dd-MM-yyyy-HHmmss').format(dateTime);
    return "" + formattedDate + ".mp3";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            ClipOval(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    FluentIcons.chevron_left_20_filled,
                    color: CustColors.tersierColor,
                    size: 30,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(member!.imageURL),
              maxRadius: 20,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.name,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    member!.messageText,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      backgroundColor: CustColors.secondaryColor,
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: CustColors.secondaryColor),
              child: isLoading
                  ? Center(
                      child: SpinKitFadingCircle(
                        color: CustColors.tersierColor.withOpacity(0.3),
                        size: 30,
                      ),
                    )
                  : ListView.builder(
                      cacheExtent: 9999,
                      controller: _scrollController,
                      itemCount: messages.length + 1,
                      reverse: true,
                      shrinkWrap: true,
                      padding: EdgeInsets.all(15),
                      itemBuilder: (context, index) {
                        if (index < messages.length) {
                          return Container(
                            padding: EdgeInsets.only(
                                left: 14, right: 14, top: 10, bottom: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  messages[index]["format"] == 'text'
                                      ? Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              color: Colors.white),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 15),
                                          child: Text(
                                            messages[index]["message"],
                                            style: TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 14,
                                                color: Colors.black),
                                          ))
                                      : messages[index]["format"] == 'image'
                                          ? Container(
                                              height: 300,
                                              width: 230,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                child: Stack(
                                                  children: [
                                                    CachedNetworkImage(
                                                        cacheManager:
                                                            customCacheManager,
                                                        imageUrl:
                                                            messages[index]
                                                                ["message"],
                                                        progressIndicatorBuilder:
                                                            (context, url,
                                                                    downloadProgress) =>
                                                                Center(
                                                                  child:
                                                                      SpinKitFadingCircle(
                                                                    color: CustColors
                                                                        .tersierColor
                                                                        .withOpacity(
                                                                            0.3),
                                                                    size: 30,
                                                                  ),
                                                                ),
                                                        memCacheWidth: 300,
                                                        height: 300,
                                                        width: 230,
                                                        fit: BoxFit.cover,
                                                        errorWidget: (context,
                                                            url, error) {
                                                          return IconButton(
                                                            onPressed: () {
                                                              customCacheManager
                                                                  .removeFile(url);
                                                            },
                                                            icon: Icon(
                                                                Icons.error,
                                                                color: CustColors
                                                                    .tersierColor
                                                                    .withOpacity(
                                                                        0.3),
                                                                size: 30),
                                                          );
                                                        }),
                                                    Positioned.fill(
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                              return ImagePreview(
                                                                  name: widget
                                                                      .name,
                                                                  generasi: member!
                                                                      .messageText,
                                                                  image: member!
                                                                      .imageURL,
                                                                  url: messages[
                                                                          index]
                                                                      [
                                                                      "message"]);
                                                            }));
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: Material(
                                                color: Colors.white,
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return AudioPlayerScreen(
                                                          name: formatName(
                                                              messages[index][
                                                                  "createdAt"]),
                                                          url: messages[index]
                                                              ["message"]);
                                                    }));
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 15,
                                                            horizontal: 15),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                            child: Icon(FluentIcons
                                                                .music_note_2_20_filled)),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(formatName(
                                                            messages[index]
                                                                ["createdAt"]))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    formatDate(messages[index]["createdAt"]),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: CustColors.tersierColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (isLoading) {
                          // return Padding(
                          //   padding: EdgeInsets.all(10),
                          //   child: const Center(
                          //     child: CircularProgressIndicator(),
                          //   ),
                          // );
                        }
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
