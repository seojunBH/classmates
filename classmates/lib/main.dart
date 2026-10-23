import 'package:classmates/notification.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const rules(),
      routes: {
        '/notification':(context)=>const notification(),
        '/rules':(context)=>const rules(),
      },
    );
  }
}