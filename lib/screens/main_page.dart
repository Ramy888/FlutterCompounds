import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:motion_tab_bar_v2/motion-badge.widget.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:pyramids_developments/screens/Feed/FeedList.dart';
import 'package:pyramids_developments/screens/contact_form_page.dart';
import 'package:pyramids_developments/screens/home_page.dart';
import 'package:pyramids_developments/screens/invitations.dart';
import 'package:pyramids_developments/screens/notifications.dart';
import 'package:pyramids_developments/screens/projects_page.dart';
import 'package:pyramids_developments/screens/qrcode_page.dart';
import 'package:pyramids_developments/screens/Serivces/support.dart';
import '../Models/User.dart';
import '../app_theme.dart';
import '../localization/language_constants.dart';
import '../widgets/custom_bottom_bar/bottom_bar_view.dart';
import '../widgets/custom_bottom_bar/tabIcon_data.dart';
import '../widgets/navigation_bar_icons.dart';
import 'account_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:pyramids_developments/widgets/custom_drawer/drawer_user_controller.dart';
import 'package:pyramids_developments/widgets/custom_drawer/home_drawer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;
  static const String routeName = 'main'; // Define a route name

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin {
  String TAG = "HomePage";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _currentIndex;
  MotionTabBarController? _motionTabBarController;
  GlobalKey<DrawerUserControllerState> drawerUserControllerKey = GlobalKey<DrawerUserControllerState>();


  String currentPage = HomePage.routeName;
  String userPhoto = "";
  String userName = "";
  String userMail = "";
  String userPhone = "";
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  AndroidNotificationChannel? channel;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  String currentLang = "";

  late List<Widget> _pages;

  Widget? screenView;
  DrawerIndex? drawerIndex;

  AnimationController? animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(
    color: AppTheme.background,
  );


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
      body: DrawerUserController(
        key: drawerUserControllerKey,
        screenIndex: drawerIndex,
        drawerWidth: MediaQuery.of(context).size.width * 0.75,
        onDrawerCall: (DrawerIndex drawerIndexData) {
          changeIndex(drawerIndexData);
          //callback from drawer for replacing screen as user needs with passing DrawerIndex(Enum index)
        },
        screenView: screenView,
      ),

      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController,
        // ADD THIS if you need to change your tab programmatically
        initialSelectedTab: "Home",
        useSafeArea: true,
        // default: true, apply safe area wrapper
        labels: const ["Home", "Social", "Services", "Settings"],
        icons: const [
          Icons.home,
          Icons.sensor_occupied,
          Icons.question_answer_outlined,
          Icons.settings
        ],

        // optional badges, length must be same with labels
        badges: [
          // Default Motion Badge Widget
          null,
          // Default Motion Badge Widget with indicator only
          const MotionBadgeWidget(
            isIndicator: true,
            color: Colors.red, // optional, default to Colors.red
            size: 5, // optional, default to 5,
            show: true, // true / false
          ),

          // const MotionBadgeWidget(
          //   text: '8+',
          //   textColor: Colors.white, // optional, default to Colors.white
          //   color: Colors.red, // optional, default to Colors.red
          //   size: 18, // optional, default to 18
          // ),

          // custom badge Widget
          // Container(
          //   color: Colors.black,
          //   padding: const EdgeInsets.all(2),
          //   child: const Text(
          //     '48',
          //     style: TextStyle(
          //       fontSize: 14,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),

          // allow null
          null,

          null,
        ],
        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        tabIconColor: AppTheme.nearlyBlack,
        tabIconSize: 28.0,
        tabIconSelectedSize: 26.0,
        tabSelectedColor: AppTheme.nearlyDarkBlue,
        tabIconSelectedColor: Colors.white,
        tabBarColor: Colors.white,
        onTabItemSelected: (int value) {
          setState(() {
            // _motionTabBarController!.index = value;
            //closing drawer if open when navigating on tabBar
            if (drawerUserControllerKey.currentState != null) {
              drawerUserControllerKey.currentState!.closeDrawer();
            }
            screenView = _pages[value];
            if (value == 0) {
              // set drawer index to home
              drawerIndex = DrawerIndex.HOME;
            }else{
              // remove selection highlight from drawer items as we are not selecting any of it
              drawerIndex = null;
            }
          });
        },
      ),
    );
  }


  void changeIndex(DrawerIndex drawerIndexdata) {
    // if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          setState(() {
            screenView = const HomePage();
            //set bottomBar index to 0
            if (_motionTabBarController != null) {
              _motionTabBarController!.index = 0;
            }
          });
          break;
        case DrawerIndex.MyQRCode:
          setState(() {
            screenView = QrCodePage(title: "My QR Code");
          });
          break;
        case DrawerIndex.Invites:
          setState(() {
            screenView = InvitaionsPage(title: "Invitations");
          });
          break;
        case DrawerIndex.Profile:
          setState(() {
            screenView = AccountPage(title: "My Account");
          });
          break;
        default:
          setState(() {
            screenView = const HomePage();
            //set bottomBar index to 0
            if (_motionTabBarController != null) {
              _motionTabBarController!.index = 0;
            }
          });
          break;
      // }
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

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {},
          changeIndex: (int index) {
            if (index == 0 || index == 2) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  // tabBody =
                  //     MyDiaryScreen(animationController: animationController);
                  screenView = _pages[index];
                });
              });
            } else if (index == 1 || index == 3) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  // tabBody =
                  //     TrainingScreen(animationController: animationController);
                  screenView = _pages[index];
                });
              });
            }
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    dev.log('initState', name: TAG);
    // initialization();
    drawerIndex = DrawerIndex.HOME;
    screenView = const HomePage();

    // tabIconsList.forEach((TabIconData tab) {
    //   tab.isSelected = false;
    // });
    // tabIconsList[0].isSelected = true;
    //
    // animationController = AnimationController(
    //     duration: const Duration(milliseconds: 600), vsync: this);
    // tabBody = HomePage();

    //// use "MotionTabBarController" to replace with "TabController", if you need to programmatically change the tab
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 4,
      vsync: this,
    );

    super.initState();

    _currentIndex = 0;
    _pages = [
      HomePage(), //0
      FeedScreen(), //1
      Support(title: "Services"), //2
      Projects(), //3
      Support(title: "Support"), //4
      QrCodePage(title: "My Access Code"), //5
      InvitaionsPage(title: "My Invitations"), //6
      AccountPage(title: "My Account"), //7
    ];

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

  @override
  void dispose() {
    // animationController?.dispose();
    _motionTabBarController!.dispose();

    super.dispose();
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
