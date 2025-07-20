import 'package:flutter/material.dart';

class SnackMessage {
  static void showSnakMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: Duration(seconds: 1)),
    );
  }
}
