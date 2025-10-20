import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String title;
  final Function onPressed;

  const SecondaryButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextButton(
        onPressed: () {
          onPressed();
        },
        child: Text(title, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
