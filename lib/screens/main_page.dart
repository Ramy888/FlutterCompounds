import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pyramids_developments/screens/contact_form_page.dart';
import 'package:pyramids_developments/screens/home_page.dart';
import 'package:pyramids_developments/screens/invitations.dart';
import 'package:pyramids_developments/screens/notifications.dart';
import 'package:pyramids_developments/screens/projects_page.dart';
import 'package:pyramids_developments/screens/qrcode_page.dart';
import '../Models/User.dart';
import '../localization/language_constants.dart';
import '../widgets/bottom_bar_icon.dart';
import '../widgets/navigation_bar_icons.dart';
import 'account_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as dev;

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;
  static const String routeName = 'main'; // Define a route name

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  String TAG = "HomePage";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  String currentPage = HomePage.routeName;
  String userPhoto = "";
  String userName = "";
  String userMail = "";
  String userPhone = "";
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  AndroidNotificationChannel? channel;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  String currentLang = "";

  final List<Widget> _pages = [
    HomePage(), //0
    Notifications(), //1
    ContactFormPage(), //2
    Projects(), //3
    QrCodePage(title: "My Access Code"), //4
    InvitaionsPage(title: "My Invitations"), //5
    AccountPage(title: "My Account"), //6
  ];

  Future<void> getUserStateFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user_data');
    if (userString != null) {
      final userJson = jsonDecode(userString);
      String id = User.fromMap(userJson).userId;
      if (id.isNotEmpty) {
        userPhoto = User.fromMap(userJson).userPhoto;
        userName = User.fromMap(userJson).first_name +
            " " +
            User.fromMap(userJson).last_name;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          // This removes the app bar
          elevation: 0,
        ),
      ),
      //   flexibleSpace: Container(
      //     margin: EdgeInsets.only(top: 29.5),
      //     height: MediaQuery.of(context).size.height * 0.5,
      //     width: MediaQuery.of(context).size.width,
      //     decoration: BoxDecoration(
      //       image: DecorationImage(
      //         image: AssetImage('assets/images/app_bar.jpg'),
      //         fit: BoxFit.fitWidth,
      //       ),
      //     ),
      //   ),
      //   leading: IconButton(
      //     icon: Image.asset(
      //       'assets/images/menuIcon.png', // Adjust the path accordingly
      //       width: 24, // Set the width as needed
      //       height: 24, // Set the height as needed
      //     ),
      //     onPressed: () {
      //       _scaffoldKey.currentState?.openDrawer();
      //     },
      //   ),
      // ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey[200]
                  // image: DecorationImage(
                  //   image: AssetImage('assets/splash/splash_bg.png'),
                  //   // Replace with the actual path or network URL
                  //   fit: BoxFit.cover,
                  // ),
                  ),
              child: GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState?.closeDrawer();
                  if (currentPage != AccountPage.routeName) {
                    Navigator.pushNamed(context, AccountPage.routeName);
                    setState(() {
                      currentPage = AccountPage.routeName;
                    });
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Container(
                        width: 100.0, // Adjust the width as needed
                        child: Image.network(
                          userPhoto,
                          colorBlendMode: BlendMode.darken,
                          fit: BoxFit.fill,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                  strokeWidth: 2.0,
                                ),
                              );
                            }
                          },
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            return Image.asset(
                              'assets/images/skycitylogo.png',
                              // Replace with your placeholder image asset path
                              fit: BoxFit.fill,
                              height: 100.0, // Adjust the height as needed
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Add some spacing between the avatar and the name
                    Text(
                      userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text(
                  getTranslated(context, 'home')!,
                  style: TextStyle(
                    fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                  )),
              onTap: () {
                _onDrawerItemTap(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.qr_code_2_outlined),
              title: Text(getTranslated(context, "accessCode")!,
                  style: TextStyle(
                    fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                  )),
              onTap: () {
                _onDrawerItemTap(4);
              },
            ),
            ListTile(
              leading: Icon(Icons.insert_invitation),
              title: Text(getTranslated(context, "invitations")!,
                  style: TextStyle(
                    fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                  )),
              onTap: () {
                _onDrawerItemTap(5);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text(getTranslated(context, "account")!,
                  style: TextStyle(
                    fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                  )),
              onTap: () {
                _onDrawerItemTap(6);
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
              // Add background image here
              image: DecorationImage(
                image: AssetImage('assets/images/home_bg.png'),
                // Replace with your image asset
                fit: BoxFit.cover,
              ),
            ),
            height: 60,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                // Background Image
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_getCurrentLang() == 'ar'
                            ? 'assets/images/app_bar.jpg'
                            : 'assets/images/app_bar_en.jpg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                // Custom AppBar
                Directionality(
                  textDirection: _getCurrentLang() == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Positioned(
                    top: 8,
                    child: IconButton(
                      icon: Image.asset(
                        'assets/images/menuIcon.png',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _pages[_currentIndex],
          ),
        ],
      ),

      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bottomBar/footer_bg.png'),
            fit: BoxFit.fill,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: MyNavigationBar(
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  void _onDrawerItemTap(int index) {
    //Navigator.pop(context); // Close the drawer
    _scaffoldKey.currentState?.closeDrawer();
    // Check if the selected screen is already active
    if (_currentIndex != index) {
      // Update the currently active index
      setState(() {
        _currentIndex = index;
      });
    }
  }

  String _getCurrentLang() {
    return Localizations.localeOf(context).languageCode;
  }

  //splash screen
  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    //await Future.delayed(const Duration(seconds: 1));

    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    dev.log('initState', name: TAG);
    // initialization();
    super.initState();

    setupInteractedMessage();

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      RemoteNotification? notification = message?.notification!;

      print(notification != null ? notification.title : '');
    });

    FirebaseMessaging.onMessage.listen((message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && !kIsWeb) {
        String action = jsonEncode(message.data);

        flutterLocalNotificationsPlugin!.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel!.id,
                channel!.name,
                priority: Priority.high,
                importance: Importance.max,
                setAsGroupSummary: true,
                styleInformation: DefaultStyleInformation(true, true),
                largeIcon: DrawableResourceAndroidBitmap('@drawable/beengee'),
                channelShowBadge: true,
                autoCancel: true,
                icon: '@drawable/beengee',
              ),
            ),
            payload: action);
      }
      print('A new event was published!');
    });

    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => _handleMessage(message.data));
  }

  // void _handleMessage(RemoteMessage message) {
  //   if (message.data['type'] == 'user') {
  //
  //     Navigator.pushNamed(context, AccountPage.routeName);
  //   }
  // }
  Future<dynamic> onSelectNotification(payload) async {
    Map<String, dynamic> action = jsonDecode(payload);
    _handleMessage(action);
  }

  Future<void> setupInteractedMessage() async {
    await FirebaseMessaging.instance
        .getInitialMessage()
        .then((value) => _handleMessage(value != null ? value.data : Map()));
  }

  void _handleMessage(Map<String, dynamic> data) {
    if (data['redirect'] == "product") {
      // Navigator.push(
      //     context,
      // MaterialPageRoute(
      //     builder: (context) => ProductPage(message: data['message'])));
      Navigator.pushNamed(context, AccountPage.routeName);
    }
  }
}
