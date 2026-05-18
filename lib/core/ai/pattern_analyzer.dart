import '../../features/record/domain/record.dart';

class PatternAnalyzer {
  static const _minDataPoints = 3;
  static const _timeWindowHours = 2;
  static const _lookbackDays = 30;

  String buildPrompt(List<Record> records, DateTime now) {
    final cutoff = now.subtract(const Duration(days: _lookbackDays));
    final recent = records.where((r) => r.recordedAt.isAfter(cutoff)).toList();

    final inWindow = recent.where((r) {
      final diff = (r.recordedAt.hour - now.hour).abs();
      return diff <= _timeWindowHours;
    }).toList();

    if (inWindow.length < _minDataPoints) return '';

    final freq = <String, int>{};
    for (final r in inWindow) {
      final key = '${r.category}:::${r.value}';
      freq[key] = (freq[key] ?? 0) + 1;
    }

    final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(3).map((e) {
      final parts = e.key.split(':::');
      return '${parts[0]} - ${parts[1]} (${e.value}회)';
    }).join('\n');

    return '''현재 시각: ${now.hour}시 ${now.minute}분
최근 $_lookbackDays일 이 시간대 기록 패턴:
$top

위 패턴을 바탕으로 지금 가장 가능성 높은 기록 하나를 제안해주세요.
반드시 다음 JSON 형식만 출력하세요: {"category": "카테고리명", "value": "값"}
카테고리는 반드시 다음 중 하나: 지출, 운동, 식단, 수면, 메모''';
  }
}
