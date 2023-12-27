import 'package:flutter/material.dart';

//projects page
class Projects extends StatefulWidget {
  const Projects({Key? key}) : super(key: key);

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  String TAG = "Projects";
  bool isGettingData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Center(
          child: Text(
            "Projects coming soon",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
