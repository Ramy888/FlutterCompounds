import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pyramids_developments/Models/User.dart';
import 'package:pyramids_developments/login_with_code.dart';
import 'package:pyramids_developments/reset_password.dart';
import 'package:pyramids_developments/screens/main_page.dart';
import 'package:pyramids_developments/widgets/ripple_effect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:developer' as dev;
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:pyramids_developments/language.dart';

import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;
  static const String routeName = '/login'; // Define a route name

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String TAG = "LoginPage";
  String currentLang = "en";
  String usernameError = ''; // Initialize the error message as empty
  String passError = '';
  bool isLoading = false;
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _userNamecontroller = TextEditingController();

  String url = "https://sourcezone2.com/public/00.AccessControl/login.php";

  Future<void> login(String phone, pass) async {
    bool isConnected = await checkInternetConnection();

    if (isConnected) {
      setState(() {
        isLoading = true;
      });

      String device_id = await getTokenFromPrefs();

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            // 'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: (<String, String>{
            'email': phone,
            'password': pass,
            'deviceId': device_id,
            'language': currentLang,
          }),
        );

        dev.log(TAG, name: "acceptedData// ", error: "$phone, $pass, $device_id, $currentLang");

        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
          });

          dev.log(TAG, name: "loginRequest", error: response.body);
          var theUser =
              User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
          if (theUser.status == "OK") {
            saveUserInPreferences(theUser);

          } else {
            dev.log(TAG, error: "login API status Error: " + response.body);
            showToast(theUser.info);
          }
        } else {
          dev.log(TAG, error: "login API request Error: $response");
          showToast(
              User.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
                  .info);

          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        dev.log(TAG, error: "loginExceptionError : $e");
        showToast(getTranslated(context, "somethingWrong")!);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      //no internet connection
      setState(() {
        isLoading = false;
      });
      showToast(getTranslated(context, "noInternetConnection")!);
    }
  }

  Future<void> saveUserInPreferences(User user) async {
    dev.log(TAG, name: "saveUserInPreferences::// ", error: user.toString());
    final prefs = await SharedPreferences.getInstance();
    final userJson = user.toJson(); // Convert the User object to a JSON map
    final userString = jsonEncode(userJson); // Convert the JSON map to a string
    await prefs.setString('user_data', userString);
    // await prefs.setString('userId', user.userId);
    // await prefs.setString('first_name', user.first_name);
    // await prefs.setString('last_name', user.last_name);
    // await prefs.setString('phoneNumber', user.phoneNumber);
    // await prefs.setString('email', user.email);
    // await prefs.setString('userPhoto', user.userPhoto);
    // await prefs.setString('role', user.role);
    await prefs.setBool('isLogin', true);

    dev.log(TAG, name: "saveUserInPreferencesPrefs:: ", error: userString);
    // Navigator.pushNamed(context, MainPage.routeName);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MainPage(title: "Pyramids Developments")));
  }

  Future<bool> getUserStateFromPreferences() async {
    bool isLogged = false;
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user_data');
    if (userString != null) {
      final userJson = jsonDecode(userString);
      String id = User.fromMap(userJson).userId;
      if (id.isNotEmpty) {
        isLogged = prefs.getBool("isLogin")!;
        dev.log(TAG, name: "getUserStateFromPreferences", error: isLogged.toString());
        return isLogged;
      }
    }
    return isLogged;
  }

  Future<String> getTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('deviceId');
    return token ?? '';
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      // Toast duration (SHORT or LONG)
      gravity: ToastGravity.BOTTOM,
      // Toast gravity (TOP, CENTER, or BOTTOM)
      timeInSecForIosWeb: 1,
      // Duration in seconds for iOS and web
      backgroundColor: Colors.black,
      // Background color
      textColor: Colors.white,
      // Text color
      fontSize: 16.0, // Text font size
    );
  }

  // Perform your login logic (HTTP request, etc.)
  // Future.delayed(const Duration(seconds: 2), () {
  //   // After the login logic is complete, stop showing the activity indicator
  //   setState(() {
  //     isLoading = false;
  //   });
  //
  //   // You can navigate to another screen or perform other actions here
  // });

  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
    currentLang = language.languageCode;
  }

  @override
  Widget build(BuildContext context) {
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
        decoration: BoxDecoration(
          // Add background image here
          image: DecorationImage(
            image: AssetImage('assets/splash/white_bg.png'),
            // Replace with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  margin: const EdgeInsets.only(bottom: 30.0, top: 80),
                  child: Image.asset(
                    'assets/images/login_icon.png',
                    width: 150,
                    height: 150,
                  ),
                ),

                // Username Field
                Container(
                  height: 53.0, // Adjust the height as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey[200],
                  ),
                  child: TextFormField(
                    controller: _userNamecontroller,
                    decoration: InputDecoration(
                      labelText: getTranslated(context, "username")!,
                      hintText: getTranslated(context, 'enterPhone')!,
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.0,
                          fontFamily:
                              _getCurrentLang() == 'ar' ? 'arFont' : 'enBold'),
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontFamily:
                              _getCurrentLang() == 'ar' ? 'arFont' : 'enBold'),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    onChanged: (value) {
                      // Add your onChanged logic here
                      if (value.isEmpty || !isValidPhoneNumber(value)) {
                        // Input field to show error
                        setState(() {
                          usernameError = getTranslated(context,
                              "usernameNotValid")!; // Customize the error message
                        });
                      } else {
                        setState(() {
                          usernameError = "";
                        });
                      }
                    },
                  ),
                ),

                // Display the error message
                Text(
                  usernameError,
                  style: TextStyle(
                    fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                // Password Field
                Container(
                  height: 53.0, // Adjust the height as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey[200],
                  ),

                  child: TextFormField(
                    controller: _passController,
                    decoration: InputDecoration(
                      labelText: getTranslated(context, "password")!,
                      hintText: getTranslated(context, "enterPassword")!,
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontFamily:
                              _getCurrentLang() == 'ar' ? 'arFont' : 'enBold'),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.0,
                          fontFamily:
                              _getCurrentLang() == 'ar' ? 'arFont' : 'enBold'),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    obscureText: true, // Passwords should be hidden
                    onChanged: (value) {
                      // Add your onChanged logic here
                      if (value.isEmpty) {
                        // Input field to show error
                        setState(() {
                          passError = getTranslated(context,
                              "passwordNotValid")!; // Customize the error message
                        });
                      } else {
                        setState(() {
                          passError = "";
                        });
                      }
                    },
                  ),
                ),

                // Display the error message
                Text(
                  passError,
                  style: TextStyle(
                    fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                Container(
                  margin:
                      const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                  child: Row(
                    children: [
                      // TextButton on the left
                      TextButton(
                        onPressed: () {
                          // Add logic to handle login with code
                          Navigator.pushNamed(
                              context, LoginWithCodePage.routeName);
                        },
                        child: Row(
                          children: [
                            Text(
                              getTranslated(context, "loginWord")! + " ",
                              style: TextStyle(
                                fontFamily: _getCurrentLang() == 'ar'
                                    ? 'arFont'
                                    : 'enBold',
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              getTranslated(context, "withCodeWord")!,
                              style: TextStyle(
                                fontFamily: _getCurrentLang() == 'ar'
                                    ? 'arFont'
                                    : 'enBold',
                                fontSize: 14,
                                color: Colors.purple,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Spacer to push the second TextButton to the right
                      const Spacer(),
                      // TextButton on the right
                      TextButton(
                        onPressed: () {
                          // Add logic to handle Login with Code
                          Navigator.pushNamed(
                              context, ResetPasswordPage.routeName);
                        },
                        child: Text(
                          getTranslated(context, "forgotPass")!,
                          style: TextStyle(
                            fontFamily:
                                _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Login Button
                isLoading
                    ? Container(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator())
                    : RippleInkWell(
                        onTap: () {
                          if (_userNamecontroller.text.isEmpty ||
                              !isValidPhoneNumber(_userNamecontroller.text)) {
                            showToast(
                                getTranslated(context, "notValidUsername")!);
                          } else if (_passController.text.isEmpty ||
                              !isValidPassword(_passController.text)) {
                            showToast(
                                getTranslated(context, "notValidPassword")!);
                          } else {
                            login(
                                _userNamecontroller.text, _passController.text);
                          }
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 1.3,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/button/button_bg.png"),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'login')!,
                              style: TextStyle(
                                fontFamily: _getCurrentLang() == 'ar'
                                    ? 'arFont'
                                    : 'enBold',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),

                // Register
                TextButton(
                  onPressed: () {
                    // Add logic to navigate to the registration page
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getTranslated(context, "register")! + " ",
                        style: TextStyle(
                          fontFamily:
                              _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        getTranslated(context, "registerWord")!,
                        style: TextStyle(
                          fontFamily:
                              _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                          fontSize: 16,
                          color: Colors.purple,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                RippleInkWell(
                  onTap: () {
                    if (_getCurrentLang() == 'ar') {
                      _changeLanguage(
                          Language(1, "assets/images/en.png", "English", "en"));
                    } else {
                      _changeLanguage(
                          Language(2, "assets/images/ar.png", "العربية", "ar"));
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _userNamecontroller.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  void initState() {

    super.initState();
    //initialization();

  }

  // void initialization() async {
  //   // This is where you can initialize the resources needed by your app while
  //   // the splash screen is displayed.  Remove the following example because
  //   // delaying the user experience is a bad design practice!
  //   // ignore_for_file: avoid_print
  //   print('ready in 3...');
  //   await Future.delayed(const Duration(seconds: 1));
  //   print('ready in 2...');
  //   await Future.delayed(const Duration(seconds: 1));
  //   print('ready in 1...');
  //   await Future.delayed(const Duration(seconds: 1));
  //   print('go!');
  //   FlutterNativeSplash.remove();
  // }

  //isvalid phonenumber
  bool isValidPhoneNumber(String value) {
    String pattern = r'(^(010|011|012|015)[0-9]{8}$)';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  //isvalid password
  bool isValidPassword(String value) {
    String pattern = r'^.{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  String _getCurrentLang() {
    return Localizations.localeOf(context).languageCode;
  }


}
