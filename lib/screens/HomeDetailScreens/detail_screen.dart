import 'package:flutter/material.dart';
import 'package:pyramids_developments/screens/home_page.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:chewie/chewie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../Models/ImagesSlider.dart';
import '../../Models/User.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.title, required this.isBackHome});

  final String title;
  final bool isBackHome;
  static const String routeName = '/detail'; // Define a route name

  @override
  State<DetailPage> createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  String TAG = "DetailPage";
  bool isGettingData = false;
  String userId = "";
  String email = "";
  String role = "";
  bool isLogged = false;

  final List<OneImage> adsList = [];

  final List<OneImage> newsList = [];

  final List<OneImage> mediaList = [];

  Future<void> getAdsNewsMedia() async {
    getUserDataFromPreferences();

    String adsNewsUrl =
        "https://sourcezone2.com/public/00.AccessControl/get_home_page.php";

    setState(() {
      isGettingData = true;
    });

    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      try {
        final response = await http.post(
          Uri.parse(adsNewsUrl),
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
          setState(() {
            isGettingData = false;
          });

          dev.log(TAG, name: "getAdsNews", error: response.body);

          Images imgs = Images.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);
          if (imgs.status == "OK") {
            adsList.clear();
            newsList.clear();
            mediaList.clear();

            for (int i = 0; i < imgs.adsList.length; i++) {
              if (imgs.adsList[i].itemType == "ads") {
                adsList.add(imgs.adsList[i]);
                dev.log(TAG, name: "getAds", error: imgs.adsList[i]);
              }
            }

            for (int i = 0; i < imgs.newsList.length; i++) {
              if (imgs.newsList[i].itemType == "news") {
                newsList.add(imgs.newsList[i]);
                dev.log(TAG, name: "getNews", error: imgs.newsList[i]);
              }
            }

            for (int i = 0; i < imgs.mediaList.length; i++) {
              if (imgs.mediaList[i].itemType == "media") {
                mediaList.add(imgs.mediaList[i]);
                // videoControllers.add(VideoPlayerController.networkUrl(
                //     Uri.parse(imgs.mediaList[i].itemPhotoUrl)));
                dev.log(TAG,
                    name: "getMedia", error: imgs.mediaList[0].itemPhotoUrl);
              }
            }

            // if (imgs.mediaList.isNotEmpty) {
            //   _initializeVideos(mediaList);
            // }
          } else {
            showToast(imgs.info);
          }
        } else {
          dev.log(TAG, error: "API sent Error: $response");
          showToast(
              Images.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
                  .info);

          setState(() {
            isGettingData = false;
          });
        }
      } catch (e) {
        dev.log(TAG, error: "ExceptionError : $e");
        showToast(getTranslated(context, "somethingWrong")!);
        setState(() {
          isGettingData = false;
        });
      }
    } else {
      showToast(getTranslated(context, "noInternetConnection")!);
      setState(() {
        isGettingData = false;
      });
      return;
    }
  }

  // void _initializeVideos(theMediaList) {
  //   videoControllers.clear();
  //   for(int i=0; i < theMediaList.length; i++){
  //     videoControllers.add(VideoPlayerController.networkUrl(
  //         Uri.parse(theMediaList[i].itemPhotoUrl)));
  //   }
  //   chewieControllers.clear();
  //   // Initialize chewie controllers
  //   chewieControllers = videoControllers
  //       .map((controller) => ChewieController(
  //             videoPlayerController: controller,
  //             aspectRatio: 16 / 9,
  //             autoInitialize: true,
  //             looping: false,
  //             autoPlay: false,
  //           ))
  //       .toList();
  // }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_sharp),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 20.0,
            fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          // Add background image here
          // image: DecorationImage(
          //   image: AssetImage('assets/splash/white_bg.png'),
          //   // Replace with your image asset
          //   fit: BoxFit.cover,
          // ),
        ),
        child: buildListViewByType(),
      ),
    );
  }

  Widget buildListViewByType() {
    if (widget.title == getTranslated(context, "news")) {
      return isGettingData
          ? Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 4.0,
              ),
            )
          : ListView(
              children: [
                Container(
                  //News list view
                  margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                  // Make height fill the remaining
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showNewsBottomSheet(
                              context,
                              newsList[index].itemPhotoUrl,
                              newsList[index].itemTitle,
                              newsList[index].itemDescription);
                        },
                        child: Card(
                          margin: EdgeInsets.only(bottom: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15.0), // Adjust the radius as needed
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image on the left
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Container(
                                  width: 100.0, // Adjust the width as needed
                                  height: 100.0, // Adjust the height as needed
                                  child: Image.network(
                                    newsList[index].itemPhotoUrl,
                                    colorBlendMode: BlendMode.darken,
                                    fit: BoxFit.fill,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.black),
                                            strokeWidth: 2.0,
                                          ),
                                        );
                                      }
                                    },
                                    errorBuilder: (BuildContext context,
                                        Object error, StackTrace? stackTrace) {
                                      return Image.asset(
                                        'assets/images/skycitylogo.png',
                                        fit: BoxFit.fill,
                                        height: 100.0,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Title and Description on the right
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        newsList[index].itemTitle,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          // Make font bold
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: _getCurrentLang() == 'ar'
                                              ? 'arFont'
                                              : 'enBold',
                                        ),
                                      ),
                                      Text(
                                        // Description limited text ellipsized
                                        newsList[index].itemDescription,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: Colors.black,
                                          fontFamily: _getCurrentLang() == 'ar'
                                              ? 'arFont'
                                              : 'enBold',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
    } else if (widget.title == "Announcements") {
      return isGettingData
          ? Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 4.0,
              ),
            )
          : ListView(
              children: [
                Container(
                  //News list view
                  margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                  // Make height fill the remaining
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: adsList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showAdBottomSheet(
                              context, adsList[index].itemPhotoUrl);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Container(
                              height: MediaQuery.of(context).size.width * 0.6,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                              ),
                              child: Image.network(
                                colorBlendMode: BlendMode.darken,
                                adsList[index].itemPhotoUrl,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.black,
                                        ),
                                        strokeWidth: 2.0,
                                      ),
                                    );
                                  }
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return Image.asset(
                                    'assets/images/skycitylogo.png',
                                    fit: BoxFit.fill,
                                    height: 100.0,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
    }
    // else if (widget.title == "Media") {
    //   return isGettingData
    //       ? Align(
    //           alignment: Alignment.center,
    //           child: CircularProgressIndicator(
    //             valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
    //             strokeWidth: 4.0,
    //           ),
    //         )
    //       : ListView(
    //           children: [
    //             ListView.builder(
    //               itemCount: mediaList.length,
    //               itemBuilder: (context, index) {
    //                 return VideoListWidget(medList: mediaList, index: index,);
    //               },
    //             )
    //           ],
    //         );
    // }
    return Container();
  }

  void _showNewsBottomSheet(
      BuildContext context, newsUrl, newsTitle, newsDescription) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                      child: Image.network(
                        newsUrl,
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
                                  Colors.black,
                                ),
                                strokeWidth: 2.0,
                              ),
                            );
                          }
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/images/skycitylogo.png',
                            fit: BoxFit.fill,
                            height: 100.0,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  newsTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(newsDescription,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontFamily:
                          _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                    )),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAdBottomSheet(BuildContext context, adUrl) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                      child: Image.network(
                        adUrl,
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
                                  Colors.black,
                                ),
                                strokeWidth: 2.0,
                              ),
                            );
                          }
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/images/skycitylogo.png',
                            fit: BoxFit.fill,
                            height: 100.0,
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
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

  String _getCurrentLang() {
    return Localizations.localeOf(context).languageCode;
  }

  @override
  void initState() {
    getAdsNewsMedia();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// class VideoListWidget extends StatefulWidget {
//
//   const VideoListWidget({super.key, required this.medList, required this.index});
//    final int index;
//   final List<OneImage> medList;
//
//   @override
//   VideoListWidgetState createState() => VideoListWidgetState();
// }
//
// class VideoListWidgetState extends State<VideoListWidget> {
//
//   late List<VideoPlayerController> videoControllers;
//   late List<ChewieController> chewieControllers;
//   late VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//
//     videoControllers.clear();
//     for(int i=0; i < widget.medList.length; i++){
//       _controller = VideoPlayerController.networkUrl(Uri.parse(widget.medList[i].itemPhotoUrl));
//
//       _controller.addListener(() {
//         setState(() {});
//       });
//       _controller.setLooping(true);
//       _controller.initialize().then((_) => setState(() {}));
//       _controller.play();
//
//       videoControllers.add(_controller);
//     }
//
//     chewieControllers.clear();
//     // Initialize chewie controllers
//     chewieControllers = videoControllers
//         .map((controller) => ChewieController(
//       videoPlayerController: controller,
//       aspectRatio: 16 / 9,
//       autoInitialize: true,
//       looping: false,
//       autoPlay: false,
//     ))
//         .toList();
//   }
//
//   @override
//   void dispose() {
//     for (var controller in videoControllers) {
//       controller.dispose();
//     }
//     for (var controller in chewieControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
//       height: MediaQuery.of(context).size.height * 0.3,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(15.0),
//         child: Chewie(
//           controller: chewieControllers[widget.index],
//         ),
//       ),
//     );
//   }
// }
