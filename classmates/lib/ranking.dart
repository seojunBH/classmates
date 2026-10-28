import 'package:flutter/material.dart';
import 'bottomBar.dart';
import 'package:flutter/services.dart'; // 숫자만 입력받는 필터용
import 'package:url_launcher/url_launcher.dart'; // NEIS 사이트 열기 (pubspec.yaml에 url_launcher 필요)

// ─────────────────────────────────────────────
// 데이터 모델 (이후 백엔드 연동 시 교체)
// ─────────────────────────────────────────────

/// 사용자 프로필 (API/BC 등으로 정보 수정 가능)
class UserProfileData {
  final String studentId;
  final String name;
  final String tier;
  final String? avatarUrl;
  final String? avatarAsset;

  const UserProfileData({
    required this.studentId,
    required this.name,
    required this.tier,
    this.avatarUrl,
    this.avatarAsset,
  });
}

/// 랭킹 기록 한 건 (학번 + 랭킹 점수)
class RankingRecord {
  final String userId;
  final num rankingScore;

  const RankingRecord({
    required this.userId,
    required this.rankingScore,
  });
}

// ─────────────────────────────────────────────
// 색상 / 상수
// ─────────────────────────────────────────────

const Color purple = Color(0xFF7252A5);
const Color palePurple = Color(0xFFF3EEF7);
const Color cardGray = Color(0xFFD9D9D9);
const Color inputGray = Color(0xFFE9E4EC);

// ─────────────────────────────────────────────
// 데이터 불러오기 (서버 연동 자리)
// ─────────────────────────────────────────────

/// 내 프로필을 서버에서 가져오는 함수
/// ★ 백엔드 연결 시 이 함수 안만 실제 API 호출로 교체하면 됩니다.
Future<UserProfileData> fetchMyProfile() async {
  // TODO: 실제 API 호출로 교체 (임시 데이터)
  return const UserProfileData(
    studentId: '20400',
    name: '홍길동',
    tier: '골드',
  );
}

/// 전체 학생의 랭킹 기록(내 기록 포함)을 서버에서 가져오는 함수
/// ★ 백엔드 연결 시 이 함수 안만 실제 API 호출로 교체하면 됩니다.
Future<List<RankingRecord>> fetchRankingRecords() async {
  // TODO: 실제 API 호출로 교체 (지금은 기록이 없으므로 항상 Unranked)
  return const [];
}

/// 상위 몇 %인지 계산 (기록이 없거나 내 기록이 없으면 null)
int? calculateTopPercent({
  required String userId,
  required List<RankingRecord> records,
}) {
  if (records.isEmpty) return null;

  RankingRecord? currentRecord;
  for (final record in records) {
    if (record.userId == userId) {
      currentRecord = record;
      break;
    }
  }

  if (currentRecord == null) return null;

  final usersAhead = records.where(
    (record) => record.rankingScore > currentRecord!.rankingScore,
  ).length;
  final rank = usersAhead + 1;
  final percent = ((rank / records.length) * 100).ceil();

  return percent.clamp(1, 100).toInt();
}

// 티어 이미지: assets/ranks/ 폴더에 png를 추가하고 pubspec.yaml의 assets에 등록해야 표시됩니다.
const Map<String, String> tierImageAssets = {
  '브론즈': 'assets/ranks/bronze.png',
  '실버': 'assets/ranks/silver.png',
  '골드': 'assets/ranks/gold.png',
  '플래티넘': 'assets/ranks/platinum.png',
  '다이아': 'assets/ranks/diamond.png',
  '마스터': 'assets/ranks/master.png',
};

// ─────────────────────────────────────────────
// 성적 랭크 메인 화면
// ─────────────────────────────────────────────

class RankingBoardPage extends StatefulWidget {
  const RankingBoardPage({super.key});

  @override
  State<RankingBoardPage> createState() => _RankingBoardPageState();
}

class _RankingBoardPageState extends State<RankingBoardPage> {
  UserProfileData? _user; // 불러오기 전에는 null
  List<RankingRecord> _rankingRecords = const [];
  bool _isLoading = true; // 처음 불러오는 중인지

  @override
  void initState() {
    super.initState();
    // 화면이 열릴 때 스스로 서버에서 데이터를 가져옴
    _loadData();
  }

  /// 내 정보와 랭킹 기록을 서버에서 불러와 화면에 반영
  /// showLoading: false 이면 기존 화면을 유지한 채 조용히 새로고침 (성적 제출 후 등)
  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final user = await fetchMyProfile();
      final records = await fetchRankingRecords();

      if (!mounted) return; // 불러오는 사이에 화면이 닫혔으면 중단

      setState(() {
        _user = user;
        _rankingRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('랭킹 데이터를 불러오지 못했습니다: $e');
      if (!mounted) return;

      setState(() => _isLoading = false);

      // 이미 보여줄 데이터가 있는 상태에서의 새로고침 실패는 안내만 표시
      if (_user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('랭킹 정보를 새로 불러오지 못했습니다.')),
        );
      }
    }
  }

  int? get _topPercent {
    final user = _user;
    if (user == null) return null;

    return calculateTopPercent(
      userId: user.studentId,
      records: _rankingRecords,
    );
  }

  Future<void> _openScoreRegistration() async {
    final submitted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const ScoreRegistrationPage(),
      ),
    );

    if (!mounted) return;

    if (submitted == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('성적 입력이 완료되었습니다.')),
      );

      // 제출한 성적이 반영된 순위를 다시 불러옴
      await _loadData(showLoading: false);
    }
  }

  void _openTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NeisTutorialPage()),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '랭킹 정보를 불러오지 못했습니다.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _PillButton(label: '다시 시도', onPressed: _loadData),
        ],
      ),
    );
  }

  Widget _buildContent(UserProfileData user) {
    final screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.12),

                  ProfileRankCard(
                    user: user,
                    topPercent: _topPercent,
                  ),

                  SizedBox(height: screenHeight * 0.12),

                  const Text(
                    '성적을 입력하세요.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PillButton(
                    label: '성적 입력',
                    onPressed: _openScoreRegistration,
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    '성적을 확인하려면?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PillButton(
                    label: 'NEIS 튜토리얼',
                    onPressed: _openTutorial,
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('성적 랭크'),
        backgroundColor: const Color.fromARGB(255, 212, 211, 211),
      ),
      bottomNavigationBar: const bottom_bar(),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : user == null
                ? _buildLoadError()
                : _buildContent(user),
      ),
    );
  }
}

/// 프로필 + 티어 + 상위 % 카드
class ProfileRankCard extends StatelessWidget {
  final UserProfileData user;
  final int? topPercent;

  const ProfileRankCard({
    super.key,
    required this.user,
    required this.topPercent,
  });

  Widget _profileFallback() {
    return const CircleAvatar(
      radius: 22,
      backgroundColor: Color(0xFFEBDDFA),
      child: Icon(Icons.person_outline, color: purple, size: 30),
    );
  }

  Widget _buildProfileAvatar() {
    if (user.avatarAsset != null && user.avatarAsset!.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          user.avatarAsset!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _profileFallback(),
        ),
      );
    }

    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          user.avatarUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _profileFallback(),
        ),
      );
    }

    return _profileFallback();
  }

  Widget _buildTierImage() {
    final assetPath = tierImageAssets[user.tier];

    if (assetPath == null) {
      return const Icon(
        Icons.workspace_premium_rounded,
        color: Color(0xFFC4BCCB),
        size: 30,
      );
    }

    return Image.asset(
      assetPath,
      width: 38,
      height: 38,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.workspace_premium_rounded,
        color: Color(0xFFC4BCCB),
        size: 30,
      ),
    );
  }

  // 순위가 있을 때: 티어 이름 (예: 골드)
  Widget _buildTierText() {
    return Text(
      user.tier,
      style: const TextStyle(
        fontSize: 27,
        height: 1.0,
        fontWeight: FontWeight.w900,
        color: Color(0xFFFFD51F),
        shadows: [
          Shadow(
            color: Colors.black38,
            offset: Offset(1, 1),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }

  // 순위가 없을 때: 테두리만 있는 Unranked 글자
  Widget _buildUnrankedText() {
    const baseStyle = TextStyle(
      fontSize: 27,
      height: 1.0,
      fontWeight: FontWeight.w900,
    );

    return Stack(
      children: [
        Text(
          'Unranked',
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2
              ..color = Colors.black,
          ),
        ),
        Text('Unranked', style: baseStyle.copyWith(color: cardGray)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 순위가 없으면(topPercent == null) Unranked 로 표시하고, 퍼센트 자리에는 '랭킹 집계 중' 표시
    final isRanked = topPercent != null;
    final percentText = isRanked
        ? '상위 ${topPercent!.toStringAsFixed(0)}%'
        : '랭킹 집계 중';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardGray,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildProfileAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${user.studentId} ${user.name}',
                  style: const TextStyle(fontSize: 17, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 순위가 있을 때만 티어 이미지 표시 (Unranked일 때는 숨김)
              if (isRanked) ...[
                Container(
                  width: 48,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: _buildTierImage(),
                ),
                const SizedBox(width: 9),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isRanked ? _buildTierText() : _buildUnrankedText(),
                  Text(
                    percentText,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PillButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palePurple,
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: purple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// 뒤로 가기 버튼 (성적 입력 / NEIS 튜토리얼 화면 공통 — 같은 위치, 같은 크기)
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 30,
        minHeight: 38,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 성적 입력 화면
// ─────────────────────────────────────────────

class ScoreRegistrationPage extends StatefulWidget {
  const ScoreRegistrationPage({super.key});

  @override
  State<ScoreRegistrationPage> createState() => _ScoreRegistrationPageState();
}

class _ScoreRegistrationPageState extends State<ScoreRegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ── 시험 선택 (3단계) ──
  // 1칸: 정기고사 / 모의고사
  // 정기고사 → 2칸: 1학기/2학기, 3칸: 중간/기말
  // 모의고사 → 2칸: 시행 월 (3·4·6·7·9·10·11월)
  static const List<String> _examCategories = ['정기고사', '모의고사'];
  static const List<String> _semesters = ['1학기', '2학기'];
  static const List<String> _termTypes = ['중간', '기말'];
  static const List<String> _mockMonths = [
    '3월',
    '4월',
    '6월',
    '7월',
    '9월',
    '10월',
    '11월',
  ];

  String? _examCategory; // 정기고사 / 모의고사
  String? _semester; // 정기고사일 때: 1학기 / 2학기
  String? _termType; // 정기고사일 때: 중간 / 기말
  String? _mockMonth; // 모의고사일 때: 3월 ~ 11월

  bool get _isRegularExam => _examCategory == '정기고사';
  bool get _isMockExam => _examCategory == '모의고사';

  /// 선택이 모두 끝났으면 '1학기 중간' / '6월 모의고사' 형태의 이름을, 아니면 null
  /// ★ 저장 시 이 값(또는 개별 선택값)을 DB/API에 사용하세요.
  String? get _examLabel {
    if (_isRegularExam && _semester != null && _termType != null) {
      return '$_semester $_termType';
    }
    if (_isMockExam && _mockMonth != null) {
      return '$_mockMonth 모의고사';
    }
    return null;
  }

  // 프로젝트/학교에서 사용할 과목 선택지입니다.
  // 사용 중인 과목은 추가 대화상자의 선택지에서 자동으로 제외됩니다.
  static const List<String> _availableSubjects = [
    '국어',
    '수학',
    '영어',
    '한국사',
    '통합사회',
    '통합과학',
    '정보',
    '진로와 직업',
    '문학',
    '독서',
    '화법과 작문',
    '확률과 통계',
    '미적분',
    '경제',
    '사회문화',
    '생활과 윤리',
    '물리학',
    '화학',
    '생명과학',
    '지구과학',
    '일본어',
    '중국어',
    '기타',
  ];

  // 처음 화면에 기본으로 뜨는 과목 (이 순서대로 표시)
  final List<_ScoreEntry> _entries = [
    _ScoreEntry('국어'),
    _ScoreEntry('수학'),
    _ScoreEntry('영어'),
    _ScoreEntry('통합사회'),
    _ScoreEntry('통합과학'),
    _ScoreEntry('한국사'),
  ];

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _addSubject() async {
    final alreadySelected = _entries.map((entry) => entry.subject).toSet();
    final candidates = _availableSubjects
        .where((subject) => !alreadySelected.contains(subject))
        .toList();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('추가할 수 있는 과목이 없습니다.')),
      );
      return;
    }

    final selectedSubject = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('추가할 과목을 선택하세요'),
          children: candidates
              .map(
                (subject) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(dialogContext, subject),
                  child: Text(subject),
                ),
              )
              .toList(),
        );
      },
    );

    if (!mounted || selectedSubject == null) return;

    // 방어 로직: 중복 선택은 UI 선택지 필터링 외에도 한 번 더 차단합니다.
    if (_entries.any((entry) => entry.subject == selectedSubject)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$selectedSubject 과목은 이미 추가되어 있습니다.')),
      );
      return;
    }

    setState(() {
      _entries.add(_ScoreEntry(selectedSubject));
    });
  }

  void _removeSubject(int index) {
    if (_entries.length <= 1) return;

    setState(() {
      final removedEntry = _entries.removeAt(index);
      removedEntry.dispose();
    });
  }

  void _submitScores() {
    final examLabel = _examLabel;
    if (examLabel == null) {
      final message = _examCategory == null
          ? '시험 종류를 선택해 주세요.'
          : _isRegularExam
              ? '학기와 중간/기말을 모두 선택해 주세요.'
              : '모의고사 시행 월을 선택해 주세요.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 현재는 입력 검증과 화면 복귀까지만 수행합니다.
    // 실제 기록 저장 시 시험 선택값(_examCategory/_semester/_termType/_mockMonth)과
    // _entries의 값을 DB/API에 저장하세요.
    final scoreData = <String, int>{};
    for (final entry in _entries) {
      scoreData[entry.subject] = int.parse(entry.scoreController.text.trim());
    }

    debugPrint('시험: $examLabel');
    debugPrint('성적: $scoreData');

    Navigator.pop(context, true);
  }

  /// 시험 선택용 드롭다운 한 칸 (모양은 기존 시험 종류 칸과 동일)
  Widget _buildExamDropdown({
    required Key key,
    required double width,
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        key: key,
        value: value,
        isExpanded: true,
        hint: Text(hint, style: const TextStyle(fontSize: 12)),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: purple, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: purple, width: 1.8),
          ),
        ),
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: Text(option, style: const TextStyle(fontSize: 12)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로 가기 버튼: NEIS 튜토리얼 화면과 같은 위치
              const _BackButton(),
              const SizedBox(height: 14),
              Padding(
                // 기존 입력 영역의 좌우 여백(20)을 유지하기 위한 추가 여백
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 시험 선택: [정기고사/모의고사] + (학기 + 중간/기말 | 시행 월)
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        _buildExamDropdown(
                          key: const ValueKey('exam-category'),
                          width: 110,
                          hint: '시험 종류',
                          value: _examCategory,
                          options: _examCategories,
                          onChanged: (value) {
                            if (value == _examCategory) return;
                            // 종류를 바꾸면 뒤쪽 선택은 모두 초기화
                            setState(() {
                              _examCategory = value;
                              _semester = null;
                              _termType = null;
                              _mockMonth = null;
                            });
                          },
                        ),
                        if (_isRegularExam) ...[
                          _buildExamDropdown(
                            key: const ValueKey('exam-semester'),
                            width: 100,
                            hint: '학기',
                            value: _semester,
                            options: _semesters,
                            onChanged: (value) =>
                                setState(() => _semester = value),
                          ),
                          _buildExamDropdown(
                            key: const ValueKey('exam-term'),
                            width: 100,
                            hint: '중간/기말',
                            value: _termType,
                            options: _termTypes,
                            onChanged: (value) =>
                                setState(() => _termType = value),
                          ),
                        ],
                        if (_isMockExam)
                          _buildExamDropdown(
                            key: const ValueKey('exam-mock-month'),
                            width: 100,
                            hint: '시행 월',
                            value: _mockMonth,
                            options: _mockMonths,
                            onChanged: (value) =>
                                setState(() => _mockMonth = value),
                          ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: List.generate(_entries.length, (index) {
                          final entry = _entries[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      entry.subject,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: _entries.length > 1
                                          ? () => _removeSubject(index)
                                          : null,
                                      tooltip: '과목 삭제',
                                      icon: const Icon(Icons.close, size: 17),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: entry.scoreController,
                                  keyboardType: TextInputType.number, // 숫자 키패드
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly, // 숫자 외 입력 차단
                                    LengthLimitingTextInputFormatter(3), // 최대 3자리 (0~100)
                                  ],
                                  validator: (value) {
                                    final score = int.tryParse((value ?? '').trim());
                                    if (score == null || score < 0 || score > 100) {
                                      return '0~100 사이의 점수를 입력해 주세요.';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: '점수',
                                    hintText: 'Input',
                                    filled: true,
                                    fillColor: inputGray,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    border: const UnderlineInputBorder(),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black38),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: purple,
                                        width: 1.5,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      tooltip: '점수 지우기',
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      onPressed: entry.scoreController.clear,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: _addSubject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF383638),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('과목 추가', style: TextStyle(fontSize: 12)),
                      ),
                    ),

                    const SizedBox(height: 42),

                    Center(
                      child: _PillButton(
                        label: '제출',
                        onPressed: _submitScores,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreEntry {
  final String subject;
  final TextEditingController scoreController = TextEditingController();

  _ScoreEntry(this.subject);

  void dispose() => scoreController.dispose();
}

// ─────────────────────────────────────────────
// NEIS 튜토리얼 화면
// ─────────────────────────────────────────────

/// 튜토리얼 한 단계 (설명 + 이미지 경로)
class _TutorialStep {
  final String text;
  final String? imagePath; // 예: 'assets/neis/step1.png' — null이면 임시 아이콘 표시

  const _TutorialStep({required this.text, this.imagePath});
}

// ★ 튜토리얼 이미지가 준비되면 아래 imagePath에 경로만 넣으면 됩니다.
//   (이미지 파일은 assets/neis/ 등에 넣고 pubspec.yaml의 assets에도 등록해야 합니다.)
//   단계를 늘리거나 줄이려면 이 목록에 항목을 추가/삭제하면 화면에 그대로 반영됩니다.
const List<_TutorialStep> _neisTutorialSteps = [
  _TutorialStep(
    text: 'STEP 1. NEIS에서 성적 조회 메뉴를 찾으세요.',
    imagePath: null, // 예: 'assets/neis/step1.png'
  ),
  _TutorialStep(
    text: 'STEP 2. 확인한 성적을 앱에 입력하세요.',
    imagePath: null, // 예: 'assets/neis/step2.png'
  ),
];

class NeisTutorialPage extends StatelessWidget {
  const NeisTutorialPage({super.key});
  static final Uri _neisUri = Uri.parse('https://www.neis.go.kr/');

  /// NEIS 사이트를 기기의 외부 브라우저로 엽니다.
  Future<void> _openNeis(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      // canLaunchUrl은 Android 11+/iOS에서 설정이 없으면 false를 돌려주므로 쓰지 않고 바로 실행합니다.
      final opened = await launchUrl(
        _neisUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        messenger.showSnackBar(
          const SnackBar(content: Text('NEIS 사이트를 열 수 없습니다.')),
        );
      }
    } catch (e) {
      debugPrint('NEIS 열기 실패: $e');
      messenger.showSnackBar(
        const SnackBar(content: Text('사이트 연결에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackButton(),
              const SizedBox(height: 14),
              // 단계별 이미지 + 설명 (내용은 위쪽 _neisTutorialSteps에서 관리)
              for (int i = 0; i < _neisTutorialSteps.length; i++) ...[
                Center(
                  child: _TutorialIllustration(
                    imagePath: _neisTutorialSteps[i].imagePath,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  _neisTutorialSteps[i].text,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: i == _neisTutorialSteps.length - 1 ? 42 : 18),
              ],
              Center(
                child: _PillButton(
                  label: 'NEIS 이동',
                  onPressed: () => _openNeis(context),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// 튜토리얼 이미지 칸
/// imagePath가 있으면 그 이미지를, 없거나 불러오지 못하면 임시 아이콘을 보여줍니다.
class _TutorialIllustration extends StatelessWidget {
  final String? imagePath;

  const _TutorialIllustration({this.imagePath});

  // 이미지 칸 크기 (튜토리얼 이미지 비율에 맞춰 조절 가능)
  static const double _width = 180;
  static const double _height = 118;

  Widget _placeholder() {
    const iconColor = Color(0xFFC9C1D0);

    return const Stack(
      children: [
        Positioned(
          top: 13,
          left: 70,
          child: Icon(
            Icons.change_history_rounded,
            color: iconColor,
            size: 43,
          ),
        ),
        Positioned(
          left: 34,
          bottom: 22,
          child: Icon(Icons.settings, color: iconColor, size: 36),
        ),
        Positioned(
          right: 34,
          bottom: 19,
          child: Icon(
            Icons.crop_square_rounded,
            color: iconColor,
            size: 43,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = imagePath;

    return Container(
      width: _width,
      height: _height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE6F1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: (path == null || path.isEmpty)
          ? _placeholder()
          : Image.asset(
              path,
              fit: BoxFit.contain,
              errorBuilder: (_, error, __) {
                debugPrint('튜토리얼 이미지를 불러오지 못했습니다: $path ($error)');
                return _placeholder();
              },
            ),
    );
  }
}