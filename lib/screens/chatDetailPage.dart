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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:grouped_list/grouped_list.dart';

class ChatDetailPage extends StatefulWidget {
  final String name;
  ChatDetailPage({required this.name});
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late ChatUsers? member;
  String lastDate = "";
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
    fetchFirstMessage();
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
    late QuerySnapshot lastM;

    if (startAfter != null) {
      var collectionRef = FirebaseFirestore.instance
          .collection(widget.name)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(startAfter);

      lastM = await collectionRef.limit(1).get();

      if (lastM.size != 0) {
        querySnapshot = await collectionRef
            .where('createdAt',
                isGreaterThanOrEqualTo: dateAgo(lastM.docs[0]['createdAt'], 5))
            .get();
      }
    } else {
      var collRef = FirebaseFirestore.instance
          .collection(widget.name)
          .orderBy('createdAt', descending: true);

      var lowerBoundDate = dateAgo(lastDate, 5);

      querySnapshot = await collRef
          .where('createdAt', isGreaterThanOrEqualTo: lowerBoundDate)
          .get();

      if (querySnapshot.size < 10) {
        print("Very LOW");
        lowerBoundDate = dateAgo(lastDate, 30);
      } else if (querySnapshot.size < 20) {
        print("LOW");
        lowerBoundDate = dateAgo(lastDate, 20);
      } else if (querySnapshot.size < 30) {
        print("Medium");
        lowerBoundDate = dateAgo(lastDate, 10);
      }

      querySnapshot = await collRef
          .where('createdAt', isGreaterThanOrEqualTo: lowerBoundDate)
          .get();
      print(querySnapshot.size);
    }

    return querySnapshot.docs;
  }

  Future<void> fetchFirstMessage() async {
    late QuerySnapshot querySnapshot;

    querySnapshot = await FirebaseFirestore.instance
        .collection(widget.name)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    setState(() {
      lastDate = querySnapshot.docs[0]['createdAt'];
    });

    if (!isLoading && lastDate.isNotEmpty) {
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

  String formatDate(date) {
    DateTime dateTime = DateTime.parse(date);
    dateTime = dateTime.add(const Duration(hours: 7));

    String formattedDate = DateFormat('HH:mm:ss', "id_ID").format(dateTime);
    return formattedDate;
  }

  String dateAgo(date, int amount) {
    DateTime now = DateTime.parse(date);
    DateTime fiveDaysAgo = now.subtract(Duration(days: amount));
    String formattedDate =
        DateFormat('yyyy-MM-dd', "id_ID").format(fiveDaysAgo);
    return formattedDate;
  }

  String formatDateOnly(date) {
    DateTime dateTime = DateTime.parse(date);
    dateTime = dateTime.add(const Duration(hours: 7));
    String formattedDate =
        DateFormat('EEEE, dd MMMM yyyy', "id_ID").format(dateTime);
    return formattedDate;
  }

  String formatName(date) {
    DateTime dateTime = DateTime.parse(date);

    dateTime = dateTime.add(const Duration(hours: 7));
    String formattedDate =
        DateFormat('dd-MM-yyyy-HHmmss', "id_ID").format(dateTime);
    return "" + formattedDate + ".mp3";
  }

  @override
  Widget build(BuildContext context) {
    final Uri _url = Uri.parse(
        'https://twitter.com/intent/tweet?text=${member!.twitter}&hashtags=${member!.hashtag}%20');

    Future<void> _launchUrl() async {
      if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    }

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        actions: [
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/x.svg',
                  width: 24,
                  height: 24,
                ),
                splashRadius: 30,
                onPressed: _launchUrl,
              ),
              SizedBox(
                width: 10,
              )
            ],
          )
        ],
        leading: IconButton(
          icon: Icon(
            FluentIcons.chevron_left_20_filled,
            color: CustColors.tersierColor,
            size: 30,
          ),
          splashRadius: 30,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
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
                  : GroupedListView(
                      sort: false,
                      groupSeparatorBuilder: (String groupByValue) => Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: width / 6,
                                height: 1,
                                decoration: BoxDecoration(
                                    color: CustColors.tersierColor
                                        .withOpacity(0.3)),
                              ),
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 0),
                                  child: Text(
                                    groupByValue,
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 12,
                                        color: CustColors.tersierColor
                                            .withOpacity(0.6)),
                                  )),
                              Container(
                                width: width / 6,
                                height: 1,
                                decoration: BoxDecoration(
                                    color: CustColors.tersierColor
                                        .withOpacity(0.3)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      elements: messages,
                      groupBy: (element) =>
                          formatDateOnly(element['createdAt']),
                      cacheExtent: 9999,
                      controller: _scrollController,
                      reverse: true,
                      shrinkWrap: true,
                      padding: EdgeInsets.all(15),
                      itemBuilder: (context, element) {
                        return Container(
                          padding: EdgeInsets.only(
                              left: 14, right: 14, top: 10, bottom: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                element["format"] == 'text'
                                    ? Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: Colors.white),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 15),
                                        child: Text(
                                          element["message"],
                                          style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 14,
                                              color: Colors.black),
                                        ))
                                    : element["format"] == 'image'
                                        ? Container(
                                            height: 300,
                                            width: 230,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: Stack(
                                                children: [
                                                  CachedNetworkImage(
                                                      cacheManager:
                                                          customCacheManager,
                                                      imageUrl:
                                                          element["message"],
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
                                                                .removeFile(
                                                                    url);
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
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                            return ImagePreview(
                                                                name:
                                                                    widget.name,
                                                                generasi: member!
                                                                    .messageText,
                                                                image: member!
                                                                    .imageURL,
                                                                url: element[
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
                                                            element[
                                                                "createdAt"]),
                                                        url:
                                                            element["message"]);
                                                  }));
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
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
                                                          element["createdAt"]))
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
                                  formatDate(element["createdAt"]) + " WIB",
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
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
