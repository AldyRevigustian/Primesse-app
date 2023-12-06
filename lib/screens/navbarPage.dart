import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:primesse_app/screens/galleryPage.dart';
import 'package:primesse_app/screens/homePage.dart';
import 'package:primesse_app/utils/constant.dart';

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[HomePage(), GalleryPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: SafeArea(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: GNav(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Colors.black,
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            duration: Duration(milliseconds: 400),
            tabBackgroundColor: Colors.grey[100]!,
            color: Colors.black,
            tabs: [
              GButton(
                icon: FluentIcons.chat_20_filled,
                iconColor: Colors.grey[600]!,
                iconActiveColor: CustColors.primaryColor,
                textColor: CustColors.primaryColor,
                text: 'Messages',
              ),
              GButton(
                icon: FluentIcons.image_20_filled,
                iconColor: Colors.grey,
                iconActiveColor: CustColors.primaryColor,
                textColor: CustColors.primaryColor,
                text: 'Gallery',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        )),
      ),
    );
  }
}
