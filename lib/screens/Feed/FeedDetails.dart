import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pyramids_developments/app_theme.dart';
import 'package:pyramids_developments/widgets/ripple_effect.dart';

class FeedDetails extends StatefulWidget {
  FeedDetails({required this.itemId});

  //receive item id from the previous screen
  final String itemId;

  @override
  _FeedDetailsState createState() => _FeedDetailsState();
}

class _FeedDetailsState extends State<FeedDetails>
    with TickerProviderStateMixin {
  final double infoHeight = 364.0;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;
  bool isLiked = false;
  double rating = 4.5;

  List<Comment> commentsList = [
    Comment(
        '1',
        'User Name1',
        'assets/images/userImage.png',
        'Lorem ipsum is simply dummy text of printing & typesetting industry, Lorem ipsum is simply dummy text of printing & typesetting industry.',
        '2021-09-01 12:00:00'),
    Comment(
        '2',
        'User Name2',
        'assets/images/userImage.png',
        'Lorem ipsum is simply dummy text of printing & typesetting industry, Lorem ipsum is simply dummy text of printing & typesetting industry.',
        '2021-09-01 12:00:00'),
    Comment(
        '3',
        'User Name3',
        'assets/images/userImage.png',
        'Lorem ipsum is simply dummy text of printing & typesetting industry, Lorem ipsum is simply dummy text of printing & typesetting industry.',
        '2021-09-01 12:00:00'),
  ];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn)));
    setData();
    super.initState();
  }

  Future<void> setData() async {
    animationController?.forward();
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity1 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity2 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity3 = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.2) +
        24.0;
    return Container(
      color: AppTheme.nearlyWhite,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.asset('assets/design_course/webInterFace.png'),
                  ),
                ],
              ),
              Positioned(
                top: (MediaQuery.of(context).size.width / 1.2) - 24.0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.nearlyWhite,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32.0),
                        topRight: Radius.circular(32.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: AppTheme.grey.withOpacity(0.2),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 32.0, left: 18, right: 16),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    AssetImage('assets/images/userImage.png'),
                              ),
                              SizedBox(width: 16),
                              Text('User Name',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.nearlyBlue)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Lorem ipsum is simply dummy text of printing & typesetting industry, Lorem ipsum is simply dummy text of printing & typesetting industry.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontWeight: FontWeight.w200,
                              fontSize: 14,
                              letterSpacing: 0.27,
                              color: AppTheme.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              RippleInkWell(
                                onTap: () {
                                  // show dialog to rate
                                  rateDialog(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  padding: EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        rating.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w200,
                                            fontFamily:
                                                _getCurrentLang() == 'ar'
                                                    ? 'arFont'
                                                    : 'enBold',
                                            fontSize: 15,
                                            letterSpacing: 0.27,
                                            color: Colors.black),
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: AppTheme.nearlyBlue,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              RippleInkWell(
                                onTap: () {
                                  // show dialog to add comment
                                  addCommentDialog(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  padding: EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Comment',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: _getCurrentLang() == 'ar'
                                          ? 'arFont'
                                          : 'enBold',
                                      fontSize: 15,
                                      letterSpacing: 0.27,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Other content goes here
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: opacity1,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 8, bottom: 20),
                            child: Container(
                              height: MediaQuery.of(context).size.width / 1.2,
                              child: ListView.builder(
                                itemCount: commentsList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  // Access the current item
                                  Comment comment = commentsList[index];
                                  // Use your custom widget to display each item
                                  return getCommentBoxUI(comment, context);
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: (MediaQuery.of(context).size.width / 1.2) - 24.0 - 35,
                right: 35,
                child: ScaleTransition(
                  alignment: Alignment.center,
                  scale: CurvedAnimation(
                      parent: animationController!,
                      curve: Curves.fastOutSlowIn),
                  child: Card(
                    color: AppTheme.nearlyBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0)),
                    elevation: 10.0,
                    child: RippleInkWell(
                      onTap: () {
                        // save like and change the icon
                        setState(() {
                          isLiked = !isLiked;
                        });
                      },
                      child: isLiked
                          ? Container(
                              width: 60,
                              height: 60,
                              child: Center(
                                child: Icon(
                                  Icons.thumb_up,
                                  color: AppTheme.nearlyWhite,
                                  size: 30,
                                ),
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              child: Center(
                                child: Icon(
                                  Icons.thumb_up_alt_outlined,
                                  color: AppTheme.nearlyWhite,
                                  size: 30,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 16,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppTheme.nearlyBlack,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget getCommentBoxUI(Comment comment, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: AppTheme.nearlyWhite,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppTheme.grey.withOpacity(0.2),
              offset: const Offset(1.1, 1.1),
              blurRadius: 8.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(comment.commentatorPhoto),
                    radius: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    comment.commentatorName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.27,
                      color: AppTheme.nearlyBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                comment.comment,
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: AppTheme.grey,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  comment.commentDateTime,
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 12,
                    letterSpacing: 0.27,
                    color: AppTheme.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextFormField(
            decoration: InputDecoration(
              labelText: 'Comment',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 5,

          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                // add comment
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void rateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate'),
          content: RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: AppTheme.nearlyBlue,
            ),
            onRatingUpdate: (rating) {
              this.rating = rating;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Rate'),
              onPressed: () {
                // rate
                setState(() {
                  rating = rating;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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

class Comment {
  final String commentatorId;
  final String commentatorName;
  final String commentatorPhoto;
  final String comment;
  final String commentDateTime;

  Comment(this.commentatorId, this.commentatorName, this.commentatorPhoto,
      this.comment, this.commentDateTime);
}
