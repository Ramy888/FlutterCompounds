import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pyramids_developments/Models/basic_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/User.dart';
import '../localization/language_constants.dart';
import '../widgets/Loading_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;

import '../widgets/ripple_effect.dart';

class ContactFormPage extends StatefulWidget {
  @override
  _ContactFormPageState createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  final _formKey = GlobalKey<FormState>();
  String TAG = "ContactFormPage";
  String name = "";
  String email = "";
  String phone = "";
  String message = "";
  String nameError = "";
  String emailError = "";
  String phoneError = "";
  String messageError = "";
  String userId = "";
  String role = "";
  bool isLogged = false;


  @override
  void dispose() {
    super.dispose();
  }

  Future<void> sendContactFormRequest() async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String getUnitsUrl =
          "https://sourcezone2.com/public/00.AccessControl/create_invitation_family_renter.php";

      LoadingDialog.show(context);

      try {
        final response = await http.post(
          Uri.parse(getUnitsUrl),
          headers: <String, String>{
            // 'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: <String, String>{
            'userId': userId,
            'role': role,
            'language': _getCurrentLang(),
            'name': name,
            'phoneNumber': phone,
            'email': email,
            'message': message,
          },
        );

        if (response.statusCode == 200) {
          dev.log(TAG, name: "sendContactFormRequest: ", error: response.body);

          BasicModel gateResponse = BasicModel.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);

          if (gateResponse.status == "OK") {
            LoadingDialog.hide(context);
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(getTranslated(context, "success")!,
                        style:  TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontFamily: _getCurrentLang() == "ar"
                                ? 'arFont'
                                : 'enBold',
                            fontWeight: FontWeight.bold)),
                    content: Text(gateResponse.info, style:  TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: _getCurrentLang() == "ar"
                            ? 'arFont'
                            : 'enBold',
                        fontWeight: FontWeight.bold)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();

                          setState(() {
                            message = "";
                          });
                        },
                        child: Text(getTranslated(context, "ok")!,
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontFamily: _getCurrentLang() == "ar"
                                ? 'arFont'
                                : 'enBold',
                            fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                });
            //showToast(gateResponse.info);
          } else {
            dev.log(TAG,
                error: "sendContactFormRequest API statusError: $response");

            showToast(gateResponse.info);
            LoadingDialog.hide(context);
          }
        } else {
          dev.log(TAG,
              error: "sendContactFormRequest API request Error: $response");
          LoadingDialog.hide(context);
          showToast(BasicModel.fromJson(
                  jsonDecode(response.body) as Map<String, dynamic>)
              .info);
        }
      } catch (e) {
        dev.log(TAG, error: "sendContactFormRequest ExceptionError : $e");
        LoadingDialog.hide(context);
        showToast(getTranslated(context, "somethingWrong")!);
      }
    } else {
      //no internet connection
      LoadingDialog.hide(context);
      showToast(getTranslated(context, "noInternetConnection")!);
    }
  }

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey[200],
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: getTranslated(context, "fullName"),
                        hintText: getTranslated(context, "enterFullName"),
                        labelStyle:  TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontFamily: _getCurrentLang() == "ar"
                              ? 'arFont'
                              : 'enBold',
                        ),
                        hintStyle:
                             TextStyle(color: Colors.grey, fontSize: 13.0, fontFamily: _getCurrentLang() == "ar"
                              ? 'arFont'
                              : 'enBold',),
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
                        if (value.isEmpty) {
                          // Input field to show error
                          setState(() {
                            nameError =
                                getTranslated(context, "notValidName")!; // Customize the error message
                          });
                        } else {
                          setState(() {
                            nameError = "";
                            name = value;
                          });
                        }
                      },
                    ),
                  ),
                  Text(
                    nameError,
                    style:  TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                      fontFamily: _getCurrentLang() == "ar"
                          ? 'arFont'
                          : 'enBold',
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey[200],
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: getTranslated(context, "email"),
                        hintText: getTranslated(context, "enterEmail"),
                        labelStyle:  TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontFamily: _getCurrentLang() == "ar"
                              ? 'arFont'
                              : 'enBold',
                        ),
                        hintStyle:
                             TextStyle(color: Colors.grey, fontSize: 13.0,
                             fontFamily: _getCurrentLang() == "ar"
                              ? 'arFont'
                              : 'enBold',
                             ),
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
                        if (value.isEmpty) {
                          // Input field to show error
                          setState(() {
                            emailError =
                                getTranslated(context, "notValidEmail")!; // Customize the error message
                          });
                        } else {
                          setState(() {
                            emailError = "";
                            email = value;
                          });
                        }
                      },
                    ),
                  ),
                  Text(
                    emailError,
                    style:  TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                      fontFamily: _getCurrentLang() == "ar"
                          ? 'arFont'
                          : 'enBold',
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey[200],
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: getTranslated(context, "phoneNumber"),
                        hintText: getTranslated(context, "enterPhoneNumber"),
                        labelStyle:  TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontFamily: _getCurrentLang() == "ar"
                              ? 'arFont'
                              : 'enBold',
                        ),
                        hintStyle:
                             TextStyle(color: Colors.grey, fontSize: 13.0,
                             fontFamily: _getCurrentLang() == "ar"
                              ? 'arFont'
                              : 'enBold',
                             ),
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
                        if (value.isEmpty) {
                          // Input field to show error
                          setState(() {
                            phoneError =
                                getTranslated(context, "notValidPhoneNumber")!; // Customize the error message
                          });
                        } else {
                          setState(() {
                            phoneError = "";
                            phone = value;
                          });
                        }
                      },
                    ),
                  ),
                  Text(
                    phoneError,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                      fontFamily: _getCurrentLang() == "ar"
                          ? 'arFont'
                          : 'enBold',
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey[200],
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: getTranslated(context, "message"),
                        hintText: getTranslated(context, "enterMessage"),
                        labelStyle:  TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontFamily: _getCurrentLang() == "ar"
                              ? 'arFont'
                              : 'enBold',
                        ),
                        hintStyle:
                             TextStyle(color: Colors.grey, fontSize: 13.0,
                             fontFamily: _getCurrentLang() == "ar"
                              ? 'arFont'
                              : 'enBold',
                             ),
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
                      maxLines: 6,
                      onChanged: (value) {
                        // Add your onChanged logic here
                        if (value.isEmpty) {
                          // Input field to show error
                          setState(() {
                            messageError =
                                getTranslated(context, "notValidMessage")!; // Customize the error message
                          });
                        } else {
                          setState(() {
                            messageError = "";
                            message = value;
                          });
                        }
                      },
                    ),
                  ),
                  Text(
                    messageError,
                    style:  TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                      fontFamily: _getCurrentLang() == "ar"
                          ? 'arFont'
                          : 'enBold',
                    ),
                  ),
                  SizedBox(height: 16),
                  RippleInkWell(
                    onTap: () {
                      if (name.isEmpty) {
                        setState(() {
                          nameError = getTranslated(context, "notValidName")!;
                        });
                      } else if (email.isEmpty) {
                        setState(() {
                          emailError = getTranslated(context, "notValidEmail")!;
                        });
                      } else if (phone.isEmpty) {
                        setState(() {
                          phoneError = getTranslated(context, "notValidPhoneNumber")!;
                        });
                      } else if (message.isEmpty) {
                        setState(() {
                          messageError = getTranslated(context, "notValidMessage")!;
                        });
                      } else
                        sendContactFormRequest();
                    },
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/button/button_bg.png"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          getTranslated(context, 'submit')!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: _getCurrentLang() == "ar"
                                ? 'arFont'
                                : 'enBold',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  RippleInkWell(
                    onTap: () {},
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/socialIcons/map.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  //add 4 social media circle buttons
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RippleInkWell(
                        onTap: () {
                          // Handle tap action for Twitter image
                        },
                        child: Container(
                          height: 27,
                          width: 27,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                              AssetImage("assets/socialIcons/fb_icon.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      RippleInkWell(
                        onTap: () {
                          // Handle tap action for Twitter image
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage("assets/socialIcons/twitter.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      RippleInkWell(
                        onTap: () {},
                        child: Container(
                          height: 27,
                          width: 27,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/socialIcons/instagram.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      RippleInkWell(
                        onTap: () {},
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage("assets/socialIcons/youtube.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
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

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }

    return input[0].toUpperCase() + input.substring(1);
  }

  String _getCurrentLang() {
    return Localizations.localeOf(context).languageCode;
  }

  Future<void> getUserDataFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user_data');
    if (userString != null) {
      final userJson = jsonDecode(userString);
      userId = User.fromMap(userJson).userId;
      if (userId.isNotEmpty) {
        isLogged = prefs.getBool("isLogin")!;
        email = User.fromMap(userJson).email;
        role = User.fromMap(userJson).role;
      }
    }
  }
}
