import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:chewie/chewie.dart';
import 'package:pyramids_developments/screens/HomeDetailScreens/detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../Models/ImagesSlider.dart';
import '../Models/User.dart';
import '../app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  //final String title;
  // final String currentPage;
  static const String routeName = 'home'; // Define a route name

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String TAG = "HomePage";
  int _currentIndex = 0;
  bool isGettingPhotos = false;
  String userId = "";
  String email = "";
  String role = "";
  bool isLogged = false;

  // late VideoPlayerController _videoPlayerController;
  // late ChewieController _chewieController;
  // String videoUrl = "";

  //fill ads list with dummy data             "https://sourcezone2.com/public/00.AccessControl/ads/ads1.jpg",
  final List<Ads> adsList = [
    Ads(
        itemId: '1',
      itemPhotoUrl: 'https://sourcezone2.com/public/00.AccessControl/videos/ads11.jpg',


    ),
    Ads(
      itemId: '1',
      itemPhotoUrl: 'https://sourcezone2.com/public/00.AccessControl/videos/ads22.jpg',

    ),

  ];

  final List<NewsObject> newsList = [
    NewsObject(
      itemId: '1',
      itemPhotoUrl: 'https://sourcezone2.com/public/00.AccessControl/videos/news11.jpg',
      itemTitle: 'News Title 1',
      itemDescription: 'News Description 1',
      validFrom: '2021-09-01',
      validTo: '2021-09-30',
      itemStatus: 'active',
    ),
    NewsObject(
      itemId: '2',
      itemPhotoUrl: 'https://sourcezone2.com/public/00.AccessControl/videos/news22.jpg',
      itemTitle: 'News Title 2',
      itemDescription: 'News Description 2',
      validFrom: '2021-09-01',
      validTo: '2021-09-30',
      itemStatus: 'active',
    ),
    NewsObject(
      itemId: '3',
      itemPhotoUrl: 'https://sourcezone2.com/public/00.AccessControl/videos/news33.jpg',
      itemTitle: 'News Title 3',
      itemDescription: 'News Description 3',
      validFrom: '2021-09-01',
      validTo: '2021-09-30',
      itemStatus: 'active',
    ),
  ];

  final List<MediaObject> mediaList = [
    MediaObject(
      itemId: '1',
      itemPhotoUrl: 'https://sourcezone2.com/public/00.AccessControl/videos/media11.mp4',
      itemTitle: 'Media Title 1',
      validFrom: '2021-09-01',
      validTo: '2021-09-30',
      itemStatus: 'active',
    ),
    MediaObject(
      itemId: '2',
      itemPhotoUrl: 'https://sourcezone2.com/public/00.AccessControl/videos/media11.mp4',
      itemTitle: 'Media Title 2',
      validFrom: '2021-09-01',
      validTo: '2021-09-30',
      itemStatus: 'active',
    ),
    MediaObject(
      itemId: '3',
      itemPhotoUrl: 'https://sourcezone2.com/public/00.AccessControl/videos/media11.mp4',
      itemTitle: 'Media Title 3',
      validFrom: '2021-09-01',
      validTo: '2021-09-30',
      itemStatus: 'active',
    ),
  ];

  // Future<void> getAdsNews() async {
  //   getUserDataFromPreferences();
  //
  //   String adsNewsUrl =
  //       "https://sourcezone2.com/public/00.AccessControl/get_home_page.php";
  //
  //   setState(() {
  //     isGettingPhotos = true;
  //   });
  //
  //   bool isConnected = await checkInternetConnection();
  //   if (isConnected) {
  //     try {
  //       final response = await http.post(
  //         Uri.parse(adsNewsUrl),
  //         headers: <String, String>{
  //           // 'Content-Type': 'application/json; charset=UTF-8',
  //           'Content-Type': 'application/x-www-form-urlencoded',
  //         },
  //         body: <String, String>{
  //           'userId': userId,
  //           'role': role,
  //           'language': _getCurrentLang(),
  //         },
  //       );
  //
  //       if (response.statusCode == 200) {
  //         setState(() {
  //           isGettingPhotos = false;
  //         });
  //
  //         dev.log(TAG, name: "getAdsNews", error: response.body);
  //
  //         Images imgs = Images.fromJson(
  //             jsonDecode(response.body) as Map<String, dynamic>);
  //         if (imgs.status == "OK") {
  //           adsList.clear();
  //           newsList.clear();
  //           mediaList.clear();
  //
  //           for (int i = 0; i < imgs.adsList.length; i++) {
  //             if (imgs.adsList[i].itemType == "ads") {
  //               adsList.add(imgs.adsList[i]);
  //               dev.log(TAG, name: "getAds", error: imgs.adsList[i]);
  //             }
  //           }
  //
  //           for (int i = 0; i < imgs.newsList.length; i++) {
  //             if (imgs.newsList[i].itemType == "news") {
  //               newsList.add(imgs.newsList[i]);
  //               dev.log(TAG, name: "getNews", error: imgs.newsList[i]);
  //             }
  //           }
  //
  //           for (int i = 0; i < imgs.mediaList.length; i++) {
  //             if (imgs.mediaList[i].itemType == "media") {
  //               mediaList.add(imgs.mediaList[i]);
  //               dev.log(TAG,
  //                   name: "getMedia:// ",
  //                   error: imgs.mediaList[i].itemPhotoUrl);
  //             }
  //           }
  //
  //           // if (imgs.mediaList[0].itemPhotoUrl.isNotEmpty) {
  //           //   //_initializeVideo(imgs.mediaList[0].itemPhotoUrl);
  //           //   videoUrl = imgs.mediaList[0].itemPhotoUrl;
  //           // }
  //         } else {
  //           showToast(imgs.info);
  //         }
  //       } else {
  //         dev.log(TAG, error: "API sent Error: $response");
  //         showToast(
  //             Images.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
  //                 .info);
  //
  //         setState(() {
  //           isGettingPhotos = false;
  //         });
  //       }
  //     } catch (e) {
  //       dev.log(TAG, error: "ExceptionError : $e");
  //       showToast(getTranslated(context, "somethingWrong")!);
  //       setState(() {
  //         isGettingPhotos = false;
  //       });
  //     }
  //   } else {
  //     showToast(getTranslated(context, "noInternetConnection")!);
  //     setState(() {
  //       isGettingPhotos = false;
  //     });
  //     return;
  //   }
  // }

  Future<void> _refreshData() async {
    // Implement your refresh logic here
    await Future.delayed(
        Duration(seconds: 2)); // Simulating a delay for fetching new data
    setState(() {
      // Update the state with new data
    });
  }

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
      body: Container(
        margin: EdgeInsets.only(top: 65),
        height: MediaQuery.of(context).size.height,
        // decoration: BoxDecoration(
        //   // Add background image here
        //   image: DecorationImage(
        //     image: AssetImage('assets/images/home_bg.png'),
        //     // Replace with your image asset
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: isGettingPhotos
            ? Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
                  strokeWidth: 4.0,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Wrap(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 200.0,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              aspectRatio: 16 / 9,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                            ),
                            items: adsList.take(2).map((item) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Handle item click here
                                      _showAdBottomSheet(
                                          context, item.itemPhotoUrl);
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                          ),
                                          child: Image.network(
                                            colorBlendMode: BlendMode.darken,
                                            item.itemPhotoUrl,
                                            fit: BoxFit.fill,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              } else {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.black,
                                                    ),
                                                    strokeWidth: 2.0,
                                                  ),
                                                );
                                              }
                                            },
                                            errorBuilder: (BuildContext context,
                                                Object error,
                                                StackTrace? stackTrace) {
                                              return Image.asset(
                                                'assets/splash/newLogo.png',
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
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: adsList.take(2).map((url) {
                        int index = adsList.indexOf(url);
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index
                                ? AppTheme.nearlyDarkBlue
                                : Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 15.0),
                                child: Text(
                                  getTranslated(context, "news")!,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontStyle: FontStyle.normal,
                                    color: AppTheme.chipBackground,
                                    fontFamily: _getCurrentLang() == "ar"
                                        ? 'arFont'
                                        : 'enBold',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          newsList.length == 0
                              ? Center(
                                  child: Text(
                                    getTranslated(context, "noNews")!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontFamily: _getCurrentLang() == "ar"
                                          ? 'arFont'
                                          : 'enBold',
                                    ),
                                  ),
                                )
                              : Container(
                            margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                            height: 170, // Adjust based on your layout
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                newsList.length > 3 ? 3 : newsList.length,
                                    (index) => GestureDetector(
                                  onTap: () {
                                    _showNewsBottomSheet(
                                      context,
                                      newsList[index].itemPhotoUrl,
                                      newsList[index].itemTitle,
                                      newsList[index].itemDescription,
                                    );
                                  },
                                  child: Container( // Use Container to manage size instead of Expanded
                                    width: MediaQuery.of(context).size.width / 3 - 15, // Adjust the width according to your needs
                                    child: Card(
                                      margin: EdgeInsets.only(bottom: 3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(15.0),
                                            child: Image.network(
                                              newsList[index].itemPhotoUrl,
                                              height: 100, // Adjust as needed
                                              width: 150, // Adjust as needed
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8),
                                            child: Text(
                                              newsList[index].itemTitle,
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //text button at the end of the screen
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailPage(
                                              title:
                                              getTranslated(context, "news")!,
                                              isBackHome: false)));
                                },
                                child: Text(
                                  getTranslated(context, "more")!,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 15.0,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.blue.shade300,
                                    fontFamily: _getCurrentLang() == "ar"
                                        ? 'arFont'
                                        : 'enBold',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15.0),
                      child: Text(
                        getTranslated(context, "media")!,
                        style: TextStyle(
                          // Make text underlined
                          fontSize: 15.0,
                          fontStyle: FontStyle.normal,
                          color: Colors.blue.shade300,
                          fontFamily:
                              _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                        ),
                      ),
                    ),
                    //media slider
                    // VideoListWidget(
                    //   medList: mediaList,
                    // ),
                    VideoWidget(videoData: mediaList[0]),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
      ),
    );
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
                            'assets/splash/newLogo.png',
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
                    fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(newsDescription,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontFamily:
                          _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
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
                            'assets/appicon/appIcon.png',
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
    // getAdsNews();
    super.initState();
  }

  @override
  void dispose() {
    dev.log('home page disposed');
    super.dispose();
  }
}

class VideoWidget extends StatefulWidget {
  final MediaObject videoData;

  const VideoWidget({Key? key, required this.videoData}) : super(key: key);

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.network(widget.videoData.itemPhotoUrl)
          ..initialize().then((_) {
            setState(() {}); // for UI update
          });
  }

  @override
  Widget build(BuildContext context) {
    return _videoController.value.isInitialized
        ? AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                VideoPlayer(_videoController),
                _PlayPauseOverlay(controller: _videoController),
                VideoProgressIndicator(_videoController, allowScrubbing: true),
              ],
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height * 0.3,
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key? key, required this.controller})
      : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}

class Ads {
  final String itemId;
  final String itemPhotoUrl;

  Ads({required this.itemId, required this.itemPhotoUrl});
}

class NewsObject {
  final String itemId;
  final String itemPhotoUrl;
  final String itemTitle;
  final String itemDescription;
  final String validFrom;
  final String validTo;
  final String itemStatus;

  NewsObject(
      {required this.itemId,
      required this.itemPhotoUrl,
      required this.itemTitle,
      required this.itemDescription,
      required this.validFrom,
      required this.validTo,
      required this.itemStatus});
}

class MediaObject {
  final String itemId;
  final String itemPhotoUrl;
  final String itemTitle;
  final String validFrom;
  final String validTo;
  final String itemStatus;

  MediaObject(
      {required this.itemId,
      required this.itemPhotoUrl,
      required this.itemTitle,
      required this.validFrom,
      required this.validTo,
      required this.itemStatus});
}
