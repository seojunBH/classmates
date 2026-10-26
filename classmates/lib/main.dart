import 'package:classmates/attendance.dart';
import 'package:classmates/notification.dart';
import 'package:flutter/material.dart';
import 'package:classmates/ranking.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/ranking',
      routes: {
        '/notification':(context)=>const notification(),
        '/rules':(context)=>const rules(),
        '/schedule': (context) => const schedule(),
        '/attendance': (context) => const attendance(),
        '/ranking': (context) => const RankingBoardPage(),
      },
    );
  }
}