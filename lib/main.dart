import 'package:flutter/material.dart';

import 'views/view.exp.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) =>  LoginPage(),
        '/home': (context) =>  HomePage(),
      },
    );
  }
}
