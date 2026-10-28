import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

//가정통신문 공지 한 개의 데이터 (이후 firebase에서 불러온 데이터로 교체)
class NoticeItem {
  final String title;
  final String content;
  const NoticeItem({required this.title, required this.content});
}

//가정통신문 공지 한 블록 (누르면 onTap 실행)
class notification_card extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onTap;

  const notification_card({
    super.key,
    required this.title,
    required this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 가로 폭은 목록(ListView)이 정하고, 높이는 모든 카드가 같게 고정
    return Material(
      color: const Color.fromARGB(255, 212, 211, 211),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 150,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // 글자 수 제한(100자) + 줄 수 제한(3줄)으로 고정 높이를 넘지 않게 함
              Text(
                content.length > 100 ? '${content.substring(0, 100)}...' : content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
  // 화면에 띄울 공지 목록. 공지를 추가하면 이 목록에 항목이 늘어나고 화면에 그대로 반영됨.
  // (현재는 임시 데이터 / 이후 firebase에서 불러온 목록으로 교체)
  final List<NoticeItem> _notices = const [
    NoticeItem(title: '가정통신문', content: '2026학년도 2학기 학부모 상담 주간 운영 안내입니다.\n상담은 다음 주 월요일부터 금요일까지 진행되며, 희망하는 날짜와 시간을 신청서에 작성하여 담임선생님께 제출해 주시기 바랍니다.'),
    NoticeItem(title: '현장체험학습 안내', content: '다음 달 현장체험학습이 예정되어 있습니다.\n학생들은 오전 8시 30분까지 학교에 집합해야 하며, 편안한 복장과 운동화, 개인 물통을 준비해 주세요.\n참가 동의서는 이번 주 금요일까지 제출해 주시기 바랍니다.'),
    NoticeItem(title: '학교 공지사항', content: '다음 주 월요일부터 중간고사 기간이 시작됩니다.\n시험 시간표와 시험 범위를 미리 확인하고, 시험 당일에는 필기도구와 필요한 준비물을 빠짐없이 챙겨 주세요.'),
    NoticeItem(title: '급식 안내', content: '학교 급식실 시설 점검으로 인해 이번 주 수요일에는 급식 제공 시간이 변경됩니다.\n점심 식사는 오후 12시부터 제공될 예정이며, 학생들은 학년별 안내에 따라 질서 있게 식사해 주시기 바랍니다.'),
    NoticeItem(title: '교내 체육대회 안내', content: '학생들의 화합과 건강한 학교생활을 위한 교내 체육대회가 다음 달 개최됩니다.\n학급별 경기 종목과 일정은 추후 안내할 예정이며, 참가 학생들은 안전 수칙을 준수하고 체육활동에 필요한 복장과 준비물을 갖춰 주시기 바랍니다.'),
    NoticeItem(title: '개인정보 보호 교육 안내', content: '최근 온라인상에서 개인정보 유출 및 계정 도용 사례가 증가하고 있습니다.\n학생들은 비밀번호를 주기적으로 변경하고, 타인에게 계정 정보를 공유하지 않도록 주의해 주세요.\n가정에서도 자녀가 안전한 인터넷 사용 습관을 기를 수 있도록 지도해 주시기 바랍니다.'),
    NoticeItem(title: '방과후학교 수강 신청', content: '2학기 방과후학교 수강 신청이 시작되었습니다.\n프로그래밍, 영어, 수학 등 다양한 강좌가 개설될 예정이며, 강좌별 수강 인원과 운영 시간은 학교 홈페이지에서 확인할 수 있습니다.\n신청을 희망하는 학생은 안내된 기간 내에 신청을 완료해 주세요.'),
    NoticeItem(title: '봉사활동 참여 안내', content: '지역사회와 함께하는 환경 정화 봉사활동 참가자를 모집합니다.\n활동은 토요일 오전에 진행되며, 학교 주변 환경 정리와 분리배출 캠페인 등의 프로그램이 마련되어 있습니다.\n참여를 희망하는 학생은 참가 신청서를 작성하여 담당 선생님께 제출해 주세요.'),
    NoticeItem(title: '학부모 공개수업 안내', content: '학교 교육활동에 대한 학부모님의 이해를 돕기 위해 학부모 공개수업을 실시합니다.\n수업 참관을 희망하시는 학부모님께서는 안내된 날짜와 교시를 확인해 주시기 바랍니다.\n원활한 수업 진행을 위해 참관 중에는 휴대전화 사용을 자제해 주시고, 지정된 좌석을 이용해 주세요.'),
    NoticeItem(title: '학생 건강검진 안내', content: '학생들의 건강 상태 확인을 위한 정기 건강검진이 실시됩니다.\n검진 대상 학생은 지정된 기간 내에 검진기관을 방문해야 하며, 검진 전 주의사항과 준비물은 가정통신문을 통해 확인해 주시기 바랍니다.\n검진 결과에 추가 확인이 필요한 경우에는 보호자에게 별도로 안내할 예정입니다.'),
    NoticeItem(title: '학교 도서관 이용 안내', content: '도서관 장서 점검 및 자료 정리 작업으로 인해 이번 주 금요일 오후에는 도서 대출과 반납 서비스가 일시적으로 중단됩니다.\n대출 중인 도서는 반납 기한을 확인해 주시고, 필요한 도서는 운영 중인 시간에 미리 대출해 주시기 바랍니다.'),
    NoticeItem(title: '수학여행 참가 신청', content: '2학년 수학여행 일정 및 참가 신청에 관한 안내입니다.\n숙박 시설과 주요 방문 장소, 이동 방법 및 안전교육 계획은 첨부된 안내 자료를 참고해 주세요.\n참가 여부를 확인할 수 있도록 보호자 동의서를 작성하여 다음 주 수요일까지 제출해 주시기 바랍니다.'),
    NoticeItem(title: '교복 공동구매 안내', content: '신입생 및 교복 추가 구매가 필요한 학생들을 대상으로 교복 공동구매 신청을 받습니다.\n품목별 가격과 치수 측정 일정, 수령 방법은 학교 홈페이지에 게시된 안내문을 확인해 주세요.\n신청 기간 이후에는 공동구매 가격 적용이 어려울 수 있으므로 기간 내 신청해 주시기 바랍니다.'),
    NoticeItem(title: '학교폭력 예방 교육 안내', content: '안전하고 존중하는 학교 문화를 만들기 위해 학교폭력 예방 교육을 실시합니다.\n언어폭력, 사이버폭력, 따돌림 등 다양한 사례를 통해 올바른 의사소통 방법과 갈등 해결 방법을 배우게 됩니다.\n가정에서도 서로를 존중하는 언어 사용과 온라인 예절에 관해 자녀와 함께 이야기해 주시기 바랍니다.'),
    NoticeItem(title: '진로진학 설명회 개최', content: '학생들의 진로 탐색과 진학 준비를 지원하기 위한 진로진학 설명회를 개최합니다.\n이번 설명회에서는 대학 진학 전형의 주요 특징과 전공 선택 방법, 취업 및 진로 설계에 관한 정보를 안내할 예정입니다.\n참석을 희망하는 학부모님께서는 사전 신청 기간과 장소를 확인해 주시기 바랍니다.'),
    NoticeItem(title: '교내 소프트웨어 경진대회', content: '학생들의 창의적인 문제 해결 능력과 프로그래밍 역량을 높이기 위한 교내 소프트웨어 경진대회를 개최합니다.\n참가자는 개인 또는 팀 단위로 신청할 수 있으며, 주제와 제출 형식, 심사 기준은 별도 안내문을 참고해 주세요.\n참가 신청은 다음 주 금요일까지 접수합니다.'),
    NoticeItem(title: '미세먼지 대응 안내', content: '미세먼지 농도가 높아질 경우 학생들의 건강 보호를 위해 실외 체육활동이 실내 활동으로 변경될 수 있습니다.\n외출 시에는 기상 정보를 확인하고, 필요한 경우 보건용 마스크를 착용해 주세요.\n호흡기 증상이 있는 학생은 무리한 야외활동을 피하고 보호자 및 학교에 알려주시기 바랍니다.'),
    NoticeItem(title: '학교 시설 공사 안내', content: '학생들의 안전한 교육환경 조성을 위해 본관 일부 시설의 보수 공사가 진행됩니다.\n공사 기간에는 해당 구역의 출입이 제한되며, 통행 시 안내 표지와 안전요원의 지시에 따라 이동해 주세요.\n공사로 인한 소음이 발생할 수 있는 점 양해 부탁드리며, 학생 안전을 최우선으로 관리하겠습니다.'),
    NoticeItem(title: '겨울방학 생활 안내', content: '겨울방학 중 학생들이 안전하고 규칙적인 생활을 할 수 있도록 가정에서 관심과 지도를 부탁드립니다.\n장시간의 스마트폰 사용을 줄이고 충분한 수면과 적절한 신체활동을 유지할 수 있도록 지도해 주세요.\n또한 겨울철 화재 예방, 빙판길 안전, 대중교통 이용 수칙 등을 숙지하여 안전사고가 발생하지 않도록 유의해 주시기 바랍니다.'),
    NoticeItem(title: '학교 교육과정 설명회', content: '2027학년도 교육과정 운영 및 선택과목 안내를 위한 설명회를 개최합니다.\n이번 설명회에서는 학년별 교육과정 편성, 과목 선택 시 유의사항, 평가 방식 및 학업 계획 수립 방법 등을 안내할 예정입니다.\n학생과 학부모님께서는 안내된 일정과 장소를 확인하시고, 원활한 진행을 위해 시작 시간에 맞춰 참석해 주시기 바랍니다.'),
  ];

  // 공지를 누르면 제목과 전체 내용을 팝업으로 보여줌
  void _showNoticeDetail(NoticeItem notice) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(notice.title),
        // 내용이 길면 팝업 안에서 스크롤
        content: SingleChildScrollView(child: Text(notice.content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const notification_bar(),
      bottomNavigationBar: const bottom_bar(),
      body: _notices.isEmpty
          ? const Center(child: Text('등록된 공지가 없습니다.'))
          // 게시판처럼: 공지 사이 간격을 일정하게 두고, 많아지면 스크롤로 내려서 봄
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _notices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => notification_card(
                title: _notices[i].title,
                content: _notices[i].content,
                onTap: () => _showNoticeDetail(_notices[i]),
              ),
            ),
    );
  }
} // +) 권리자에게는 공지 추가 기능 있어야 함, +) 플러스 알파 기능 추가

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

/// 공공데이터포털(data.go.kr)에서 발급받은 '특일 정보' API 인증키를 입력하세요.
/// ★ 마이페이지에서 복사할 때 "일반 인증키(Decoding)" 쪽을 넣어야 합니다.
///   (Encoding 키를 넣으면 한 번 더 인코딩되어 인증 오류가 납니다.)
const String _dataGoKrKey = '4980157bf3a25ffdf58a704faa68b848cb732593ee2ccf36c744811c003181f6';

/// 국가 특일(공휴일) 조회 — 한국천문연구원 특일 정보 API (getRestDeInfo)
/// 해당 연도의 공휴일 전체를 {날짜: [이름들]} 로 돌려줍니다.
Future<Map<DateTime, List<String>>> _fetchHolidays(int year) async {
  if (_dataGoKrKey.trim().isEmpty) {
    throw const _NeisException(
      '공휴일 API 인증키가 설정되지 않았습니다.\n'
      'notification.dart 의 _dataGoKrKey 에 인증키를 입력해주세요.',
    );
  }

  final uri = Uri.https(
    'apis.data.go.kr',
    '/B090041/openapi/service/SpcdeInfoService/getRestDeInfo',
    {
      'serviceKey': _dataGoKrKey.trim(),
      'solYear': '$year',
      '_type': 'json',
      'numOfRows': '100',
      'pageNo': '1',
    },
  );

  http.Response res;
  try {
    res = await http.get(uri).timeout(const Duration(seconds: 15));
  } catch (_) {
    throw const _NeisException('네트워크 연결을 확인해주세요.');
  }
  if (res.statusCode != 200) {
    throw _NeisException('공휴일 서버 오류가 발생했습니다. (${res.statusCode})');
  }

  dynamic decoded;
  try {
    decoded = jsonDecode(utf8.decode(res.bodyBytes));
  } catch (_) {
    // 인증키 오류 등은 JSON이 아닌 XML/텍스트로 응답되는 경우가 있음
    throw const _NeisException('공휴일 응답을 해석할 수 없습니다. 인증키를 확인해주세요.');
  }

  final response = decoded is Map ? decoded['response'] : null;
  final header = response is Map ? response['header'] : null;
  final resultCode = header is Map ? header['resultCode']?.toString() : null;
  if (resultCode != null && resultCode != '00') {
    throw _NeisException(
      '공휴일 API 오류: ${header['resultMsg'] ?? resultCode}',
    );
  }

  final body = response is Map ? response['body'] : null;
  final items = body is Map ? body['items'] : null;
  // 결과가 없으면 items 가 빈 문자열("")로 옴
  if (items is! Map) return {};

  // 결과가 1건이면 item 이 Map, 여러 건이면 List 로 옴
  final raw = items['item'];
  final list = raw is List ? raw : (raw is Map ? [raw] : const []);

  final result = <DateTime, List<String>>{};
  for (final e in list) {
    if (e is! Map) continue;
    if (e['isHoliday']?.toString() != 'Y') continue; // 쉬는 날만
    final loc = e['locdate']?.toString() ?? '';
    final name = e['dateName']?.toString() ?? '';
    if (loc.length != 8 || name.isEmpty) continue;
    final date = DateTime(
      int.parse(loc.substring(0, 4)),
      int.parse(loc.substring(4, 6)),
      int.parse(loc.substring(6, 8)),
    );
    final names = result.putIfAbsent(date, () => []);
    if (!names.contains(name)) names.add(name);
  }
  return result;
}

/// 학사일정 조회 — NEIS 학사일정 API (SchoolSchedule)
/// 해당 연도의 학교 학사일정을 {날짜: [일정명들]} 로 돌려줍니다.
Future<Map<DateTime, List<String>>> _fetchAcademicSchedule(
    _NeisSchool school, int year) async {
  final rows = await _neisFetch('SchoolSchedule', {
    'ATPT_OFCDC_SC_CODE': school.officeCode,
    'SD_SCHUL_CODE': school.schoolCode,
    'AA_FROM_YMD': '${year}0101',
    'AA_TO_YMD': '${year}1231',
  });

  final result = <DateTime, List<String>>{};
  for (final r in rows) {
    final ymd = r['AA_YMD']?.toString() ?? '';
    final name = r['EVENT_NM']?.toString().trim() ?? '';
    if (ymd.length != 8 || name.isEmpty) continue;
    final date = DateTime(
      int.parse(ymd.substring(0, 4)),
      int.parse(ymd.substring(4, 6)),
      int.parse(ymd.substring(6, 8)),
    );
    final names = result.putIfAbsent(date, () => []);
    if (!names.contains(name)) names.add(name);
  }
  return result;
}

/// 수행평가 일정 (임시 데이터)
/// ★ 이후 firebase에서 불러온 데이터로 이 함수 안만 교체하면 됩니다.
///   (현재 달 기준 전달~다음달에 항상 보이도록 생성)
Map<DateTime, List<ScheduleItem>> _buildSampleAssessments() {
  final map = <DateTime, List<ScheduleItem>>{};
  void add(int y, int m, int d, String title) {
    map
        .putIfAbsent(DateTime(y, m, d), () => [])
        .add(ScheduleItem(title, ScheduleType.assessment));
  }

  final now = DateTime.now();

  for (int off = -1; off <= 1; off++) {
    final base = DateTime(now.year, now.month + off, 1);
    final y = base.year, m = base.month;

    add(y, m, 7, '국어 발표');
    add(y, m, 13, '영어 에세이');
    add(y, m, 21, '과학 보고서');
    add(y, m, 27, '수학 수행평가');
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

  // 수행평가: 임시 데이터 (이후 firebase)
  final Map<DateTime, List<ScheduleItem>> _assessments =
      _buildSampleAssessments();

  // 공휴일 / 학사일정: API에서 불러온 데이터 (연도별로 한 번만 불러와 보관)
  final Map<DateTime, List<String>> _holidays = {};
  final Map<DateTime, List<String>> _academic = {};
  final Set<int> _holidayYears = {}; // 이미 불러온 연도
  final Set<int> _academicYears = {};
  final Set<int> _loadingYears = {}; // 불러오는 중인 연도 (중복 호출 방지)
  _NeisSchool? _school; // 시간표 화면에서 선택해 둔 학교 (학사일정 조회용)
  bool _schoolChecked = false;
  String? _holidayError;
  String? _academicError;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
    _init();
  }

  Future<void> _init() async {
    // 시간표 화면에서 선택해 저장해 둔 학교를 가져옴
    await _SavedSelection.loadFromDisk();
    if (!mounted) return;
    setState(() {
      _school = _SavedSelection.school;
      _schoolChecked = true;
    });
    await _ensureLoaded();
  }

  /// 현재 달력(앞뒤로 이어지는 달 포함)에 필요한 연도의 데이터를 불러옴
  Future<void> _ensureLoaded() async {
    final first = DateTime(_month.year, _month.month, 1);
    final gridStart = DateTime(first.year, first.month, 1 - first.weekday % 7);
    final gridEnd =
        DateTime(gridStart.year, gridStart.month, gridStart.day + 41);
    final years = {gridStart.year, _month.year, gridEnd.year};
    for (final y in years) {
      _loadYear(y);
    }
  }

  Future<void> _loadYear(int year) async {
    final school = _school;
    final needHoliday = !_holidayYears.contains(year);
    final needAcademic = school != null && !_academicYears.contains(year);
    if (!needHoliday && !needAcademic) return;
    if (!_loadingYears.add(year)) return; // 이미 불러오는 중

    try {
      if (needHoliday) {
        try {
          final data = await _fetchHolidays(year);
          if (!mounted) return;
          setState(() {
            _holidays.addAll(data);
            _holidayYears.add(year);
            _holidayError = null;
          });
        } on _NeisException catch (e) {
          if (mounted) setState(() => _holidayError = e.message);
        } catch (e) {
          if (mounted) setState(() => _holidayError = '공휴일 정보를 처리하지 못했습니다: $e');
        }
      }

      if (needAcademic) {
        try {
          final data = await _fetchAcademicSchedule(school!, year);
          if (!mounted) return;
          setState(() {
            _academic.addAll(data);
            _academicYears.add(year);
            _academicError = null;
          });
        } on _NeisException catch (e) {
          if (mounted) setState(() => _academicError = e.message);
        } catch (e) {
          if (mounted) setState(() => _academicError = '학사일정을 처리하지 못했습니다: $e');
        }
      }
    } finally {
      _loadingYears.remove(year);
    }
  }

  void _retryLoad() {
    setState(() {
      _holidayError = null;
      _academicError = null;
    });
    _ensureLoaded();
  }

  /// 공휴일 이름 (여러 개면 ', '로 연결)
  String? _holidayName(DateTime key) {
    final names = _holidays[key];
    if (names == null || names.isEmpty) return null;
    return names.join(', ');
  }

  /// 하루의 학사일정 + 수행평가 (공휴일과 이름이 같은 학사일정은 중복이라 제외)
  List<ScheduleItem> _itemsOf(DateTime key) {
    final holidayNames = _holidays[key] ?? const <String>[];
    return [
      for (final title in _academic[key] ?? const <String>[])
        if (!holidayNames.contains(title))
          ScheduleItem(title, ScheduleType.academic),
      ...(_assessments[key] ?? const <ScheduleItem>[]),
    ];
  }

  void _moveMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
    _ensureLoaded();
  }

  void _goToday() {
    final n = DateTime.now();
    setState(() => _month = DateTime(n.year, n.month));
    _ensureLoaded();
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
            _buildStatusNotice(),
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

  // 학교 미선택 / 불러오기 실패 안내
  Widget _buildStatusNotice() {
    final messages = <String>[
      if (_holidayError != null) _holidayError!,
      if (_academicError != null) _academicError!,
      if (_schoolChecked && _school == null)
        '학사일정을 보려면 시간표 탭에서 학교를 먼저 선택해주세요.',
    ];
    if (messages.isEmpty) return const SizedBox.shrink();

    final hasError = _holidayError != null || _academicError != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              messages.join('\n'),
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),
          if (hasError)
            TextButton(onPressed: _retryLoad, child: const Text('다시 시도')),
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
    final holiday = _holidayName(key);
    final items = _itemsOf(key);
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
    final holiday = _holidayName(key);
    final items = _itemsOf(key);

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

  // 기기에 저장할 때 사용 (선택한 학교 기억용)
  Map<String, String> toStorage() => {
        'officeCode': officeCode,
        'schoolCode': schoolCode,
        'name': name,
        'kind': kind,
        'region': region,
      };

  factory _NeisSchool.fromStorage(Map<String, dynamic> j) => _NeisSchool(
        officeCode: j['officeCode']?.toString() ?? '',
        schoolCode: j['schoolCode']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        kind: j['kind']?.toString() ?? '',
        region: j['region']?.toString() ?? '',
      );
}

/// 시간표 화면에서 고른 학교 / 학년 / 반 (+ 불러온 학급·시간표)을 보관합니다.
/// - 메모리(static)에 두어 화면을 나갔다 와도 바로 복원되고,
/// - 기기(shared_preferences)에도 저장해 앱을 완전히 종료했다 켜도 학교·학급이 유지됩니다.
class _SavedSelection {
  static _NeisSchool? school;
  static String? grade;
  static String? className;

  // 메모리 전용 캐시 (앱 종료 시 사라짐)
  static Map<String, List<String>>? classesByGrade;
  static Map<String, Map<int, String>>? timetable;
  static DateTime? timetableMonday;

  static bool ready = false; // 기기에서 읽기를 끝냈는지
  static Future<void>? _loading;

  static const _kSchool = 'tt_school';
  static const _kGrade = 'tt_grade';
  static const _kClass = 'tt_class';

  static Future<void> loadFromDisk() => _loading ??= _read();

  static Future<void> _read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kSchool);
      if (raw != null) {
        school = _NeisSchool.fromStorage(
          Map<String, dynamic>.from(jsonDecode(raw) as Map),
        );
        grade = prefs.getString(_kGrade);
        className = prefs.getString(_kClass);
      }
    } catch (e) {
      debugPrint('저장된 시간표 선택을 읽지 못했습니다: $e');
    }
    ready = true;
  }

  static Future<void> saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sc = school;
      if (sc == null) {
        await prefs.remove(_kSchool);
      } else {
        await prefs.setString(_kSchool, jsonEncode(sc.toStorage()));
      }
      final g = grade, c = className;
      if (g == null) {
        await prefs.remove(_kGrade);
      } else {
        await prefs.setString(_kGrade, g);
      }
      if (c == null) {
        await prefs.remove(_kClass);
      } else {
        await prefs.setString(_kClass, c);
      }
    } catch (e) {
      debugPrint('시간표 선택을 저장하지 못했습니다: $e');
    }
  }
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
  bool _restoring = false; // 저장된 선택을 기기에서 읽는 중인지

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    // 토/일요일에는 다음 주 시간표를 보여줌
    final shift = n.weekday >= DateTime.saturday ? 7 : 0;
    _monday = DateTime(n.year, n.month, n.day - (n.weekday - 1) + shift);

    // 화면을 나갔다 돌아왔을 때 이전 선택(학교·학급·시간표)을 복원
    if (_SavedSelection.ready) {
      _applySaved(); // 이미 메모리에 있으면 깜빡임 없이 바로 복원
      // 첫 화면이 그려진 뒤에 부족한 부분(학급 목록/시간표)을 불러옴
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _continueAfterRestore();
      });
    } else {
      _restoring = true;
      _restoreFromDisk();
    }
  }

  Future<void> _restoreFromDisk() async {
    await _SavedSelection.loadFromDisk();
    if (!mounted) return;
    setState(() {
      _applySaved();
      _restoring = false;
    });
    _continueAfterRestore();
  }

  // 저장된 값을 화면 상태에 반영 (setState 없이 값만 채움)
  void _applySaved() {
    final school = _SavedSelection.school;
    if (school == null) return;
    _school = school;
    _grade = _SavedSelection.grade;
    _className = _SavedSelection.className;
    _classesByGrade = _SavedSelection.classesByGrade ?? {};
    // 같은 주의 시간표를 이미 불러온 적이 있으면 그대로 사용
    if (_SavedSelection.timetableMonday == _monday) {
      _timetable = _SavedSelection.timetable;
    }
  }

  // 복원 후 비어 있는 부분(학급 목록, 시간표)만 다시 불러옴
  Future<void> _continueAfterRestore() async {
    final school = _school;
    if (school == null) return;
    if (_classesByGrade.isEmpty) {
      setState(() => _classLoading = true);
      await _loadClasses(school);
      if (!mounted) return;
    }
    if (_grade != null && _className != null && _timetable == null) {
      _loadTimetable();
    }
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
    _SavedSelection.school = school;
    _SavedSelection.grade = null;
    _SavedSelection.className = null;
    _SavedSelection.classesByGrade = null;
    _SavedSelection.timetable = null;
    _SavedSelection.timetableMonday = null;
    _SavedSelection.saveToDisk();
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
      _SavedSelection.classesByGrade = _classesByGrade;
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
    _SavedSelection.grade = _grade;
    _SavedSelection.className = _className;
    _SavedSelection.saveToDisk();
    _loadTimetable();
  }

  void _onClassChanged(String? c) {
    setState(() => _className = c);
    _SavedSelection.className = _className;
    _SavedSelection.saveToDisk();
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
      _SavedSelection.timetable = data;
      _SavedSelection.timetableMonday = _monday;
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
        body: _restoring
            ? const Center(child: CircularProgressIndicator())
            : _searching
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