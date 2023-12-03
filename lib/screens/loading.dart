import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:primesse_app/screens/homePage.dart';
import 'package:primesse_app/screens/loginPage.dart';
import 'package:primesse_app/utils/constant.dart';

class LoadinPage extends StatefulWidget {
  const LoadinPage({super.key});

  @override
  State<LoadinPage> createState() => _LoadinPageState();
}

class _LoadinPageState extends State<LoadinPage> {
  Future<void> checkEmailExistence(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    if (FirebaseAuth.instance.currentUser?.email != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Verified')
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();

      await googleSignIn.signOut();
      if (querySnapshot.docs.isEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false);
      }
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  void initState() {
    checkEmailExistence(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/PM.png", width: 150, height: 150),
            SpinKitFadingCircle(
              color: Colors.black.withOpacity(0.2),
              size: 25,
            )
          ],
        ),
      ),
    );
  }
}
