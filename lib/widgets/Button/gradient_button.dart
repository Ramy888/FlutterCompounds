import 'package:flutter/material.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton({Key? key, required this.text, required this.onPressed}) : super(key: key);

  @override
  _GradientButtonState createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      // onHover: (hovering) {
      //   setState(() {
      //     isHovering = hovering;
      //   });
      // },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isHovering
                ? [Color(0xFF26a0da), Color(0xFF314755)]
                : [Color(0xFF314755), Color(0xFF26a0da), Color(0xFF314755)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 3, blurRadius: 5, offset: Offset(0, 3))],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          widget.text.toUpperCase(),
          style:  TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily:
            _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getCurrentLang() {
    return Localizations.localeOf(context).languageCode;
  }
}
