import 'package:flutter/material.dart';
import 'LoginPage.dart';

void main() {
  runApp(const MyApp());
  runApp(MaterialApp(home: LoginPage(), debugShowCheckedModeBanner: false));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home : LoginPage(),
    );
  }
}
