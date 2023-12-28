import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pyramids_developments/firebase_options.dart';
import 'package:pyramids_developments/login_with_code.dart';
import 'package:pyramids_developments/reset_password.dart';
import 'package:pyramids_developments/screens/InvitationScreens/family_renter_invitation.dart';
import 'package:pyramids_developments/screens/InvitationScreens/gate_permission.dart';
import 'package:pyramids_developments/screens/InvitationScreens/one_time_permission.dart';
import 'package:pyramids_developments/screens/account_page.dart';
import 'package:pyramids_developments/screens/home_page.dart';
import 'package:pyramids_developments/screens/invitations.dart';
import 'package:pyramids_developments/screens/main_page.dart';
import 'package:pyramids_developments/screens/qrcode_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Models/User.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization/language_constants.dart';
import 'localization/demo_localization.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as dev;
import 'package:flutter/services.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void notificationTapBackground(NotificationResponse notificationResponse) {
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

AndroidNotificationChannel? channel;
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late FirebaseMessaging messaging;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  messaging = FirebaseMessaging.instance;

  _prepareForNotification();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', 'US');

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Pyramids Developments",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          secondary: Colors.yellow,
          primary: Colors.black,
          surface: Colors.white,
          background: Colors.white,
          error: Colors.red,
        ),
        useMaterial3: true,
        // textTheme: GoogleFonts.nexaLightTextTheme(
        //   Theme.of(context).textTheme,
        // ),
      ),
      locale: _locale,
      supportedLocales: const [
        Locale("en", "US"),
        Locale("ar", "EG"),
      ],
      localizationsDelegates: const [
        DemoLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode &&
              supportedLocale.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      initialRoute: '/',
      // Define the initial route
      routes: {
        // '/': (context) => const SplashScreen(),
        '/': (context) => SplashScreen(),
        // Login page
        LoginPage.routeName: (context) => const LoginPage(title: "Login"),
        // register page route
        RegisterPage.routeName: (context) =>
            const RegisterPage(title: "Sign Up"),
        // login with code page route
        LoginWithCodePage.routeName: (context) =>
            const LoginWithCodePage(title: "Login With Code"),
        //reset password
        ResetPasswordPage.routeName: (context) =>
            const ResetPasswordPage(title: "Reset Password"),
        // main page route
        MainPage.routeName: (context) =>
            const MainPage(title: "Pyramids Developments"),
        //home page route
        HomePage.routeName: (context) => const HomePage(),
        // QrCode page route
        QrCodePage.routeName: (context) => const QrCodePage(title: "QrCode"),
        //invitations page route
        InvitaionsPage.routeName: (context) =>
            const InvitaionsPage(title: "Invitations"),
        //account page route
        AccountPage.routeName: (context) => const AccountPage(title: "Account"),
        //gate permission page route
        GatePermission.routeName: (context) => GatePermission(),
        //oneTime permission page route
        OneTimePermission.routeName: (context) => OneTimePermission(),
        //famRenter page route
        FamilyRenter.routeName: (context) => FamilyRenter(
              type: "family",
            ),
      },
    );
  }
}

Future<void> _prepareForNotification() async {
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  //If subscribe based sent notification then use this token
  final fcmToken = await messaging.getToken();
  dev.log("theToken??:: ", error: fcmToken);

  //If subscribe based on topic then use this
  await messaging.subscribeToTopic('news');

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = AndroidNotificationChannel(
        'flutter_notification', // id
        'flutter_notification_title', // title
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
        playSound: true);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = DarwinInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    await flutterLocalNotificationsPlugin!.initialize(initSettings,
        onDidReceiveNotificationResponse: notificationTapBackground,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  static const String TAG = "SplashScreen";

  Future<bool> getUserStateFromPreferences() async {
    bool isLogged = false;
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user_data');
    if (userString != null && userString.isNotEmpty) {
      final userJson = jsonDecode(userString);
      String id = User.fromMap(userJson).userId;
      if (id.isNotEmpty) {
        isLogged = prefs.getBool("isLogin")!;
        dev.log(TAG,
            name: "getUserStateFromPreferences", error: isLogged.toString());
        return isLogged;
      }
    }
    return isLogged;
  }

  @override
  Widget build(BuildContext context) {
    // Hide the system overlay elements
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    // Restore the system overlay elements when the widget is disposed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    });
    // Use a Future.delayed to show the splash screen for a certain duration
    Future.delayed(Duration(seconds: 2), () async {
      // Navigate to the main screen after the splash screen
      if (await getUserStateFromPreferences()) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => MainPage(
                    title: 'Pyramids Developments',
                  )),
        );
      } else
        Navigator.of(context).pushReplacement(
          // MaterialPageRoute(builder: (context) => MainPage(title: 'Pyramids Developments',)),
          MaterialPageRoute(builder: (context) => LoginPage(title: "Login")),
        );
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          // This removes the app bar
          elevation: 0,
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    initialization();
    super.initState();
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
}
