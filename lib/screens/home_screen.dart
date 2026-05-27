import 'package:flutter/material.dart';
import '../widgets/ad_banner.dart';
import 'calculator_screen.dart';
import 'unit_converter_screen.dart';
import 'percent_screen.dart';
import 'date_calculator_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _tools = [
    _ToolItem(
      icon: Icons.calculate_rounded,
      label: '일반 계산기',
      subtitle: '사칙연산 · 기본 계산',
      color: Color(0xFF6750A4),
    ),
    _ToolItem(
      icon: Icons.swap_horiz_rounded,
      label: '단위 변환기',
      subtitle: '길이 · 무게 · 온도 · 넓이',
      color: Color(0xFF0061A4),
    ),
    _ToolItem(
      icon: Icons.percent_rounded,
      label: '퍼센트 · 할인 계산기',
      subtitle: '할인율 · 증감율 · 팁 계산',
      color: Color(0xFF006E1C),
    ),
    _ToolItem(
      icon: Icons.calendar_month_rounded,
      label: '날짜 계산기',
      subtitle: 'D-Day · 날짜 차이 · 더하기',
      color: Color(0xFF7D2B00),
    ),
  ];

  void _navigate(BuildContext context, int index) {
    final screens = [
      const CalculatorScreen(),
      const UnitConverterScreen(),
      const PercentScreen(),
      const DateCalculatorScreen(),
    ];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screens[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calculate_rounded, color: cs.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Smart Calculator Plus',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GridView.builder(
                itemCount: _tools.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, i) => _ToolCard(
                  item: _tools[i],
                  onTap: () => _navigate(context, i),
                ),
              ),
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  const _ToolItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });
}

class _ToolCard extends StatelessWidget {
  final _ToolItem item;
  final VoidCallback onTap;
  const _ToolCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = item.color.withValues(alpha: 0.08);
    final iconBg = item.color.withValues(alpha: 0.15);

    return Card(
      color: bg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const Spacer(),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
