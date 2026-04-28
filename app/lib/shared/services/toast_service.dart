import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastService {
  static void success(String message) {
    _showToast(message, const Color(0xFF0F9D58));
  }

  static void error(String message) {
    _showToast(message, const Color(0xFFD93025));
  }

  static void warning(String message) {
    _showToast(message, const Color(0xFFF9AB00));
  }

  static void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
