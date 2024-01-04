import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/User.dart';
import '../Models/basic_model.dart';
import 'Loading_dialog.dart';
import 'dart:developer' as dev;

class PasswordDialog extends StatefulWidget {
  @override
  _PasswordDialogState createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String TAG = "PasswordDialog";
  String password = "";
  String confirmPassword = "";
  String passError = "";
  String confirmPassError = "";
  String userId = "";
  String email = "";
  String role = "";
  bool isLogged = false;

  Future<void> changeUserPassword(String pass) async {
    getUserDataFromPreferences();

    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String url =
          "https://sourcezone2.com/public/00.AccessControl/user_change_password.php";

      LoadingDialog.show(context);

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            // 'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: <String, String>{
            'userId': userId,
            'role': role,
            'language': _getCurrentLang(),
            'password': pass,
          },
        );
        dev.log(TAG, name: "changePassword: ", error: response.body);

        if (response.statusCode == 200) {
          BasicModel passResponse = BasicModel.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);

          if (passResponse.status == "OK") {
            showToast(passResponse.info);
            LoadingDialog.hide(context);
            Navigator.of(context).pop();
          } else {
            dev.log(TAG, error: "changePassword API status Error: $response");
            showToast(passResponse.info);
            LoadingDialog.hide(context);
          }
        } else {
          dev.log(TAG, error: "changePassword requestFailed Error: $response");
          LoadingDialog.hide(context);
        }
      } catch (e) {
        dev.log(TAG, error: "changePasswordExceptionError : $e");
        showToast(getTranslated(context, "somethingWrong")!);
        LoadingDialog.hide(context);
      }
    } else {
      showToast(getTranslated(context, "noInternetConnection")!);
      LoadingDialog.hide(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        getTranslated(context, "changePass")!,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: getTranslated(context, "password"),
                hintText: getTranslated(context, "enterNewPassword"),
                labelStyle:  TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                ),
                hintStyle:  TextStyle(color: Colors.grey, fontSize: 13.0,
                  fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              onChanged: (value) {
                // Add your onChanged logic here
                if (value.isEmpty) {
                  // Input field to show error
                  setState(() {
                    passError =
                        getTranslated(context, "passwordNotValid")!; // Customize the error message
                  });
                } else {
                  setState(() {
                    passError = "";
                    password = value;
                  });
                }
              },
            ),
            Text(
              passError,
              style:  TextStyle(
                color: Colors.red,
                fontSize: 12.0,
                fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: getTranslated(context, "confirmPassword"),
                hintText: getTranslated(context, "enterConfirmPassword")!,
                labelStyle:  TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                ),
                hintStyle:  TextStyle(color: Colors.grey, fontSize: 13.0,
                  fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              onChanged: (value) {
                // Add your onChanged logic here
                if (value.isEmpty) {
                  // Input field to show error
                  setState(() {
                    confirmPassError =
                        getTranslated(context, "notValidConfirmPassword")!; // Customize the error message
                  });
                } else {
                  setState(() {
                    confirmPassError = "";
                    confirmPassword = value;
                  });
                }
              },
            ),
            Text(
              confirmPassError,
              style:  TextStyle(
                color: Colors.red,
                fontSize: 12.0,
                fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
              ),
            ),
          ],
        ),
      ),
      actions: [
        InkWell(
          onTap: () {
            // Validate and save logic here
            String password = passwordController.text;
            String confirmPassword = confirmPasswordController.text;

            if (password.isEmpty) {
              setState(() {
                passError = getTranslated(context, "passwordNotValid")!;
              });
            } else if (confirmPassword.isEmpty) {
              setState(() {
                confirmPassError = getTranslated(context, "passwordNotValid")!;
              });
            } else if (password != confirmPassword) {
              setState(() {
                confirmPassError = getTranslated(context, "notValidConfirmPassword")!;
              });
            } else {
              changeUserPassword(password);
            }
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
                getTranslated(context, 'save')!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                ),
              ),
            ),
          ),
        ),
      ],
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
