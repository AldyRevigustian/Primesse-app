import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:primesse_app/utils/constant.dart';
import 'package:primesse_app/widgets/imagePreview.dart';

class GalleryView extends StatefulWidget {
  final String name;
  final String generasi;
  final String image;
  const GalleryView(
      {super.key,
      required this.name,
      required this.generasi,
      required this.image});

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  List messages = [];
  bool isLoading = false;
  late ScrollController _scrollController;
  late DocumentSnapshot lastMessage;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    loadMessages();
  }

  Future<void> loadMessages() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      List newMessages = await fetchMessages(
        21,
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
      21,
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
  }

  final customCacheManager = CacheManager(Config(
    'customCacheKey',
    stalePeriod: Duration(days: 15),
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
          .where('format', isEqualTo: 'image')
          .get();
      querySnapshot.docs.map((e) {
        print(e.data().toString());
      }).toList();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection(widget.name)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .where('format', isEqualTo: 'image')
          .get();
    }

    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 150,
        centerTitle: true,
        elevation: 1,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
            side: BorderSide.none),
        title: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(widget.image),
                maxRadius: 40,
              ),
            ),
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
              widget.generasi,
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: GridView.builder(
                cacheExtent: 99999,
                controller: _scrollController,
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 20, top: 20),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    childAspectRatio: 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5),
                itemCount: messages.length,
                itemBuilder: (BuildContext ctx, index) {
                  return isLoading
                      ? Center(
                          child: SpinKitFadingCircle(
                            color: CustColors.tersierColor.withOpacity(0.3),
                            size: 30,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                cacheManager: customCacheManager,
                                imageUrl: messages[index]["message"],
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
                                  child: SpinKitFadingCircle(
                                    color: CustColors.tersierColor
                                        .withOpacity(0.3),
                                    size: 30,
                                  ),
                                ),
                                memCacheWidth: 200,
                                // maxHeightDiskCache: 150,
                                // memCacheWidth: 150,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    color: CustColors.tersierColor
                                        .withOpacity(0.3),
                                    size: 30),
                              ),
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return ImagePreview(
                                            name: widget.name,
                                            generasi: widget.generasi,
                                            image: widget.image,
                                            url: messages[index]["message"]);
                                      }));
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                }),
          ),
        ]),
      ),
    );
  }
}
