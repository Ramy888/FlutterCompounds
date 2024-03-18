import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:pyramids_developments/widgets/ripple_effect.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/User.dart';
import '../app_theme.dart';
import '../../localization/language_constants.dart';
import '../language.dart';
import '../main.dart';

//projects page
class Projects extends StatefulWidget {
  const Projects({Key? key}) : super(key: key);

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  String TAG = "Projects";
  bool isGettingData = false;
  bool isNews = true;
  bool isMy = false;
  bool isService = true;
  String currentLang = "en";

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
        child: Theme(
          data: AppTheme.buildLightTheme(),
          // add settings customizations notification switch, and other settings
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Notifications Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'News Notifications',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      //switch button
                      Switch(
                        value: isNews,
                        onChanged: (value) {
                          setState(() {
                            isNews = value;
                          });
                        },
                        activeTrackColor: Colors.blue[600],
                        activeColor: AppTheme.darkBlue,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'My Notifications',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        //change switch color when active to blue
                        value: isMy,
                        onChanged: (value) {
                          setState(() {
                            isMy = value;
                          });
                        },
                        activeTrackColor: Colors.blue[600],
                        activeColor: AppTheme.nearlyDarkBlue,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Service Notifications',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: isService,
                        onChanged: (value) {
                          setState(() {
                            isService = value;
                          });
                        },
                        activeTrackColor: Colors.blue[600],
                        activeColor: AppTheme.nearlyDarkBlue,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        getTranslated(context, "change_language")!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RippleInkWell(
                        onTap: () {
                          if (_getCurrentLang() == 'ar') {
                            _changeLanguage(Language(
                                1, "assets/images/en.png", "English", "en"));
                          } else {
                            _changeLanguage(Language(
                                2, "assets/images/ar.png", "العربية", "ar"));
                          }
                        },
                        child: IconButton(
                          onPressed: () {
                            if (_getCurrentLang() == 'ar') {
                              _changeLanguage(Language(
                                  1, "assets/images/en.png", "English", "en"));
                            } else {
                              _changeLanguage(Language(
                                  2, "assets/images/ar.png", "العربية", "ar"));
                            }
                          },
                          icon: Image.asset(
                            _getCurrentLang() == 'ar'
                                ? 'assets/images/en.png'
                                : 'assets/images/ar.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
    currentLang = language.languageCode;
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
