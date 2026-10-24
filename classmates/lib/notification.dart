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
              // Navigator.pushNamed(context, '/notification'); //네비게이션 아직 미수정
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
              Navigator.pushNamed(context, '/schedule');
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

// ─────────────────────────────────────────────
// 일정(캘린더) 화면
// ─────────────────────────────────────────────

/// 일정 종류: 학사일정 / 수행평가
enum ScheduleType { academic, assessment }

/// 하루에 표시되는 일정 한 줄 (이후 백엔드에서 불러온 데이터로 교체)
class ScheduleItem {
  final String title;
  final ScheduleType type;
  const ScheduleItem(this.title, this.type);
}

DateTime _dateKey(DateTime d) => DateTime(d.year, d.month, d.day);

const Color _academicColor = Color(0xFF1E88E5); // 학사일정: 파랑
const Color _assessmentColor = Color(0xFFF57C00); // 수행평가: 주황
const Color _holidayColor = Color(0xFFE53935); // 공휴일/일요일: 빨강
const Color _saturdayColor = Color(0xFF1E5BE5); // 토요일: 파랑
const Color _purple = Color(0xFF6750A4);

Color _typeColor(ScheduleType t) =>
    t == ScheduleType.academic ? _academicColor : _assessmentColor;

String _typeName(ScheduleType t) =>
    t == ScheduleType.academic ? '학사일정' : '수행평가';

/// 한국 공휴일 (대체공휴일·임시공휴일 포함).
/// 2025~2026년 고정 데이터입니다. 이후 연도는 직접 추가하거나
/// 공공데이터포털 '특일 정보' API 등으로 대체하세요.
final Map<DateTime, String> _koreanHolidays = {
  // 2025
  DateTime(2025, 1, 1): '신정',
  DateTime(2025, 1, 27): '임시공휴일',
  DateTime(2025, 1, 28): '설날 연휴',
  DateTime(2025, 1, 29): '설날',
  DateTime(2025, 1, 30): '설날 연휴',
  DateTime(2025, 3, 1): '삼일절',
  DateTime(2025, 3, 3): '대체공휴일',
  DateTime(2025, 5, 5): '어린이날·부처님오신날',
  DateTime(2025, 5, 6): '대체공휴일',
  DateTime(2025, 6, 3): '대통령 선거일',
  DateTime(2025, 6, 6): '현충일',
  DateTime(2025, 8, 15): '광복절',
  DateTime(2025, 10, 3): '개천절',
  DateTime(2025, 10, 5): '추석 연휴',
  DateTime(2025, 10, 6): '추석',
  DateTime(2025, 10, 7): '추석 연휴',
  DateTime(2025, 10, 8): '대체공휴일',
  DateTime(2025, 10, 9): '한글날',
  DateTime(2025, 12, 25): '성탄절',
  // 2026
  DateTime(2026, 1, 1): '신정',
  DateTime(2026, 2, 16): '설날 연휴',
  DateTime(2026, 2, 17): '설날',
  DateTime(2026, 2, 18): '설날 연휴',
  DateTime(2026, 3, 1): '삼일절',
  DateTime(2026, 3, 2): '대체공휴일',
  DateTime(2026, 5, 5): '어린이날',
  DateTime(2026, 5, 24): '부처님오신날',
  DateTime(2026, 5, 25): '대체공휴일',
  DateTime(2026, 6, 3): '지방선거일',
  DateTime(2026, 6, 6): '현충일',
  DateTime(2026, 8, 15): '광복절',
  DateTime(2026, 8, 17): '대체공휴일',
  DateTime(2026, 9, 24): '추석 연휴',
  DateTime(2026, 9, 25): '추석',
  DateTime(2026, 9, 26): '추석 연휴',
  DateTime(2026, 9, 28): '대체공휴일',
  DateTime(2026, 10, 3): '개천절',
  DateTime(2026, 10, 5): '대체공휴일',
  DateTime(2026, 10, 9): '한글날',
  DateTime(2026, 12, 25): '성탄절',
};

/// 임의의 학사일정/수행평가 (현재 달 기준 전달~다음달에 항상 보이도록 생성)
Map<DateTime, List<ScheduleItem>> _buildSampleSchedule() {
  final map = <DateTime, List<ScheduleItem>>{};
  void add(int y, int m, int d, String title, ScheduleType type) {
    map.putIfAbsent(DateTime(y, m, d), () => []).add(ScheduleItem(title, type));
  }

  const ac = ScheduleType.academic;
  const asmt = ScheduleType.assessment;
  final now = DateTime.now();

  for (int off = -1; off <= 1; off++) {
    final base = DateTime(now.year, now.month + off, 1);
    final y = base.year, m = base.month;

    add(y, m, 4, '학급 회의', ac);
    add(y, m, 7, '국어 발표', asmt);
    add(y, m, 10, '학부모 상담', ac);
    add(y, m, 13, '영어 에세이', asmt);
    add(y, m, 15, '현장체험학습', ac);
    add(y, m, 20, '중간고사', ac);
    add(y, m, 21, '중간고사', ac);
    add(y, m, 21, '과학 보고서', asmt);
    add(y, m, 22, '중간고사', ac);
    add(y, m, 25, '진로 특강', ac);
    add(y, m, 27, '수학 수행평가', asmt);
    add(y, m, 27, '체육대회', ac);
  }
  return map;
}

class schedule extends StatefulWidget {
  const schedule({super.key});

  @override
  State<schedule> createState() => _scheduleState();
}

class _scheduleState extends State<schedule> {
  static const List<String> _weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  static const double _lineHeight = 14;

  late DateTime _month; // 표시 중인 달 (1일 기준)
  final Map<DateTime, List<ScheduleItem>> _items = _buildSampleSchedule();

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
  }

  void _moveMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  void _goToday() {
    final n = DateTime.now();
    setState(() => _month = DateTime(n.year, n.month));
  }

  @override
  Widget build(BuildContext context) {
    // 달력 시작일: 이번 달 1일이 속한 주의 일요일
    final first = DateTime(_month.year, _month.month, 1);
    final start = DateTime(first.year, first.month, 1 - first.weekday % 7);

    return Scaffold(
      appBar: const notification_bar(),
      body: GestureDetector(
        // 좌우로 밀어서 달 이동
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v > 300) _moveMonth(-1);
          if (v < -300) _moveMonth(1);
        },
        child: Column(
          children: [
            _buildHeader(),
            _buildLegend(),
            _buildWeekdayRow(),
            Expanded(
              child: Column(
                children: [
                  for (int r = 0; r < 6; r++)
                    Expanded(
                      child: Row(
                        children: [
                          for (int c = 0; c < 7; c++)
                            Expanded(
                              child: _buildDayCell(DateTime(start.year,
                                  start.month, start.day + r * 7 + c)),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상단: 2026년 10월 / 이전·다음 / 오늘
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _moveMonth(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '${_month.year}년 ${_month.month}월',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => _moveMonth(1),
            icon: const Icon(Icons.chevron_right),
          ),
          const Spacer(),
          TextButton(onPressed: _goToday, child: const Text('오늘')),
        ],
      ),
    );
  }

  // 범례
  Widget _buildLegend() {
    Widget dot(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          dot(_academicColor, '학사일정'),
          const SizedBox(width: 12),
          dot(_assessmentColor, '수행평가'),
          const SizedBox(width: 12),
          const Text('공휴일',
              style: TextStyle(
                  fontSize: 12,
                  color: _holidayColor,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 요일 줄 (일 월 화 수 목 금 토)
  Widget _buildWeekdayRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFDDDDDD)),
          bottom: BorderSide(color: Color(0xFFDDDDDD)),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: Text(
                  _weekdays[i],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: i == 0
                        ? _holidayColor
                        : (i == 6 ? _saturdayColor : Colors.black87),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 날짜 칸: 날짜 숫자 아래에 공휴일/학사일정/수행평가가 세로로 한 줄씩
  Widget _buildDayCell(DateTime day) {
    final key = _dateKey(day);
    final inMonth = day.month == _month.month;
    final holiday = _koreanHolidays[key];
    final items = _items[key] ?? const <ScheduleItem>[];
    final isToday = key == _dateKey(DateTime.now());

    Color numColor;
    if (holiday != null || day.weekday == DateTime.sunday) {
      numColor = _holidayColor;
    } else if (day.weekday == DateTime.saturday) {
      numColor = _saturdayColor;
    } else {
      numColor = Colors.black87;
    }
    if (!inMonth) numColor = numColor.withAlpha(90);

    // 표시할 줄들
    final lines = <Widget>[
      if (holiday != null)
        SizedBox(
          height: _lineHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              holiday,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: inMonth ? _holidayColor : _holidayColor.withAlpha(90),
              ),
            ),
          ),
        ),
      for (final it in items)
        SizedBox(
          height: _lineHeight,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: inMonth
                  ? _typeColor(it.type)
                  : _typeColor(it.type).withAlpha(90),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              it.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
    ];

    return InkWell(
      onTap: () => _showDayDetail(day),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE3E3E3), width: 0.5),
          color: inMonth ? Colors.white : const Color(0xFFFAFAFA),
        ),
        padding: const EdgeInsets.fromLTRB(2, 3, 2, 0),
        child: LayoutBuilder(builder: (context, constraints) {
          // 칸 높이에 맞춰 줄 수 계산, 넘치면 +n 으로 표시
          final avail = constraints.maxHeight - 24;
          final fit = (avail / _lineHeight).floor().clamp(0, 99);
          List<Widget> shown;
          if (lines.length <= fit) {
            shown = lines;
          } else if (fit >= 1) {
            shown = [
              ...lines.take(fit - 1),
              SizedBox(
                height: _lineHeight,
                child: Text(
                  '+${lines.length - (fit - 1)}',
                  style: const TextStyle(fontSize: 9, color: Colors.black54),
                ),
              ),
            ];
          } else {
            shown = const [];
          }

          return ClipRect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isToday ? _purple : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : numColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ...shown,
              ],
            ),
          );
        }),
      ),
    );
  }

  // 날짜를 누르면 그날의 일정을 전부 보여주는 시트
  void _showDayDetail(DateTime day) {
    final key = _dateKey(day);
    final holiday = _koreanHolidays[key];
    final items = _items[key] ?? const <ScheduleItem>[];

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${day.month}월 ${day.day}일 (${_weekdays[day.weekday % 7]})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // 일정이 많아 화면을 넘어가면 이 영역(날짜 제목 아래)만 스크롤됨
            // (일정이 적을 때는 기존처럼 내용 크기에 맞는 시트 그대로)
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (holiday != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(holiday,
                            style: const TextStyle(
                                color: _holidayColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    for (final it in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _typeColor(it.type),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                  '[${_typeName(it.type)}] ${it.title}'),
                            ),
                          ],
                        ),
                      ),
                    if (holiday == null && items.isEmpty)
                      const Text('등록된 일정이 없습니다.',
                          style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}