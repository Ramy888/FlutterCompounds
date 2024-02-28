import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/User.dart';

//projects page
class Projects extends StatefulWidget {
  const Projects({Key? key}) : super(key: key);

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  String TAG = "Projects";
  bool isGettingData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 65),
        height: MediaQuery.of(context).size.height,
        // decoration: BoxDecoration(
        //   // Add background image here
        //   image: DecorationImage(
        //     image: AssetImage('assets/splash/white_bg.png'),
        //     // Replace with your image asset
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: Center(
          child: Text(
            getTranslated(context, "projectsSoon")!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
            ),
          ),
        ),
      ),
    );
  }

  String _getCurrentLang() {
    return Localizations.localeOf(context).languageCode;
  }


  // Future<void> getUserDataFromPreferences() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userString = prefs.getString('user_data');
  //   if (userString != null) {
  //     final userJson = jsonDecode(userString);
  //     userId = User.fromMap(userJson).userId;
  //     if (userId.isNotEmpty) {
  //       isLogged = prefs.getBool("isLogin")!;
  //       email = User.fromMap(userJson).email;
  //       role = User.fromMap(userJson).role;
  //     }
  //   }
  // }
}
