import 'package:flutter/material.dart';
import '../widgets/ad_banner.dart';

enum _DateMode { diff, dday, add }

class DateCalculatorScreen extends StatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen> {
  _DateMode _mode = _DateMode.diff;

  // Diff
  DateTime _diffFrom = DateTime.now();
  DateTime _diffTo = DateTime.now().add(const Duration(days: 30));

  // D-Day
  DateTime _ddayTarget = DateTime.now().add(const Duration(days: 100));

  // Add
  DateTime _addBase = DateTime.now();
  int _addDays = 0;
  int _addMonths = 0;
  int _addYears = 0;
  bool _addNegative = false;

  String _fmt(DateTime d) =>
      '${d.year}년 ${d.month.toString().padLeft(2, '0')}월 ${d.day.toString().padLeft(2, '0')}일';

  String _weekday(DateTime d) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return '${days[d.weekday - 1]}요일';
  }

  Future<void> _pickDate(DateTime initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  // ─── Diff view ────────────────────────────────────────────
  Widget _diffView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final diff = _diffTo.difference(_diffFrom);
    final days = diff.inDays.abs();
    final months = _monthsBetween(_diffFrom, _diffTo).abs();
    final years = (_diffTo.year - _diffFrom.year).abs();

    return Column(
      children: [
        _DateTile('시작일', _diffFrom, cs,
            onTap: () => _pickDate(_diffFrom, (d) => setState(() => _diffFrom = d))),
        const SizedBox(height: 12),
        _DateTile('종료일', _diffTo, cs,
            onTap: () => _pickDate(_diffTo, (d) => setState(() => _diffTo = d))),
        const SizedBox(height: 20),
        _CardResult(children: [
          _Row('총 일수', '$days 일', cs, highlight: true),
          const Divider(),
          _Row('약', '$months 개월 / $years 년', cs),
        ]),
      ],
    );
  }

  // ─── D-Day view ───────────────────────────────────────────
  Widget _ddayView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(_ddayTarget.year, _ddayTarget.month, _ddayTarget.day);
    final diff = target.difference(today).inDays;
    final label = diff > 0 ? 'D - $diff' : diff == 0 ? 'D - Day!' : 'D + ${diff.abs()}';

    return Column(
      children: [
        _DateTile('목표 날짜', _ddayTarget, cs,
            onTap: () => _pickDate(_ddayTarget, (d) => setState(() => _ddayTarget = d))),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(label, style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: cs.onPrimaryContainer,
              )),
              const SizedBox(height: 8),
              Text(_fmt(_ddayTarget), style: TextStyle(color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
              Text(_weekday(_ddayTarget), style: TextStyle(color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Add view ─────────────────────────────────────────────
  Widget _addView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    DateTime result = _addBase;
    try {
      final sign = _addNegative ? -1 : 1;
      result = DateTime(
        result.year + sign * _addYears,
        result.month + sign * _addMonths,
        result.day + sign * _addDays,
      );
    } catch (_) {}

    return Column(
      children: [
        _DateTile('기준 날짜', _addBase, cs,
            onTap: () => _pickDate(_addBase, (d) => setState(() => _addBase = d))),
        const SizedBox(height: 16),
        Row(children: [
          _expanded(context, '년', _addYears, (v) => setState(() => _addYears = v)),
          const SizedBox(width: 8),
          _expanded(context, '개월', _addMonths, (v) => setState(() => _addMonths = v)),
          const SizedBox(width: 8),
          _expanded(context, '일', _addDays, (v) => setState(() => _addDays = v)),
        ]),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('계산 방향'),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('+ 더하기'),
              selected: !_addNegative,
              onSelected: (_) => setState(() => _addNegative = false),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('− 빼기'),
              selected: _addNegative,
              onSelected: (_) => setState(() => _addNegative = true),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _CardResult(children: [
          _Row('결과 날짜', _fmt(result), cs, highlight: true),
          _Row('요일', _weekday(result), cs),
        ]),
      ],
    );
  }

  Widget _expanded(BuildContext context, String label, int value, ValueChanged<int> onChanged) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHigh,
                  minimumSize: const Size(36, 36),
                ),
              ),
              const SizedBox(width: 8),
              Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => onChanged(value + 1),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHigh,
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _monthsBetween(DateTime a, DateTime b) =>
      (b.year - a.year) * 12 + b.month - a.month;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const tabs = [
      (Icons.date_range_rounded, '날짜 차이'),
      (Icons.flag_rounded, 'D-Day'),
      (Icons.add_circle_outline_rounded, '날짜 더하기'),
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: const Text('날짜 계산기'),
      ),
      body: Column(
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final mode = _DateMode.values[i];
                final sel = _mode == mode;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: sel ? cs.primaryContainer : cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _mode = mode),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Icon(tabs[i].$1, size: 18,
                                color: sel ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                              const SizedBox(height: 2),
                              Text(tabs[i].$2, style: TextStyle(
                                fontSize: 11,
                                color: sel ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Builder(builder: (ctx) {
                switch (_mode) {
                  case _DateMode.diff:  return _diffView(ctx);
                  case _DateMode.dday: return _ddayView(ctx);
                  case _DateMode.add:  return _addView(ctx);
                }
              }),
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}

// ─── Shared helpers ─────────────────────────────────────────
class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final ColorScheme cs;
  final VoidCallback onTap;
  const _DateTile(this.label, this.date, this.cs, {required this.onTap});

  String _fmt(DateTime d) =>
      '${d.year}년 ${d.month.toString().padLeft(2, '0')}월 ${d.day.toString().padLeft(2, '0')}일';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              Text(_fmt(date), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            ]),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _CardResult extends StatelessWidget {
  final List<Widget> children;
  const _CardResult({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final ColorScheme cs;
  final bool highlight;
  const _Row(this.label, this.value, this.cs, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: highlight ? 15 : 14)),
          Text(value, style: TextStyle(
            color: highlight ? cs.primary : cs.onSurface,
            fontSize: highlight ? 20 : 16,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          )),
        ],
      ),
    );
  }
}
