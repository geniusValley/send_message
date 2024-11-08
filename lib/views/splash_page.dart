import 'package:flutter/material.dart';

import '../controllers/controller.exp.dart';
import 'widgets/animation.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  late SplashController _controller;
  bool _visible = false;
  bool? isInternetAvailable;

  @override
  void initState() {
    super.initState();

    // ایجاد نمونه کنترلر
    _controller = SplashController(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _visible = true;
      });
    });

    checkConnection();
  }

  /// بررسی وضعیت اینترنت و بروزرسانی نمایش
  void checkConnection() async {
    setState(() {
      isInternetAvailable = null;
    });

    final connectionStatus = await _controller.isInternetConnected();
    setState(() {
      isInternetAvailable = connectionStatus;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(connectionStatus ? 'welcome' : 'check internet'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(seconds: 2),
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isInternetAvailable == null)
                SizedBox(
                  width: 200,
                  height: 200,
                  child: LoadingAnimate(),
                )
              else if (!isInternetAvailable!) ...{
                ElevatedButton(
                  onPressed: checkConnection,
                  child: const Text('try again!'),
                )
              },
            ],
          ),
        ),
      ),
    );
  }
}
