// bottomBar.dart
import 'package:flutter/material.dart';

class bottom_bar extends StatelessWidget {
  const bottom_bar({super.key});

  // ──────────────────────────────────────────────
  // ★ 여기서 아이콘 / 텍스트 / 경로를 수정하세요 ★
  //  - icon  : 버튼에 표시될 아이콘 (현재는 임시 아이콘)
  //  - label : 버튼에 표시될 텍스트 (현재는 임시 텍스트)
  //  - route : pushNamed로 이동할 경로 (요청하신 경로 그대로)
  //  - extraRoutes : (선택) 이 버튼이 '현재 위치'로 표시되어야 하는 하위 화면 경로
  // ──────────────────────────────────────────────
  static const List<_BottomItem> _items = [
    _BottomItem(
      icon: Icons.notifications,
      label: '공지',
      route: '/notification',
      extraRoutes: ['/rules', '/time_table', '/schedule'], // 규칙/시간표/일정 화면에서도 '공지'를 현재 위치로 표시
    ),
    _BottomItem(icon: Icons.emoji_events, label: '랭크', route: '/ranking'),
    _BottomItem(icon: Icons.check_circle, label: '출석', route: '/attendance'),
  ];

  // 현재 라우트와 같으면 이동하지 않음
  void _go(BuildContext context, String routeName) {
    if (ModalRoute.of(context)?.settings.name == routeName) return;
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Container(
      height: 80,
      color: const Color.fromARGB(255, 212, 211, 211), // 상단바와 동일한 배경색
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _items.map((item) {
            final isCurrent = currentRoute == item.route ||
                item.extraRoutes.contains(currentRoute);

            return SizedBox(
              width: 100,
              height: 100,
              child: TextButton(
                onPressed: () => _go(context, item.route),
                // 현재 위치의 버튼은 배경색/테두리를 달리해서 표시
                style: isCurrent
                    ?  TextButton.styleFrom(
                        backgroundColor: Colors.black12,
                        side: const BorderSide(width: 2,color: Colors.black12),
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon),
                    Text(item.label),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BottomItem {
  final IconData icon;
  final String label;
  final String route;
  final List<String> extraRoutes;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.route,
    this.extraRoutes = const [],
  });
}