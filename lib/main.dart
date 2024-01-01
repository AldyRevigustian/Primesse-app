import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:primesse_app/firebase_options.dart';
import 'package:primesse_app/screens/chatDetailPage.dart';
import 'package:primesse_app/screens/loading.dart';
import 'package:primesse_app/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.subscribeToTopic("ALL");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const initialzationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_stat_pm');
  const initializationSettings =
      InitializationSettings(android: initialzationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      Navigator.push(
        MyApp.navigatorKey.currentState!.context,
        MaterialPageRoute(
          builder: (context) => ChatDetailPage(
            name: details.payload!,
          ),
        ),
      );
    },
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.data['type'].toString() == "image") {
      Future<String> getImageFilePath(String assetPath) async {
        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes = data.buffer.asUint8List();

        Directory tempDir = await getTemporaryDirectory();
        String tempPath = '${tempDir.path}/temp_image.png';
        File tempFile = File(tempPath);
        await tempFile.writeAsBytes(bytes);
        return tempPath;
      }

      final http.Response response =
          await http.get(Uri.parse(message.data['body'].toString()));
      BigPictureStyleInformation bigPictureStyleInformation =
          BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(
            base64Encode(response.bodyBytes)),
      );

      flutterLocalNotificationsPlugin.show(
        message.data.hashCode,
        message.data['title'].toString(),
        "Yuuhu New Image",
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: channel.description,
              styleInformation: bigPictureStyleInformation,
              setAsGroupSummary: false,
              icon: "@drawable/ic_stat_pm"),
        ),
        payload: message.data['title'].toString(),
      );
    }

    if (message.data['type'].toString() == "text") {
      flutterLocalNotificationsPlugin.show(
          message.data.hashCode,
          message.data['title'].toString(),
          message.data['body'].toString(),
          payload: message.data['title'].toString(),
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                setAsGroupSummary: false,
                icon: "@drawable/ic_stat_pm"),
          ));
    }

    if (message.data['type'].toString() == "audio") {
      flutterLocalNotificationsPlugin.show(
          message.data.hashCode,
          message.data['title'].toString(),
          "Yeahh New Audio",
          payload: message.data['title'].toString(),
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                setAsGroupSummary: false,
                icon: "@drawable/ic_stat_pm"),
          ));
    }
  });

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark));

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    await Permission.notification.request();
  }

  runApp(MyApp());
}


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'].toString() == "image") {
    Future<String> getImageFilePath(String assetPath) async {
      // Load the image from the asset
      ByteData data = await rootBundle.load(assetPath);
      List<int> bytes = data.buffer.asUint8List();

      // Create a temporary file
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/temp_image.png';
      File tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes);
      return tempPath;
    }

    final http.Response response =
        await http.get(Uri.parse(message.data['body'].toString()));
    BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
    );

    flutterLocalNotificationsPlugin.show(
      message.data.hashCode,
      message.data['title'].toString(),
      "Yuuhu New Image",
      payload: message.data['title'].toString(),
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description,
            styleInformation: bigPictureStyleInformation,
            setAsGroupSummary: false,
            icon: "@drawable/ic_stat_pm"),
      ),
    );
  }

  if (message.data['type'].toString() == "text") {
    flutterLocalNotificationsPlugin.show(
        message.data.hashCode,
        message.data['title'].toString(),
        message.data['body'].toString(),
        payload: message.data['title'].toString(),
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: channel.description,
              setAsGroupSummary: false,
              icon: "@drawable/ic_stat_pm"),
        ));
  }

  if (message.data['type'].toString() == "audio") {
    flutterLocalNotificationsPlugin.show(
        message.data.hashCode,
        message.data['title'].toString(),
        "Yeahh New Audio",
        payload: message.data['title'].toString(),
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: channel.description,
              setAsGroupSummary: false,
              icon: "@drawable/ic_stat_pm"),
        ));
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadinPage(),
      navigatorKey: navigatorKey,
      theme: ThemeData(
        focusColor: CustColors.primaryColor,
        primaryColor: CustColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: CustColors.primaryColor),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
