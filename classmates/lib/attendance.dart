import 'package:flutter/material.dart';
import 'bottomBar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ─────────────────────────────────────────────
// 데이터 모델 (이후 백엔드 연동 시 교체)
// ─────────────────────────────────────────────

/// 입실/퇴실 기록 한 건
class AttendanceEvent {
  final bool isIn; // true: 입실, false: 퇴실
  final int period; // 교시
  final TimeOfDay time; // 정확한 시각
  final bool earlyLeave; // 조퇴 여부 (퇴실일 때만 의미 있음)

  const AttendanceEvent({
    required this.isIn,
    required this.period,
    required this.time,
    this.earlyLeave = false,
  });

  int get minutes => time.hour * 60 + time.minute;

  String get reason {
    final base = '$period교시 ${isIn ? '입실' : '퇴실'}';
    return earlyLeave ? '$base (조퇴)' : base;
  }
}

class Student {
  final String id; // 학번
  final String name;
  final String? profileUrl; // 없으면 기본 인물 아이콘
  final String info;
  bool isPresent; // false = 퇴실 상태(기본), true = 입실 상태
  final Map<DateTime, List<AttendanceEvent>> records = {};

  Student({
    required this.id,
    required this.name,
    this.profileUrl,
    this.info = '',
    this.isPresent = false, // 당일 초기 상태는 퇴실
  });

  String get label => '$id $name';

  List<AttendanceEvent> eventsOf(DateTime day) =>
      records[dateOnly(day)] ?? <AttendanceEvent>[];

  void addEvent(DateTime day, AttendanceEvent e) {
    final list = records.putIfAbsent(dateOnly(day), () => []);
    // 같은 종류(입실/퇴실)이면서 시간이 정확히 같은 기록은 나중에 추가된 것만 남김
    list.removeWhere((old) => old.isIn == e.isIn && old.minutes == e.minutes);
    list.add(e);
    isPresent = e.isIn;
  }
}

/// 날짜/시간 선택 도구를 한국어로 표시 (MaterialApp 설정과 무관하게 동작)
Widget koreanLocalized(BuildContext context, Widget? child) {
  return Localizations.override(
    context: context,
    locale: const Locale('ko', 'KR'),
    delegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    child: child ?? const SizedBox.shrink(),
  );
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String fmtDate(DateTime d) =>
    '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

// 색상
const Color kInColor = Color(0xFF34C759); // 입실 버튼(초록)
const Color kOutColor = Color(0xFFFF3B3B); // 퇴실 버튼(빨강)
const Color kOutCardBg = Color(0xFFFF8F8F); // 퇴실 상태 카드 배경
const Color kInCardBg = Color.fromARGB(255, 217, 217, 217); // 입실 상태 카드 배경
const Color kPurple = Color(0xFF6750A4);
const Color kPurpleLight = Color(0xFFE8DEF8);

// ─────────────────────────────────────────────
// 공통 위젯
// ─────────────────────────────────────────────

/// 프로필 (없으면 기본 인물 모양)
class _Profile extends StatelessWidget {
  final String? url;
  final double radius;

  const _Profile({this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEADDFF),
      backgroundImage: url != null ? NetworkImage(url!) : null,
      onBackgroundImageError: url != null ? (_, __) {} : null,
      child: url == null
          ? Icon(Icons.person_outline, size: radius * 1.3, color: kPurple)
          : null,
    );
  }
}

/// 팝업 공통 틀: 오른쪽 위 X 버튼 포함
class _PopupFrame extends StatelessWidget {
  final Color background;
  final Widget child;

  const _PopupFrame({required this.background, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            child: SingleChildScrollView(child: child),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              customBorder: const CircleBorder(),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: kPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 총 학생 화면
// ─────────────────────────────────────────────

class attendance extends StatefulWidget {
  const attendance({super.key});

  @override
  State<attendance> createState() => _attendanceState();
}

class _attendanceState extends State<attendance> {
  // 임시 학급 데이터 (학급 선택 기능은 아직 없음)
  final List<Student> students = [
    Student(id: '10811', name: '메타몽', info: '임시 인포메이션'),
    Student(id: '10812', name: '피카츄', info: '임시 인포메이션'),
    Student(id: '10813', name: '꼬부기', info: '임시 인포메이션'),
  ];

  Future<void> _openDetail(Student s) async {
    await showDialog(
      context: context,
      builder: (_) => _StudentDetailPopup(student: s),
    );
    setState(() {});
  }

  Future<void> _openForm(Student s, {required bool isIn}) async {
    final result = await showDialog<AttendanceEvent>(
      context: context,
      builder: (_) => _AttendanceFormPopup(student: s, isIn: isIn),
    );
    if (result != null) {
      setState(() => s.addEvent(DateTime.now(), result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('실시간 출결'),
        backgroundColor: const Color.fromARGB(255, 212, 211, 211),
      ),
      bottomNavigationBar: const bottom_bar(),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        itemCount: students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final s = students[i];
          return _StudentCard(
            student: s,
            onTapInfo: () => _openDetail(s),
            onIn: () => _openForm(s, isIn: true),
            onOut: () => _openForm(s, isIn: false),
          );
        },
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTapInfo;
  final VoidCallback onIn;
  final VoidCallback onOut;

  const _StudentCard({
    required this.student,
    required this.onTapInfo,
    required this.onIn,
    required this.onOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: student.isPresent ? kInCardBg : kOutCardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 프로필 + 학번/성명 (누르면 학생별 팝업)
          Expanded(
            child: InkWell(
              onTap: onTapInfo,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  _Profile(url: student.profileUrl, radius: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      student.label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          _StatusButton(label: '입실', color: kInColor, onPressed: onIn),
          const SizedBox(width: 6),
          _StatusButton(label: '퇴실', color: kOutColor, onPressed: onOut),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _StatusButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 34),
        shape: const StadiumBorder(),
      ),
      child: Text(label),
    );
  }
}

// ─────────────────────────────────────────────
// 각 학생별 화면 (팝업)
// ─────────────────────────────────────────────

class _StudentDetailPopup extends StatefulWidget {
  final Student student;

  const _StudentDetailPopup({required this.student});

  @override
  State<_StudentDetailPopup> createState() => _StudentDetailPopupState();
}

class _StudentDetailPopupState extends State<_StudentDetailPopup> {
  DateTime selectedDate = dateOnly(DateTime.now());

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: koreanLocalized,
      helpText: '날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
    );
    if (picked != null) setState(() => selectedDate = dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final events = [...s.eventsOf(selectedDate)]
      ..sort((a, b) => a.minutes.compareTo(b.minutes));

    return _PopupFrame(
      background: s.isPresent ? kInCardBg : kOutCardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 + 학번 성명
          Row(
            children: [
              _Profile(url: s.profileUrl, radius: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  s.label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 인포메이션
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 90),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('INFORMATION',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(s.info),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 날짜별 출석 기록
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('출석 기록',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    TextButton.icon(
                      onPressed: _pickDate,
                      style: TextButton.styleFrom(
                        backgroundColor: kPurpleLight,
                        foregroundColor: Colors.black87,
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: Text(fmtDate(selectedDate)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _AttendanceTimeline(events: events),
                if (events.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(
                      child: Text('해당 날짜의 입·퇴실 기록이 없습니다.',
                          style: TextStyle(color: Colors.black54)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 하루(00:00~24:00) 출석 막대: 입실=초록, 퇴실=빨강
class _AttendanceTimeline extends StatelessWidget {
  final List<AttendanceEvent> events; // 시간순 정렬되어 있어야 함

  const _AttendanceTimeline({required this.events});

  static const int dayMinutes = 24 * 60;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;

      // 구간 계산 (하루 시작은 퇴실 상태)
      final segments = <_Segment>[];
      int cur = 0;
      bool state = false;
      for (final e in events) {
        if (e.minutes > cur) {
          segments.add(_Segment(cur, e.minutes, state));
        }
        cur = e.minutes;
        state = e.isIn;
      }
      if (cur < dayMinutes) segments.add(_Segment(cur, dayMinutes, state));

      final children = <Widget>[];

      // 막대
      for (final seg in segments) {
        children.add(Positioned(
          left: seg.start / dayMinutes * w,
          width: (seg.end - seg.start) / dayMinutes * w,
          top: 0,
          height: 28,
          child: Container(color: seg.isIn ? kInColor : kOutColor),
        ));
      }

      // 경계 지점: 시간 + 교시/사유 (겹치지 않도록 위아래 번갈아 배치)
      for (int i = 0; i < events.length; i++) {
        final e = events[i];
        final x = e.minutes / dayMinutes * w;
        final labelW = 90.0;
        final left = (x - labelW / 2).clamp(0.0, (w - labelW).clamp(0.0, w));
        final top = 34.0 + (i % 2) * 40;

        children.add(Positioned(
          left: x - 0.5,
          top: -4,
          width: 1,
          height: 36 + (i % 2) * 40,
          child: Container(color: Colors.black),
        ));
        children.add(Positioned(
          left: left,
          top: top + (i % 2) * 0,
          width: labelW,
          child: Column(
            children: [
              Text(fmtTime(e.time),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              Text(e.reason,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10)),
            ],
          ),
        ));
      }

      return Column(
        children: [
          SizedBox(
            height: events.length > 1 ? 120 : 80,
            child: Stack(clipBehavior: Clip.none, children: children),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('00:00',
                  style: TextStyle(fontSize: 10, color: Colors.black54)),
              Text('12:00',
                  style: TextStyle(fontSize: 10, color: Colors.black54)),
              Text('24:00',
                  style: TextStyle(fontSize: 10, color: Colors.black54)),
            ],
          ),
        ],
      );
    });
  }
}

class _Segment {
  final int start;
  final int end;
  final bool isIn;
  _Segment(this.start, this.end, this.isIn);
}

// ─────────────────────────────────────────────
// 입실 / 퇴실 입력 폼 (팝업)
// ─────────────────────────────────────────────

class _AttendanceFormPopup extends StatefulWidget {
  final Student student;
  final bool isIn;

  const _AttendanceFormPopup({required this.student, required this.isIn});

  @override
  State<_AttendanceFormPopup> createState() => _AttendanceFormPopupState();
}

class _AttendanceFormPopupState extends State<_AttendanceFormPopup> {
  final TextEditingController _periodController = TextEditingController();
  TimeOfDay? _time;
  bool _earlyLeave = false;
  String? _error;

  @override
  void dispose() {
    _periodController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial, // 시계(다이얼) 형태
      builder: koreanLocalized,
      helpText: '시간 선택',
      cancelText: '취소',
      confirmText: '확인',
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    final period = int.tryParse(_periodController.text.trim());
    if (period == null || period <= 0) {
      setState(() => _error = '교시를 숫자로 입력해주세요.');
      return;
    }
    if (_time == null) {
      setState(() => _error = '시간을 선택해주세요.');
      return;
    }
    Navigator.of(context).pop(AttendanceEvent(
      isIn: widget.isIn,
      period: period,
      time: _time!,
      earlyLeave: !widget.isIn && _earlyLeave,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isIn = widget.isIn;

    return _PopupFrame(
      background: kInCardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.student.label} · ${isIn ? '입실' : '퇴실'} 기록',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 20),

          // 교시 입력 (숫자 키패드)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _periodController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: isIn ? '몇교시에 들어온건가요?' : '몇교시부터 참여하지 않았나요?',
                hintText: '숫자 입력',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 시간 입력 (시간 선택 도구)
          Container(
            color: Colors.white,
            width: double.infinity,
            child: InkWell(
              onTap: _pickTime,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _time == null
                            ? (isIn
                                ? '입실 시간을 정확히 입력하세요'
                                : '몇시부터 참여하지 않았나요? (정확한 시간)')
                            : fmtTime(_time!),
                        style: TextStyle(
                            color: _time == null ? Colors.black54 : null),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 조퇴 체크박스 (퇴실 폼에만)
          if (!isIn) ...[
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: kPurple,
              value: _earlyLeave,
              onChanged: (v) => setState(() => _earlyLeave = v ?? false),
              title: const Text('조퇴인가요?'),
            ),
          ],

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),

          const SizedBox(height: 24),

          // 제출 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPurpleLight,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: Text('위 학생을 이 날짜로 ${isIn ? '입실' : '퇴실'} 기록합니다'),
            ),
          ),
        ],
      ),
    );
  }
}