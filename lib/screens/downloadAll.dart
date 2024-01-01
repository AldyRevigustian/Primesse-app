import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:primesse_app/utils/constant.dart';

class DownloadAllPage extends StatefulWidget {
  final String name;
  const DownloadAllPage({super.key, required this.name});

  @override
  State<DownloadAllPage> createState() => _DownloadAllPageState();
}

class _DownloadAllPageState extends State<DownloadAllPage> {
  List allImage = [];
  double _percent = 0.0;
  int _progress = 0;
  int length = 0;
  bool isDownloading = false;
  bool stop = false;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    late QuerySnapshot querySnapshot;

    querySnapshot = await FirebaseFirestore.instance
        .collection(widget.name)
        .orderBy('createdAt', descending: true)
        .where('format', isEqualTo: 'image')
        .get();

    querySnapshot.docs.forEach((document) {
      String message = document['message'];
      allImage.add(message);
    });

    setState(() {
      length = allImage.length;
    });
  }

  void downloadAll(BuildContext context) async {
    for (int i = 0; i < allImage.length && stop == false; i++) {
      String url = allImage[i];
      try {
        bool res = await downloadImage(url);
        if (res) {
          setState(() {
            _progress = i + 1;
            _percent = (i + 1) / allImage.length;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download Failed'),
            ),
          );
        }
      } catch (e) {
        print('Error downloading $url: $e');
      }
    }

    setState(() {
      isDownloading = false;
      stop = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_progress.toString() + " Image Downloaded"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 10.0,
            percent: _percent,
            center: Text(_progress.toString() + "/" + length.toString()),
            progressColor: Colors.blue,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: isDownloading == true
                  ? Colors.red // Set your desired background color
                  : CustColors.primaryColor,
              onPrimary: Colors.white, // Set the text color
            ),
            onPressed: () {
              if (isDownloading == true) {
                setState(() {
                  stop = true;
                  isDownloading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_progress.toString() + " Image Downloaded"),
                  ),
                );
              } else {
                setState(() {
                  stop = false;
                  isDownloading = true;
                });

                downloadAll(context);
              }
            },
            child:
                Text(isDownloading ? "Stop Downloading" : "Download All Image"),
          ),
        ],
      ),
    ));
  }

  Future<bool> downloadImage(String imageUrl) async {
    var status2 = await Permission.manageExternalStorage.request();
    var status3 = await Permission.mediaLibrary.request();

    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    final status = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (status.isGranted && status2.isGranted && status3.isGranted) {
      var response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final appDir = await getExternalStorageDirectory();
        final filename = 'downloaded_image.png';
        final savePath = appDir!.path + '/' + filename;

        await File(savePath).writeAsBytes(response.bodyBytes);
        _moveToGallery(savePath);
        return true;
      } else {
        return false;
      }
    } else {
      await Permission.storage.request();
      print(status.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission denied'),
        ),
      );
      return false;
    }
  }

  Future<void> _moveToGallery(String filePath) async {
    final result = await ImageGallerySaver.saveFile(filePath);
    print(result);
  }
}
