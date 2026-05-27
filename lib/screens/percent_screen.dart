import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/ad_banner.dart';

enum _Mode { discount, tipSplit, changeRate, percentOf }

class PercentScreen extends StatefulWidget {
  const PercentScreen({super.key});

  @override
  State<PercentScreen> createState() => _PercentScreenState();
}

class _PercentScreenState extends State<PercentScreen> {
  _Mode _mode = _Mode.discount;

  // Discount
  final _priceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  // Tip & Split
  final _billCtrl = TextEditingController();
  final _tipCtrl = TextEditingController(text: '10');
  final _peopleCtrl = TextEditingController(text: '2');

  // Change rate
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();

  // Percent of
  final _partCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [_priceCtrl, _discountCtrl, _billCtrl, _tipCtrl,
      _peopleCtrl, _oldCtrl, _newCtrl, _partCtrl, _totalCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  // ─── Discount ────────────────────────────────────────────
  Widget _discountView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final rate = double.tryParse(_discountCtrl.text) ?? 0;
    final saved = price * rate / 100;
    final final_ = price - saved;

    return Column(
      children: [
        _Field('원래 가격 (원)', _priceCtrl, '예) 50000'),
        const SizedBox(height: 12),
        _Field('할인율 (%)', _discountCtrl, '예) 20'),
        const SizedBox(height: 20),
        _ResultCard(children: [
          _ResultRow('할인 금액', '${_fmt(saved)} 원', cs),
          const Divider(),
          _ResultRow('최종 가격', '${_fmt(final_)} 원', cs, highlight: true),
        ]),
      ],
    );
  }

  // ─── Tip & Split ─────────────────────────────────────────
  Widget _tipView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bill = double.tryParse(_billCtrl.text) ?? 0;
    final tip = double.tryParse(_tipCtrl.text) ?? 0;
    final people = int.tryParse(_peopleCtrl.text) ?? 1;
    final tipAmt = bill * tip / 100;
    final total = bill + tipAmt;
    final perPerson = people > 0 ? total / people : 0.0;

    return Column(
      children: [
        _Field('금액 (원)', _billCtrl, '예) 35000'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _Field('팁 (%)', _tipCtrl, '예) 10')),
          const SizedBox(width: 12),
          Expanded(child: _Field('인원 수', _peopleCtrl, '예) 3', integer: true)),
        ]),
        const SizedBox(height: 20),
        _ResultCard(children: [
          _ResultRow('팁 금액', '${_fmt(tipAmt)} 원', cs),
          _ResultRow('총 금액', '${_fmt(total)} 원', cs),
          const Divider(),
          _ResultRow('1인당', '${_fmt(perPerson)} 원', cs, highlight: true),
        ]),
      ],
    );
  }

  // ─── Change Rate ──────────────────────────────────────────
  Widget _changeView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final oldV = double.tryParse(_oldCtrl.text) ?? 0;
    final newV = double.tryParse(_newCtrl.text) ?? 0;
    double rate = oldV != 0 ? (newV - oldV) / oldV * 100 : 0;
    final diff = newV - oldV;
    final isIncrease = diff >= 0;

    return Column(
      children: [
        _Field('이전 값', _oldCtrl, '예) 100'),
        const SizedBox(height: 12),
        _Field('현재 값', _newCtrl, '예) 120'),
        const SizedBox(height: 20),
        _ResultCard(children: [
          _ResultRow('변화량', '${isIncrease ? '+' : ''}${_fmt(diff)}', cs),
          const Divider(),
          _ResultRow(
            '변화율',
            '${isIncrease ? '▲' : '▼'} ${_fmt(rate.abs())}%',
            cs,
            highlight: true,
            color: isIncrease ? Colors.green : Colors.red,
          ),
        ]),
      ],
    );
  }

  // ─── Percent Of ───────────────────────────────────────────
  Widget _percentOfView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final part = double.tryParse(_partCtrl.text) ?? 0;
    final total = double.tryParse(_totalCtrl.text) ?? 0;
    final rate = total != 0 ? part / total * 100 : 0.0;

    return Column(
      children: [
        _Field('부분 값', _partCtrl, '예) 30'),
        const SizedBox(height: 12),
        _Field('전체 값', _totalCtrl, '예) 200'),
        const SizedBox(height: 20),
        _ResultCard(children: [
          _ResultRow('${_fmt(part)} / ${_fmt(total)}', '${_fmt(rate)} %', cs, highlight: true),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const tabs = [
      (Icons.local_offer_rounded, '할인'),
      (Icons.restaurant_rounded, '팁/N빵'),
      (Icons.trending_up_rounded, '증감율'),
      (Icons.calculate_rounded, '비율'),
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: const Text('퍼센트 · 할인 계산기'),
      ),
      body: Column(
        children: [
          // Tab row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final mode = _Mode.values[i];
                final selected = _mode == mode;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
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
                                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                              const SizedBox(height: 2),
                              Text(tabs[i].$2, style: TextStyle(
                                fontSize: 11,
                                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
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
                  case _Mode.discount: return _discountView(ctx);
                  case _Mode.tipSplit: return _tipView(ctx);
                  case _Mode.changeRate: return _changeView(ctx);
                  case _Mode.percentOf: return _percentOfView(ctx);
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

// ─── Shared helpers ───────────────────────────────────────────
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final bool integer;
  const _Field(this.label, this.ctrl, this.hint, {this.integer = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: ctrl,
      keyboardType: integer
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(integer ? RegExp(r'[0-9]') : RegExp(r'[0-9.]')),
      ],
      onChanged: (_) => (context as Element).markNeedsBuild(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: cs.surfaceContainerLow,
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final List<Widget> children;
  const _ResultCard({required this.children});

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

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  final bool highlight;
  final Color? color;
  const _ResultRow(this.label, this.value, this.cs,
      {this.highlight = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: highlight ? 16 : 14,
          )),
          Text(value, style: TextStyle(
            color: color ?? (highlight ? cs.primary : cs.onSurface),
            fontSize: highlight ? 22 : 16,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          )),
        ],
      ),
    );
  }
}
