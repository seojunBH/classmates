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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoTransitionBuilder(),
            TargetPlatform.iOS: NoTransitionBuilder(),
            // 컴퓨터나 웹에서 테스트한다면 아래도 추가
            TargetPlatform.windows: NoTransitionBuilder(),
            TargetPlatform.macOS: NoTransitionBuilder(),
            TargetPlatform.linux: NoTransitionBuilder(),
          },
        ),
      ),
      initialRoute: '/ranking',
      routes: {
        '/notification':(context)=>const notification(),
        '/rules':(context)=>const rules(),
        '/time_table': (context) => const time_table(),
        '/schedule': (context) => const schedule(),
        '/attendance': (context) => const attendance(),
        '/ranking': (context) => const RankingBoardPage(),
      },
    );
  }
}
// 화면 전환 애니메이션 없이 바로 화면을 보여주는 빌더
class NoTransitionBuilder extends PageTransitionsBuilder {
  const NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child; // 애니메이션을 적용하지 않고 화면 그대로 반환
  }
}