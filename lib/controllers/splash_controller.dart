import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class SplashController {
  final BuildContext context;

  SplashController(this.context);

  /// چک کردن اتصال به اینترنت
  Future<bool> isInternetConnected() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        navigateToLoginPage();
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  /// هدایت به صفحه لاگین
  void navigateToLoginPage() {
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
