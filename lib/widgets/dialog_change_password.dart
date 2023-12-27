import 'package:connectivity/connectivity.dart%20%20';
import 'package:flutter/material.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

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


  Future<void> changeUserPassword(String pass) async {
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
            'userId': '29',
            'role': 'owner',
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
      title: Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter New Password',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                ),
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13.0),
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
                    'Must not be Empty'; // Customize the error message
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
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Enter Password again',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                ),
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13.0),
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
                    'Must not be Empty'; // Customize the error message
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
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12.0,
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

            if(password.isEmpty){
              setState(() {
                passError = "Password is empty";
              });
            } else if (confirmPassword.isEmpty) {
              setState(() {
                confirmPassError = "Confirm Password is empty";
              });
            } else if(password != confirmPassword){
              setState(() {
                confirmPassError = "Password and Confirm Password must be same";
              });
            }else{
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
}
