import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;

import '../../Models/User.dart';
import '../../widgets/Loading_dialog.dart';

class RequestDetails extends StatefulWidget {
  const RequestDetails({Key? key}) : super(key: key);

  static const routeName = 'support/request-details';

  @override
  _RequestDetailsState createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  static const TAG = "RequestDetails";
  String userId = "";
  bool isLogged = false;
  String email = "";
  String role = "";

  List<Message> messages = [
    Message(text: 'Hello!', isUser: true, time: DateTime.now()),
    Message(text: 'Hi there!', isUser: false, time: DateTime.now()),
    // Add more messages as needed
  ];

  TextEditingController _textEditingController = TextEditingController();

  Future<void> getRequestDetails() async {
    getUserDataFromPreferences();

    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String getUnitsUrl =
          "https://sourcezone2.com/public/00.AccessControl/create_one_time_pass.php";

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

          },
        );

        if (response.statusCode == 200) {
          dev.log(TAG, name: "createGatePermission: ", error: response.body);
          //
          // OneTime gateResponse = OneTime.fromJson(
          //     jsonDecode(response.body) as Map<String, dynamic>);
          //
          // if (gateResponse.status == "OK") {
          //   showToast(gateResponse.info);
          //   LoadingDialog.hide(context);
          //   Navigator.pop(context, true);
          // } else {
          //   dev.log(TAG,
          //       error: "createGatePermission API statusError: $response");
          //
          //   showToast(gateResponse.info);
          //   LoadingDialog.hide(context);
          // }
        } else {
          dev.log(TAG, error: "createGatePermission API sent Error: $response");
          // LoadingDialog.hide(context);
          // showToast(OneTime.fromJson(
          //     jsonDecode(response.body) as Map<String, dynamic>)
          //     .info);
        }
      } catch (e) {
        dev.log(TAG, error: "createGatePermission ExceptionError : $e");
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
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Type: Plumbing',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Description: There is a leak in the kitchen sink that needs to be fixed.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Date: 2023-01-01',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          'Time: 10:00 AM',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                reverse: true,
                // Reverse the list to show recent messages at the bottom
                itemBuilder: (context, index) {
                  Message message = messages[index];
                  return ChatBubble(
                    text: message.text,
                    isUser: message.isUser,
                    time: message.time,
                  );
                },
              ),
            ),
            Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child:TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: getTranslated(context, "typeMessage"),
                        hintStyle: TextStyle(
                          fontSize: 16.0,
                          fontFamily:
                              _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  void sendMessage() {
    String text = _textEditingController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        //delay insertion of message to show typing indicator
        messages.insert(
          0,
          Message(text: text, isUser: true, time: DateTime.now()),
        );
        _textEditingController.clear();
      });
    }

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        messages.insert(
          0,
          Message(text: 'please hold...', isUser: false, time: DateTime.now()),
        );
      });
    });
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
}

class Message {
  final String text;
  final bool isUser;
  final DateTime time;

  Message({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatBubble({
    required this.text,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${time.hour}:${time.minute}',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
