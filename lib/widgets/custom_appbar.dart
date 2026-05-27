import 'package:flutter/material.dart';
import 'package:women_safety_app/utils/quotes.dart';

class CustomAppBar extends StatelessWidget {
  final Function? onTap;
  final int? qouteIndex;
  const CustomAppBar({super.key, this.onTap, this.qouteIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap!(); //parameter from constructor
      },
      child: SizedBox(
        child: Text(
          sweetSayings[qouteIndex!],
          style: TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
