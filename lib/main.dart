import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:primesse_app/firebase_options.dart';
import 'package:primesse_app/screens/homePage.dart';
import 'package:primesse_app/utils/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        focusColor: CustColors.primaryColor,
        primaryColor: CustColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: CustColors.primaryColor),
        // useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
