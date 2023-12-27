import 'package:flutter/material.dart';


class RippleInkWell extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  RippleInkWell({required this.onTap, required this.child});

  @override
  _RippleInkWellState createState() => _RippleInkWellState();
}

class _RippleInkWellState extends State<RippleInkWell> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(30), // Adjust the borderRadius as needed
        child: Container(
          padding: EdgeInsets.all(8),
          child: widget.child,
        ),
      ),
    );
  }
}