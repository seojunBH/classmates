import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'bottomBar.dart';

//전체 공지화면 앱바
class notification_bar extends StatelessWidget
    implements PreferredSizeWidget {
  const notification_bar({super.key});

  // 상단바 버튼 목록 (아이콘 / 텍스트 / 경로)
  static const List<_TopItem> _items = [
    _TopItem(icon: Icons.notifications, label: '공지', route: '/notification'),
    _TopItem(icon: Icons.rule, label: '규칙', route: '/rules'),
    _TopItem(icon: Icons.table_view, label: '시간표', route: '/time_table'),
    _TopItem(icon: Icons.schedule, label: '일정', route: '/schedule'),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(80);

  // 현재 라우트와 같으면 이동하지 않음 (하단바와 동일)
  void _go(BuildContext context, String routeName) {
    if (ModalRoute.of(context)?.settings.name == routeName) return;
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromARGB(255, 212, 211, 211),
      toolbarHeight: 80,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items.map((item) {
          final isCurrent = currentRoute == item.route;

          return OutlinedButton(
            onPressed: () => _go(context, item.route),
            // 현재 위치의 버튼은 하단바와 같은 스타일(배경색/테두리)로 표시
            style: isCurrent
                ? OutlinedButton.styleFrom(
                    backgroundColor: Colors.black12,
                    side: const BorderSide(width: 2, color: Colors.black12),
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon),
                Text(item.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TopItem {
  final IconData icon;
  final String label;
  final String route;

  const _TopItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

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
        bottomNavigationBar: const bottom_bar(),
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
        bottomNavigationBar: const bottom_bar(),
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
      bottomNavigationBar: const bottom_bar(),
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
// ─────────────────────────────────────────────
// 시간표 화면 (NEIS 교육정보 개발 포털 Open API)
// ─────────────────────────────────────────────

/// open.neis.go.kr 에서 발급받은 인증키를 아래 문자열에 직접 입력하세요.
const String _neisKey = 'c5be902880ea4e1695596365a98b8f8d';

const Color _ttPurple = Color(0xFF6750A4); // 입력창 테두리
const Color _ttDivider = Color(0xFFE6E0F5); // 구분선
const Color _ttDropdownBg = Color(0xFFF3EDF7); // 드롭다운 배경
const Color _ttHeaderBg = Color(0xFFEDEDFA); // 표 머리칸
const Color _ttCellBg = Color(0xFFFFFFE8); // 표 내용칸
const Color _ttBorder = Color(0xFFCCCCCC);
const Color _ttLink = Color(0xFF1A0DAB); // 학교 검색 결과 (파란 글씨)

class _NeisException implements Exception {
  final String message;
  const _NeisException(this.message);

  @override
  String toString() => message;
}

class _NeisSchool {
  final String officeCode; // ATPT_OFCDC_SC_CODE (시도교육청 코드)
  final String schoolCode; // SD_SCHUL_CODE (학교 코드)
  final String name; // SCHUL_NM
  final String kind; // SCHUL_KND_SC_NM (초등학교/중학교/고등학교/특수학교)
  final String region; // 지역 (서울, 경기 ...)

  const _NeisSchool({
    required this.officeCode,
    required this.schoolCode,
    required this.name,
    required this.kind,
    required this.region,
  });

  factory _NeisSchool.fromJson(Map<String, dynamic> j) => _NeisSchool(
        officeCode: j['ATPT_OFCDC_SC_CODE']?.toString() ?? '',
        schoolCode: j['SD_SCHUL_CODE']?.toString() ?? '',
        name: j['SCHUL_NM']?.toString() ?? '',
        kind: j['SCHUL_KND_SC_NM']?.toString() ?? '',
        region: _shortRegion(j['LCTN_SC_NM']?.toString() ?? ''),
      );
}

/// '서울특별시' → '서울', '충청북도' → '충북' 처럼 줄여서 표시
String _shortRegion(String full) {
  const special = {
    '충청북도': '충북',
    '충청남도': '충남',
    '전라북도': '전북',
    '전북특별자치도': '전북',
    '전라남도': '전남',
    '경상북도': '경북',
    '경상남도': '경남',
  };
  if (special.containsKey(full)) return special[full]!;
  return full.length >= 2 ? full.substring(0, 2) : full;
}

/// NEIS Open API 공통 호출.
/// 페이지를 나누어 조회해 결과가 1,000건을 넘더라도 누락되지 않도록 합니다.
Future<List<Map<String, dynamic>>> _neisFetch(
    String service, Map<String, String> params) async {
  if (_neisKey.trim().isEmpty) {
    throw const _NeisException(
      'NEIS 인증키가 설정되지 않았습니다.\n'
      'notification.dart 상단의 _neisKey에 발급받은 인증키를 입력해주세요.',
    );
  }

  const pageSize = 1000;
  final allRows = <Map<String, dynamic>>[];

  for (var page = 1; page <= 100; page++) {
    final uri = Uri.https('open.neis.go.kr', '/hub/$service', {
      'KEY': _neisKey.trim(),
      'Type': 'json',
      'pIndex': '$page',
      'pSize': '$pageSize',
      ...params,
    });

    http.Response res;
    try {
      res = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const _NeisException('네트워크 연결을 확인해주세요.');
    }

    if (res.statusCode != 200) {
      throw _NeisException('NEIS 서버 오류가 발생했습니다. (${res.statusCode})');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      throw const _NeisException(
        'NEIS 응답을 해석할 수 없습니다. 인증키와 API 응답을 확인해주세요.',
      );
    }

    if (decoded is! Map) {
      throw const _NeisException('NEIS 응답 형식이 올바르지 않습니다.');
    }

    final body = Map<String, dynamic>.from(decoded);
    final topResult = body['RESULT'];
    if (topResult is Map) {
      final code = topResult['CODE']?.toString();
      if (code == 'INFO-200') return allRows;
      throw _NeisException(
        topResult['MESSAGE']?.toString() ?? 'NEIS API 오류가 발생했습니다.',
      );
    }

    final blocks = body[service];
    if (blocks is! List) {
      if (allRows.isNotEmpty) return allRows;
      throw const _NeisException(
        'NEIS 응답에 시간표 데이터가 없습니다. 학교·학급·조회 날짜를 확인해주세요.',
      );
    }

    final pageRows = <Map<String, dynamic>>[];
    for (final block in blocks) {
      if (block is! Map) continue;

      final head = block['head'];
      if (head is List) {
        for (final item in head) {
          if (item is! Map || item['RESULT'] is! Map) continue;
          final result = item['RESULT'] as Map;
          final code = result['CODE']?.toString();
          if (code == 'INFO-200') return allRows;
          if (code != null && code != 'INFO-000') {
            throw _NeisException(
              result['MESSAGE']?.toString() ?? 'NEIS API 오류가 발생했습니다.',
            );
          }
        }
      }

      final rows = block['row'];
      if (rows is List) {
        pageRows.addAll(
          rows.whereType<Map>().map(
                (row) => Map<String, dynamic>.from(row),
              ),
        );
      }
    }

    allRows.addAll(pageRows);

    // 마지막 페이지는 보통 pageSize보다 적은 결과를 반환합니다.
    if (pageRows.length < pageSize) return allRows;
  }

  throw const _NeisException(
    '조회 결과가 너무 많아 중단했습니다. 검색 조건을 확인해주세요.',
  );
}

String _ymd(DateTime d) =>
    '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

/// 학교 종류별 시간표 서비스명
String? _timetableService(String kind) {
  if (kind.contains('초등')) return 'elsTimetable';
  if (kind.contains('중학')) return 'misTimetable';
  if (kind.contains('고등')) return 'hisTimetable';
  if (kind.contains('특수')) return 'spsTimetable';
  return null;
}

int _numCompare(String a, String b) {
  final x = int.tryParse(a), y = int.tryParse(b);
  if (x != null && y != null) return x.compareTo(y);
  return a.compareTo(b);
}

class time_table extends StatefulWidget {
  const time_table({super.key});

  @override
  State<time_table> createState() => _time_tableState();
}

class _time_tableState extends State<time_table> {
  _NeisSchool? _school;
  bool _searching = false; // 학교 찾기 화면 표시 여부

  // 학급 목록 (학년 → 반 목록)
  Map<String, List<String>> _classesByGrade = {};
  bool _classLoading = false;
  String? _classError;

  String? _grade; // '1'
  String? _className; // '1'

  // 시간표: yyyyMMdd → (교시 → 과목)
  Map<String, Map<int, String>>? _timetable;
  bool _ttLoading = false;
  String? _ttError;
  int _reqId = 0;

  late DateTime _monday; // 표시할 주의 월요일

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    // 토/일요일에는 다음 주 시간표를 보여줌
    final shift = n.weekday >= DateTime.saturday ? 7 : 0;
    _monday = DateTime(n.year, n.month, n.day - (n.weekday - 1) + shift);
  }

  List<String> get _grades {
    final list = _classesByGrade.keys.toList()..sort(_numCompare);
    return list;
  }

  List<String> get _classOptions {
    if (_grade != null) return _classesByGrade[_grade] ?? const [];
    // 학년을 아직 고르지 않았다면 전체 반 번호를 보여줌
    final all = <String>{for (final l in _classesByGrade.values) ...l};
    return all.toList()..sort(_numCompare);
  }

  // ── 학교 선택 → 학급 목록 불러오기 ──
  Future<void> _selectSchool(_NeisSchool school) async {
    _reqId++;
    setState(() {
      _school = school;
      _searching = false;
      _grade = null;
      _className = null;
      _timetable = null;
      _ttLoading = false;
      _ttError = null;
      _classesByGrade = {};
      _classLoading = true;
      _classError = null;
    });
    await _loadClasses(school);
  }

  Future<void> _loadClasses(_NeisSchool school) async {
    final now = DateTime.now();
    final academicYear = now.month >= 3 ? now.year : now.year - 1;
    try {
      final rows = await _neisFetch('classInfo', {
        'ATPT_OFCDC_SC_CODE': school.officeCode,
        'SD_SCHUL_CODE': school.schoolCode,
        'AY': '$academicYear',
      });
      if (!mounted || _school != school) return;

      final grouped = <String, Set<String>>{};
      for (final r in rows) {
        final g = r['GRADE']?.toString() ?? '';
        final c = r['CLASS_NM']?.toString() ?? '';
        if (g.isEmpty || c.isEmpty) continue;
        grouped.putIfAbsent(g, () => {}).add(c);
      }
      setState(() {
        _classesByGrade = {
          for (final e in grouped.entries) e.key: e.value.toList()..sort(_numCompare)
        };
        _classLoading = false;
        _classError =
            grouped.isEmpty ? '학급 정보를 찾을 수 없습니다.' : null;
      });
    } on _NeisException catch (e) {
      if (!mounted || _school != school) return;
      setState(() {
        _classLoading = false;
        _classError = e.message;
      });
    } catch (e) {
      if (!mounted || _school != school) return;
      setState(() {
        _classLoading = false;
        _classError = '학급 정보를 처리하지 못했습니다: $e';
      });
    }
  }

  void _onGradeChanged(String? g) {
    setState(() {
      _grade = g;
      // 새 학년에 없는 반이면 반 선택 해제
      if (g != null &&
          _className != null &&
          !(_classesByGrade[g]?.contains(_className) ?? false)) {
        _className = null;
      }
    });
    _loadTimetable();
  }

  void _onClassChanged(String? c) {
    setState(() => _className = c);
    _loadTimetable();
  }

  // ── 시간표 불러오기 ──
  Future<void> _loadTimetable() async {
    final id = ++_reqId;
    final school = _school;
    final grade = _grade;
    final cls = _className;

    if (school == null || grade == null || cls == null) {
      setState(() {
        _timetable = null;
        _ttLoading = false;
        _ttError = null;
      });
      return;
    }

    final service = _timetableService(school.kind);
    if (service == null) {
      setState(() {
        _timetable = null;
        _ttLoading = false;
        _ttError = '${school.kind}은(는) 시간표 조회를 지원하지 않습니다.';
      });
      return;
    }

    setState(() {
      _ttLoading = true;
      _ttError = null;
      _timetable = null;
    });

    try {
      final rows = await _neisFetch(service, {
        'ATPT_OFCDC_SC_CODE': school.officeCode,
        'SD_SCHUL_CODE': school.schoolCode,
        // NEIS 시간표 조회에는 해당 학년도와 학기도 함께 전달합니다.
        'AY': '${_monday.month >= 3 ? _monday.year : _monday.year - 1}',
        'SEM': '${_monday.month >= 8 || _monday.month <= 2 ? 2 : 1}',
        'GRADE': grade,
        'CLASS_NM': cls,
        'TI_FROM_YMD': _ymd(_monday),
        'TI_TO_YMD':
            _ymd(DateTime(_monday.year, _monday.month, _monday.day + 4)),
      });
      if (!mounted || id != _reqId) return;

      final data = <String, Map<int, String>>{};
      for (final r in rows) {
        final date = r['ALL_TI_YMD']?.toString() ?? '';
        final period = int.tryParse(r['PERIO']?.toString() ?? '');
        final subject = r['ITRT_CNTNT']?.toString() ?? '';
        if (date.isEmpty || period == null || subject.isEmpty) continue;
        final day = data.putIfAbsent(date, () => {});
        final prev = day[period];
        // 같은 교시에 여러 과목이 있으면 줄바꿈으로 함께 표시
        if (prev == null) {
          day[period] = subject;
        } else if (!prev.split('\n').contains(subject)) {
          day[period] = '$prev\n$subject';
        }
      }
      setState(() {
        _timetable = data;
        _ttLoading = false;
      });
    } on _NeisException catch (e) {
      if (!mounted || id != _reqId) return;
      setState(() {
        _ttLoading = false;
        _ttError = e.message;
      });
    } catch (e) {
      if (!mounted || id != _reqId) return;
      setState(() {
        _ttLoading = false;
        _ttError = '시간표 데이터를 처리하지 못했습니다: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 학교 찾기 화면에서 뒤로가기 → 시간표 화면으로 복귀
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _searching) setState(() => _searching = false);
      },
      child: Scaffold(
        appBar: const notification_bar(),
        bottomNavigationBar: const bottom_bar(),
        body: _searching
            ? _SchoolSearchPanel(onSelected: _selectSchool)
            : _buildMain(),
      ),
    );
  }

  Widget _buildMain() {
    final school = _school;

    // 학교 입력 이전
    if (school == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('학교 이름을 입력하세요',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => setState(() => _searching = true),
              child: const Text('학교 찾기'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 학교명 + 학교 찾기 버튼
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  school.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () => setState(() => _searching = true),
                child: const Text('학교 찾기'),
              ),
            ],
          ),
        ),
        Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: _ttDivider,
        ),
        // 학급 입력
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Text('학급 :',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPickerField(
                  key: ValueKey('grade-${school.schoolCode}'),
                  hint: '학년',
                  suffix: '학년',
                  options: _grades,
                  current: _grade,
                  onChanged: _onGradeChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPickerField(
                  key: ValueKey('class-${school.schoolCode}-$_grade'),
                  hint: '반',
                  suffix: '반',
                  options: _classOptions,
                  current: _className,
                  onChanged: _onClassChanged,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: _buildBody(),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_classLoading || _ttLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_classError != null) {
      return _errorView(_classError!, () => _loadClasses(_school!));
    }
    if (_ttError != null) {
      return _errorView(_ttError!, _loadTimetable);
    }
    final data = _timetable;
    if (data == null) return const SizedBox.shrink(); // 학급 입력 이전
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: Text('이번 주 시간표 정보가 없습니다.')),
      );
    }
    return _buildTable(data);
  }

  Widget _errorView(String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }

  // 학년 / 반 입력창 (클릭하면 목록이 뜨고, 선택하면 채워짐. X 버튼으로 비움)
  Widget _buildPickerField({
    required Key key,
    required String hint,
    required String suffix,
    required List<String> options,
    required String? current,
    required ValueChanged<String?> onChanged,
  }) {
    String label(String v) => '$v$suffix';
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: _ttPurple, width: 2),
    );

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      return Autocomplete<String>(
        key: key,
        initialValue: current == null
            ? null
            : TextEditingValue(text: label(current)),
        displayStringForOption: label,
        optionsBuilder: (value) {
          final text = value.text.trim();
          // 비어있거나 이미 선택된 값이면 전체 목록 표시
          if (text.isEmpty || options.any((o) => label(o) == text)) {
            return options;
          }
          return options.where((o) => label(o).contains(text));
        },
        onSelected: (v) {
          FocusManager.instance.primaryFocus?.unfocus();
          onChanged(v);
        },
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onTapOutside: (_) => focusNode.unfocus(),
            onChanged: (t) {
              // 직접 고쳐 쓰면 선택 해제 (시간표 숨김)
              if (current != null && t != label(current)) onChanged(null);
            },
            decoration: InputDecoration(
              hintText: hint,
              border: border,
              enabledBorder: border,
              focusedBorder: border,
              suffixIcon: IconButton(
                icon: const Icon(Icons.cancel_outlined),
                onPressed: () {
                  controller.clear();
                  onChanged(null);
                  focusNode.requestFocus();
                },
              ),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, opts) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              color: _ttDropdownBg,
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: width,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: opts.length,
                    itemBuilder: (context, i) {
                      final o = opts.elementAt(i);
                      return InkWell(
                        onTap: () => onSelected(o),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          child: Text(label(o),
                              style: const TextStyle(fontSize: 16)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // 주간 시간표 표
  Widget _buildTable(Map<String, Map<int, String>> data) {
    const dayNames = ['월', '화', '수', '목', '금'];
    final days = List.generate(
        5, (i) => DateTime(_monday.year, _monday.month, _monday.day + i));

    int maxPeriod = 7;
    for (final m in data.values) {
      for (final p in m.keys) {
        if (p > maxPeriod) maxPeriod = p;
      }
    }

    Widget cell(String text,
        {required Color bg, double fontSize = 12, bool bold = false}) {
      return Container(
        color: bg,
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
      );
    }

    return Table(
      border: TableBorder.all(color: _ttBorder, width: 0.5),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {0: FlexColumnWidth(1.3)},
      children: [
        TableRow(children: [
          cell('교시', bg: _ttHeaderBg, fontSize: 11),
          for (int i = 0; i < 5; i++)
            cell('${dayNames[i]}(${days[i].day})',
                bg: _ttHeaderBg, fontSize: 11),
        ]),
        for (int p = 1; p <= maxPeriod; p++)
          TableRow(children: [
            cell('$p', bg: _ttHeaderBg, fontSize: 11),
            for (int i = 0; i < 5; i++)
              cell(data[_ymd(days[i])]?[p] ?? '', bg: _ttCellBg),
          ]),
      ],
    );
  }
}

// 학교 찾기 (검색어 입력 → 검색 → 결과에서 학교 선택)
class _SchoolSearchPanel extends StatefulWidget {
  final ValueChanged<_NeisSchool> onSelected;
  const _SchoolSearchPanel({required this.onSelected});

  @override
  State<_SchoolSearchPanel> createState() => _SchoolSearchPanelState();
}

class _SchoolSearchPanelState extends State<_SchoolSearchPanel> {
  final TextEditingController _controller = TextEditingController();
  List<_NeisSchool>? _results; // null: 아직 검색 전
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _neisFetch('schoolInfo', {'SCHUL_NM': keyword});
      if (!mounted) return;
      setState(() {
        _results = rows.map(_NeisSchool.fromJson).toList();
        _loading = false;
      });
    } on _NeisException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _results = null;
        _error = e.message;
      });
    }
  }

  Widget _tableCell(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Center(child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    labelText: '학교 이름',
                    filled: true,
                    fillColor: const Color(0xFFE7E0EC),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel_outlined),
                      onPressed: () => _controller.clear(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: _search,
                child: const Text('학교 검색'),
              ),
            ],
          ),
        ),
        Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: _ttDivider,
        ),
        Expanded(child: _buildResults()),
      ],
    );
  }

  Widget _buildResults() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    final results = _results;
    if (results == null) return const SizedBox.shrink(); // 검색 이전
    if (results.isEmpty) return const Center(child: Text('검색 결과가 없습니다.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Table(
        border: TableBorder.all(color: _ttBorder, width: 0.5),
        columnWidths: const {0: FractionColumnWidth(0.2)},
        children: [
          TableRow(children: [
            _tableCell(const Text('지역')),
            _tableCell(const Text('학교명')),
          ]),
          for (final s in results)
            TableRow(children: [
              _tableCell(Text(s.region)),
              InkWell(
                onTap: () => widget.onSelected(s),
                child: _tableCell(Text(
                  s.name,
                  style: const TextStyle(
                    color: _ttLink,
                    decoration: TextDecoration.underline,
                  ),
                )),
              ),
            ]),
        ],
      ),
    );
  }
}