import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../record/domain/record.dart';
import '../../record/presentation/record_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(recordListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: '이번 주'), Tab(text: '이번 달')],
        ),
      ),
      body: allAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (all) => TabBarView(
          controller: _tab,
          children: [
            _StatsView(records: all, mode: _StatsMode.week),
            _StatsView(records: all, mode: _StatsMode.month),
          ],
        ),
      ),
    );
  }
}

enum _StatsMode { week, month }

class _StatsView extends StatelessWidget {
  final List<Record> records;
  final _StatsMode mode;
  const _StatsView({required this.records, required this.mode});

  List<Record> get _filtered {
    final now = DateTime.now();
    final DateTime start;
    if (mode == _StatsMode.week) {
      start = now.subtract(Duration(days: now.weekday - 1));
    } else {
      start = DateTime(now.year, now.month, 1);
    }
    final startDay = DateTime(start.year, start.month, start.day);
    return records.where((r) => !r.recordedAt.isBefore(startDay)).toList();
  }

  Map<int, int> _spendingByDay(List<Record> recs) {
    final map = <int, int>{};
    for (final r in recs) {
      if (r.category != '지출') continue;
      final day = r.recordedAt.day;
      map[day] = (map[day] ?? 0) + (int.tryParse(r.value) ?? 0);
    }
    return map;
  }

  Map<String, int> _countByCategory(List<Record> recs) {
    final map = <String, int>{};
    for (final r in recs) {
      map[r.category] = (map[r.category] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final spending = _spendingByDay(filtered);
    final byCategory = _countByCategory(filtered);
    final totalSpend = spending.values.fold(0, (a, b) => a + b);

    if (filtered.isEmpty) {
      return const Center(child: Text('이 기간에 기록이 없습니다'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryRow(
          totalRecords: filtered.length,
          totalSpend: totalSpend,
        ),
        const SizedBox(height: 24),
        if (spending.isNotEmpty) ...[
          Text('지출 현황', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(height: 180, child: _SpendingChart(spending: spending, mode: mode)),
          const SizedBox(height: 24),
        ],
        Text('카테고리별 기록', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...byCategory.entries.map((e) => _CategoryRow(
              category: e.key,
              count: e.value,
              total: filtered.length,
            )),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int totalRecords;
  final int totalSpend;
  const _SummaryRow({required this.totalRecords, required this.totalSpend});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('$totalRecords건',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text('총 기록', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${NumberFormat('#,###').format(totalSpend)}원',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text('총 지출', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpendingChart extends StatelessWidget {
  final Map<int, int> spending;
  final _StatsMode mode;
  const _SpendingChart({required this.spending, required this.mode});

  @override
  Widget build(BuildContext context) {
    final maxY = spending.values.reduce((a, b) => a > b ? a : b).toDouble();
    final bars = spending.entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.toDouble(),
            color: Theme.of(context).colorScheme.primary,
            width: mode == _StatsMode.week ? 24 : 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        barGroups: bars,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text(
                mode == _StatsMode.week
                    ? _weekdayLabel(value.toInt())
                    : '${value.toInt()}',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _weekdayLabel(int day) {
    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    if (day < 1 || day > 7) return '';
    return labels[day - 1];
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final int count;
  final int total;
  const _CategoryRow({required this.category, required this.count, required this.total});

  String get _emoji =>
      kCategories.firstWhere((c) => c.name == category, orElse: () => kCategories.last).emoji;

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category),
                    Text('$count건  ${(ratio * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: ratio,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
