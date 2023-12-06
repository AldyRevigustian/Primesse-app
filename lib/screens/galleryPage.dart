import 'package:flutter/material.dart';
import 'package:primesse_app/models/chatUsersMode.dart';
import 'package:primesse_app/screens/galleryView.dart';
import 'package:primesse_app/utils/constant.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<ChatUsers> allUsers = chatUsers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustColors.secondaryColor,
      body: SafeArea(
        child: Center(
          child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20),
              itemCount: allUsers.length,
              itemBuilder: (BuildContext ctx, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(allUsers[index].imageURL),
                                  fit: BoxFit.cover,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)),
                            // child: Text("AAA"),
                          ),
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.white.withOpacity(0.3),
                                  highlightColor: Colors.white.withOpacity(0.2),
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return GalleryView(
                                        name: allUsers[index].name,
                                        generasi: allUsers[index].messageText,
                                        image: allUsers[index].imageURL,
                                      );
                                    }));
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      allUsers[index].name,
                      style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Text(
                      allUsers[index].messageText,
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
