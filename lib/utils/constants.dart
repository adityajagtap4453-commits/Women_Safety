import 'package:flutter/material.dart';

const Color primaryColor = Color(0xfffc3b77);
const Color kColorRed = Color(0xFFCC2029);
const Color red = Colors.red;
const Color red300 = Color.fromRGBO(229, 115, 115, 1);
const Color pink50 = Color.fromRGBO(252, 228, 236, 1);
const Color pink200 = Color.fromRGBO(244, 143, 177, 1);
const Color pink400 = Color.fromRGBO(236, 64, 122, 1);
const Color pink150 = Color.fromRGBO(250, 163, 192, 1);
const Color pink = Colors.pink;
const Color white = Colors.white;
const Color black = Colors.black;
const Color blackOpacity = Color.fromRGBO(0, 0, 0, 0.5);
const Color transparent = Colors.transparent;
const Color grey100 = Color.fromRGBO(245, 245, 245, 1);
const Color grey300 = Color.fromRGBO(224, 224, 224, 1);
const Color deepPurple = Colors.deepPurple;
void goToPush(BuildContext context, Widget nextScreen) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => nextScreen));
}

void goToPushReplacement(BuildContext context, Widget nextScreen) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => nextScreen),
  );
}

dialogueBox(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(title: Text(text)),
  );
}

showSnackBar({required BuildContext context, required String msg}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

Widget progressIndicator(BuildContext context) {
  return Center(child: CircularProgressIndicator(color: red, strokeWidth: 7));
}
