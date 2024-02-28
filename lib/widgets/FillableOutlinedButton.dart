import 'package:flutter/material.dart';


class FillableOutlinedButton extends StatefulWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const FillableOutlinedButton({
    Key? key,
    required this.text,
    required this.isActive,
    required this.onPressed,
  }) : super(key: key);

  @override
  _FillableOutlinedButtonState createState() => _FillableOutlinedButtonState();
}

class _FillableOutlinedButtonState extends State<FillableOutlinedButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: widget.isActive ? Colors.transparent : Colors.cyan,
            width: 2.0,
          ),
          color: widget.isActive ? Colors.cyan : Colors.transparent,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.isActive ? Colors.white : Colors.cyan,
            fontWeight: FontWeight.bold,
            fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
          ),
        ),
      ),
    );
  }

  String _getCurrentLang() {
    return Localizations.localeOf(context).languageCode;
  }
}


// class FillableOutlinedButton extends StatefulWidget {
//   final String text;
//   final VoidCallback onPressed;
//
//   const FillableOutlinedButton({
//     Key? key,
//     required this.text,
//     required this.onPressed,
//   }) : super(key: key);
//
//   @override
//   _FillableOutlinedButtonState createState() => _FillableOutlinedButtonState();
// }
//
// class _FillableOutlinedButtonState extends State<FillableOutlinedButton> {
//   bool _isPressed = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: widget.onPressed,
//       onTapDown: (_) {
//         setState(() {
//           _isPressed = true;
//         });
//       },
//       onTapUp: (_) {
//         setState(() {
//           _isPressed = true;
//         });
//       },
//       onTapCancel: () {
//         setState(() {
//           _isPressed = false;
//         });
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8.0),
//           border: Border.all(
//             color: _isPressed ? Colors.transparent : Colors.purple,
//             width: 2.0,
//           ),
//           color: _isPressed ? Colors.purple : Colors.transparent,
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         child: Text(
//           widget.text,
//           style: TextStyle(
//             color: _isPressed ? Colors.white : Colors.purpleAccent,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }