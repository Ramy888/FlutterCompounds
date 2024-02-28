import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pyramids_developments/screens/InvitationScreens/family_renter_invitation.dart';
import 'package:pyramids_developments/screens/InvitationScreens/gate_permission.dart';
import 'package:pyramids_developments/screens/InvitationScreens/one_time_permission.dart';
import 'package:pyramids_developments/widgets/FillableOutlinedButton.dart';
import 'package:share/share.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/User.dart';
import '../Models/invitaion.dart';
import '../Models/invitation_update.dart';
import '../widgets/Loading_dialog.dart';

class InvitaionsPage extends StatefulWidget {
  const InvitaionsPage({super.key, required this.title});

  final String title;
  static const String routeName = 'invitations'; // Define a route name

  @override
  State<InvitaionsPage> createState() => InvitationsPageState();
}

class InvitationsPageState extends State<InvitaionsPage> {
  String TAG = "InvitationsPage";
  String _selectedButton = 'Tenant';
  bool isGettingInvites = false;
  bool updatingPermission = false;
  late List<bool> buttonStates;
  String userId = "";
  String email = "";
  String role = "";
  bool isLogged = false;

  List<OneInvitation> invitationsList = [];

  Future<void> getInvitationsByType(String type) async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String getUnitsUrl =
          "https://sourcezone2.com/public/00.AccessControl/get_invitations_by_type.php";

      setState(() {
        isGettingInvites = true;
      });

      try {
        final response = await http.post(
          Uri.parse(getUnitsUrl),
          headers: <String, String>{
            // 'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: <String, String>{
            'userId': userId,
            'type': type,
            'role': role,
            'language': _getCurrentLang()
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            isGettingInvites = false;
          });

          dev.log(TAG, name: "getInvitations", error: response.body);

          Invitation invitationResponse = Invitation.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);

          if (invitationResponse.status == "OK") {
            invitationsList.clear();
            for (int i = 0; i < invitationResponse.invitationList.length; i++) {
              invitationsList.add(invitationResponse.invitationList[i]);
            }
            dev.log(TAG,
                name: "showInvListSize statusOK:: ", error: response.body);
          } else {
            invitationsList.clear();
            dev.log(TAG,
                name: "showInvListSize:: ", error: invitationsList.length);

            showToast(invitationResponse.info);
          }
        } else {
          dev.log(TAG, error: "API sent Error: $response");
          showToast(Invitation.fromJson(
                  jsonDecode(response.body) as Map<String, dynamic>)
              .info);

          setState(() {
            isGettingInvites = false;
          });
        }
      } catch (e) {
        dev.log(TAG, error: "ExceptionError : $e");
        showToast(getTranslated(context, "somethingWrong")!);
        setState(() {
          isGettingInvites = false;
        });
      }
    } else {
      //no internet connection
      setState(() {
        isGettingInvites = false;
      });
      showToast(getTranslated(context, "noInternetConnection")!);
    }
  }

  Future<void> activateDeactivate(
      OneInvitation oneInvitation, String state) async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String getUnitsUrl =
          "https://sourcezone2.com/public/00.AccessControl/activate_deactivate_permission.php";

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
            'permissionId': oneInvitation.invitationId,
            'new_status': state,
            'language': _getCurrentLang()
          },
        );

        if (response.statusCode == 200) {
          dev.log(TAG, name: "activateDeactivate", error: response.body);

          InvitationUpdate invitationResponse = InvitationUpdate.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);

          if (invitationResponse.status == "OK") {
            LoadingDialog.hide(context);
            showToast(invitationResponse.info);
            setState(() {
              oneInvitation.invitationStatus = state;
            });
          } else {
            LoadingDialog.hide(context);
            showToast(invitationResponse.info);
          }
        } else {
          dev.log(TAG, error: "API sent Error: $response");
          LoadingDialog.hide(context);

          showToast(Invitation.fromJson(
                  jsonDecode(response.body) as Map<String, dynamic>)
              .info);
        }
      } catch (e) {
        dev.log(TAG, error: "activateDeactivate ExceptionError : $e");
        LoadingDialog.hide(context);

        showToast(getTranslated(context, "somethingWrong")!);
      }
    } else {
      //no internet connection
      LoadingDialog.hide(context);
      showToast(getTranslated(context, "noInternetConnection")!);
    }
  }

  Future<void> _refreshData() async {
    // Implement your refresh logic here
    //get current buttonstate value
    int bt_id = buttonStates.indexOf(true);
    if (bt_id == 0)
      _selectedButton = "permission";
    else if (bt_id == 1)
      _selectedButton = "oneTimePass";
    else if (bt_id == 2)
      _selectedButton = "family";
    else if (bt_id == 3) _selectedButton = "renter";
    getInvitationsByType(_selectedButton);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 30.0, // Adjust the bottom position as needed
            right: 5.0,
            width: MediaQuery.of(context).size.width * 0.35,
            child: FloatingActionButton.extended(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 10,
              onPressed: () {
                _showBottomSheet(context);
              },
              label: Text(
                getTranslated(context, "addNew")!,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                ),
              ),
              icon: Icon(Icons.add_business_rounded, color: Colors.white),
              backgroundColor: Colors.cyan,
            ),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 65),
        // decoration: BoxDecoration(
        //   // Add background image here
        //   image: DecorationImage(
        //     image: AssetImage('assets/splash/white_bg.png'),
        //     // Replace with your image asset
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FillableOutlinedButton(
                      text: getTranslated(context, "gate")!,
                      isActive: buttonStates[0],
                      onPressed: () async {
                        _updateButtonState(0);
                      },
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    FillableOutlinedButton(
                      text: getTranslated(context, "oneTime")!,
                      isActive: buttonStates[1],
                      onPressed: () {
                        _updateButtonState(1);
                      },
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    FillableOutlinedButton(
                      text: getTranslated(context, "family")!,
                      isActive: buttonStates[2],
                      onPressed: () {
                        _updateButtonState(2);
                      },
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    FillableOutlinedButton(
                      text: getTranslated(context, "tenant")!,
                      isActive: buttonStates[3],
                      onPressed: () {
                        _updateButtonState(3);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            isGettingInvites
                ? Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      strokeWidth: 4.0,
                    ),
                  )
                : Flexible(
                    child: Container(
                      child: RefreshIndicator(
                        onRefresh: _refreshData,
                        child: invitationsList.length == 0
                            ? Center(
                                child: Text(
                                getTranslated(context, "noInvitations")!,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: _getCurrentLang() == "ar"
                                      ? 'arFont'
                                      : 'enBold',
                                ),
                              ))
                            : ListView.builder(
                                itemCount: invitationsList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        top: 7, left: 15, right: 15),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (invitationsList[index]
                                                .invitationType ==
                                            "permission") {
                                          _showSheetActivateDeactivate(
                                              context, invitationsList[index]);
                                        } else {
                                          if (invitationsList[index]
                                                  .invitationStatus ==
                                              'approved') {
                                            _showShareOptions(context,
                                                invitationsList[index]);
                                          } else
                                            showToast(getTranslated(context,
                                                "invitationsExpired")!);
                                        }
                                      },
                                      child: Card(
                                        child: ListTile(
                                          title: Text(
                                              DateFormat('yyyy-MM-dd').format(
                                                DateTime.parse(
                                                    invitationsList[index]
                                                        .created_at),
                                              ),
                                              style: TextStyle(fontSize: 12)),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 5,
                                              ),
                                              invitationsList[index]
                                                              .guestName !=
                                                          null &&
                                                      invitationsList[index]
                                                          .guestName!
                                                          .isNotEmpty
                                                  ? Center(
                                                      child: Text(
                                                          invitationsList[index]
                                                              .guestName!,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                _getCurrentLang() ==
                                                                        "ar"
                                                                    ? 'arFont'
                                                                    : 'enBold',
                                                          )),
                                                    )
                                                  : Text(
                                                      capitalizeFirstLetter(
                                                          invitationsList[index]
                                                              .invitationType),
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily:
                                                              _getCurrentLang() ==
                                                                      "ar"
                                                                  ? 'arFont'
                                                                  : 'enBold',
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              Center(
                                                child: invitationsList[index]
                                                                .description !=
                                                            null &&
                                                        invitationsList[index]
                                                            .description!
                                                            .isNotEmpty
                                                    ? Text(
                                                        invitationsList[index]
                                                            .description!,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily:
                                                              _getCurrentLang() ==
                                                                      "ar"
                                                                  ? 'arFont'
                                                                  : 'enBold',
                                                        ),
                                                      )
                                                    : Text(
                                                        invitationsList[index]
                                                                .guest_ride ??
                                                            '',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily:
                                                              _getCurrentLang() ==
                                                                      "ar"
                                                                  ? 'arFont'
                                                                  : 'enBold',
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                          trailing: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius: BorderRadius.circular(
                                                  12.0), // Adjust the radius as needed
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 5.0),
                                            // Adjust padding as needed
                                            child: Text(
                                              invitationsList[index]
                                                  .invitationStatus,
                                              style: TextStyle(
                                                fontSize: 13.0,
                                                color: Colors.white,
                                                fontFamily:
                                                    _getCurrentLang() == "ar"
                                                        ? 'arFont'
                                                        : 'enBold',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _updateButtonState(int index) {
    setState(() {
      buttonStates = List.generate(4, (i) => i == index);
    });

    invitationsList.clear();
    if (index == 0) {
      // Gate
      getInvitationsByType("permission");
    } else if (index == 1) {
      // One Time
      getInvitationsByType("oneTimePass");
    } else if (index == 2) {
      // Family
      getInvitationsByType("family");
    } else if (index == 3) {
      // Tenant
      getInvitationsByType("renter");
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.43,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.door_back_door),
                  title: Text(getTranslated(context, "gate")!,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily:
                              _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                          color: Colors.black)),
                  onTap: () async {
                    final newItem = await Navigator.popAndPushNamed(
                        context, GatePermission.routeName);
                    if (newItem == true) {
                      setState(() {
                        _updateButtonState(0);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.qr_code_2_outlined),
                  title: Text(getTranslated(context, "oneTime")!,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily:
                              _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                          color: Colors.black)),
                  onTap: () async {
                    final newItem = await Navigator.popAndPushNamed(
                        context, OneTimePermission.routeName);
                    if (newItem == true) {
                      setState(() {
                        _updateButtonState(1);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.family_restroom_rounded),
                  title: Text(getTranslated(context, "family")!,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily:
                              _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                          color: Colors.black)),
                  onTap: () async {
                    Navigator.pop(context);
                    final newItem = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FamilyRenter(
                            type: getTranslated(context, "family")!,
                          ),
                        ));
                    if (newItem == true) {
                      setState(() {
                        _updateButtonState(2);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.emoji_people),
                  title: Text(getTranslated(context, "tenant")!,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily:
                              _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                          color: Colors.black)),
                  onTap: () async {
                    Navigator.pop(context);
                    final newItem = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FamilyRenter(
                            type: getTranslated(context, "tenant")!,
                          ),
                        ));
                    if (newItem == true) {
                      setState(() {
                        _updateButtonState(3);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShareOptions(BuildContext context, OneInvitation invitation) async {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.2,
          child: Wrap(
            spacing: 50.0,
            children: [
              ListTile(
                leading: Icon(Icons.share),
                title: Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Text(
                      getTranslated(context, "share")!,
                      style: TextStyle(
                        fontFamily:
                            _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                      ),
                    )),
                onTap: () async {
                  // Handle sharing text or base64 image
                  if (invitation.invitationType == 'oneTimePass') {
                    Uint8List bytes = base64Decode(invitation.qrcode!);
                    File tempFile = await _saveBytesToFile(bytes);
                    Share.shareFiles([tempFile.path]);
                  } else if (invitation.invitationType == 'renter' ||
                      invitation.invitationType == 'family') {
                    if (invitation.invitationStatus == 'approved')
                      Share.share(invitation.code!);
                  }

                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File> _saveBytesToFile(Uint8List bytes) async {
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/temp_image.png');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  void _showSheetActivateDeactivate(
      BuildContext context, OneInvitation invitation) {
    String buttonText = getTranslated(context, "activate")!;
    IconData icon = Icons.lock_open_rounded;

    if (invitation.invitationStatus == 'active') {
      buttonText = getTranslated(context, "deactivate")!;
      icon = Icons.lock_outline_rounded;
    } else {
      buttonText = getTranslated(context, "activate")!;
      icon = Icons.lock_open_rounded;
    }

    setState(() {
      updatingPermission = true;
    });

    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.2,
          child: Wrap(
            spacing: 20.0,
            children: [
              ListTile(
                leading: Icon(icon),
                title: Text(buttonText),
                onTap: () {
                  setState(() {
                    updatingPermission = true;
                  });
                  if (invitation.invitationStatus == 'active') {
                    activateDeactivate(invitation, 'expired');
                  } else {
                    activateDeactivate(invitation, 'active');
                  }
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
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

  @override
  void initState() {
    // buttonStates = List.generate(4, (index) => false);
    _updateButtonState(0);
    super.initState();
  }
}
