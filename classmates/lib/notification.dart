import 'package:flutter/material.dart';

//전체 공지화면 앱바
class notification_bar extends StatelessWidget
    implements PreferredSizeWidget {
  const notification_bar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 212, 211, 211),
      toolbarHeight: 80,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios_new),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notification');
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications),
                Text('공지'),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/rules');
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.rule),
                Text('규칙'),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notification'); //네비게이션 아직 미수정
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.table_view),
                Text('시간표'),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notification'); //네비게이션 아직 미수정
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule),
                Text('일정'),
              ],
            ),
          ),
        ],
      ),
    );
  }
} //+) 네비게이터 고치기

//가정통신문 공지 한 블록
class notification_card extends StatelessWidget {
  final String title;
  final String content;

  const notification_card({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 150,
        color: const Color.fromARGB(255, 212, 211, 211),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,),
                SizedBox(height: 30,),
                Text(content.length > 100 ? '${content.substring(0, 100)}...' : content,),
              ],
            ),
          ],
        ),
      ),
    );
  }
} //+) 추가기능 추가

//가정통신문 공지 전체 화면
class notification extends StatefulWidget {
  const notification({super.key});

  @override
  State<notification> createState() => _notificationState();
}

class _notificationState extends State<notification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const notification_bar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            notification_card(title: '학교 공지사항', content: '다음 주 월요일부터 중간고사 기간이 시작됩니다.' ),
            notification_card(title: '학교 공지사항', content: '다음 주 월요일부터 중간고사 기간이 시작됩니다.' ),
            notification_card(title: '학교 공지사항', content: '다음 주 월요일부터 중간고사 기간이 시작됩니다.' ),
          ],
        ),
    );
  }
} // +) 권리자에게는 공지 추가 기능 있어야 함, +) 플러스 알파 기능 추가, +) 카드 지금은 3개 임의 지정이지만 이후엔 추가하는 대로 되도록

// 규칙 전체 화면 (이후에 백엔드 작업 후에 규칙 적용하면 됨)
class rules extends StatefulWidget {
  const rules({super.key});

  @override
  State<rules> createState() => _rulesState();
}

class _rulesState extends State<rules> {
  // 화면에 띄울 데이터 (길이 제한 없음)
  final String rulesText = '''
📢 [O학년 O반 카톡방 이용 약속]  우리 반 소통방의 건강한 운영을 위해 아래 약속을 꼭 지켜주세요!  1. 닉네임은 [학번+이름]으로 설정하기  2. 대화는 평일 방과 후 저녁 6시까지만 하기 (주말에는 쉬어요!) 3. 개인적인 대화(사담, 게임 이야기, 장난)는 개인 톡에서 하기 4. 친구에게 상처 주는 말이나 욕설은 절대 금지! 5. 선생님께 드릴 말씀은 1:1 오픈프로필로 정중하게 보내기  * 규칙을 반복해서 어길 경우 경고 후 대화방 참여가 제한될 수 있습니다. 우리 서로 배려하는 예쁜 O반이 됩시다! ❤️
'''; // Text 예시 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: notification_bar(),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
                children: [
                  SizedBox(height: 30,),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(rulesText),
                  ),
                ],
              )
            ),
        ),
    );
  }
} //+) 피그마에 있던 아래 블록 아직 미구현

