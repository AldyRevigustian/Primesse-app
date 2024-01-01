import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:primesse_app/utils/constant.dart';

class ImagePreview extends StatefulWidget {
  final String url;
  final String name;
  final String generasi;
  final String image;
  const ImagePreview(
      {required this.url,
      required this.name,
      required this.generasi,
      required this.image});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              FluentIcons.arrow_download_20_regular,
              size: 30,
            ),
            onPressed: () => downloadImage(widget.url),
          ),
        ],
        leading: IconButton(
          icon: Icon(
            FluentIcons.chevron_left_20_filled,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        foregroundColor: CustColors.secondaryColor,
      ),
      body: SafeArea(
          child: PhotoView(
              loadingBuilder: (context, event) {
                if (event != null) {
                  return Center(
                      child: SpinKitFadingCircle(
                    color: CustColors.primaryWhite.withOpacity(0.5),
                    size: 30,
                  ));
                } else {
                  return Container();
                }
              },
              imageProvider: NetworkImage(widget.url))),
    );
  }

  Future<void> downloadImage(String imageUrl) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image downloaded successfully!'),
          ),
        );
        _moveToGallery(savePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download image'),
          ),
        );
      }
    } else {
      await Permission.storage.request();
      print(status.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission denied'),
        ),
      );
    }
  }

  Future<void> _moveToGallery(String filePath) async {
    final result = await ImageGallerySaver.saveFile(filePath);
    print(result);
  }
}
