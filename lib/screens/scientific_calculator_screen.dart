import 'package:flutter/material.dart';
import '../utils/calc_evaluator.dart';
import '../widgets/ad_banner.dart';

class ScientificCalculatorScreen extends StatefulWidget {
  const ScientificCalculatorScreen({super.key});

  @override
  State<ScientificCalculatorScreen> createState() =>
      _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState
    extends State<ScientificCalculatorScreen> {
  final _eval = CalcEvaluator(isDegree: true);
  String _expr = '';
  String _live = '';       // live result while typing
  bool _isDeg = true;
  bool _justEvaled = false;

  // ── Expression manipulation ───────────────────────────────

  void _append(String s) {
    setState(() {
      if (_justEvaled) {
        // After =: if operator pressed, continue from result; else start fresh
        if (!'+-×÷−^'.contains(s)) _expr = '';
        _justEvaled = false;
      }
      _expr += s;
      _updateLive();
    });
  }

  void _backspace() {
    setState(() {
      if (_expr.isEmpty) return;
      const multi = [
        'sin(', 'cos(', 'tan(', 'ln(', 'log(', '√(', 'asin(', 'acos(', 'atan(',
        '^2', '×', '÷', '−',
      ];
      for (final t in multi) {
        if (_expr.endsWith(t)) {
          _expr = _expr.substring(0, _expr.length - t.length);
          _updateLive();
          return;
        }
      }
      _expr = _expr.substring(0, _expr.length - 1);
      _updateLive();
    });
  }

  void _clear() {
    setState(() {
      _expr = '';
      _live = '';
      _justEvaled = false;
    });
  }

  void _equals() {
    final v = _eval.evaluate(_expr);
    setState(() {
      if (v.isNaN || v.isInfinite) {
        _live = v.isInfinite ? '∞' : 'Error';
        _justEvaled = false;
      } else {
        _expr = formatNumber(v);
        _live = '';
        _justEvaled = true;
      }
    });
  }

  void _toggleDeg() {
    setState(() {
      _isDeg = !_isDeg;
      _eval.isDegree = _isDeg;
      _updateLive();
    });
  }

  void _updateLive() {
    final v = _eval.evaluate(_expr);
    _live = (v.isNaN || _expr.isEmpty) ? '' : formatNumber(v);
  }

  // ── Layout helpers ────────────────────────────────────────

  // 4 cols × 8 rows
  List<List<_Btn>> get _rows => [
    [
      _Btn('sin(', type: _T.sci),
      _Btn('cos(', type: _T.sci),
      _Btn('tan(', type: _T.sci),
      _Btn(_isDeg ? 'DEG' : 'RAD', type: _T.tog),
    ],
    [
      _Btn('ln(',  type: _T.sci),
      _Btn('log(', type: _T.sci),
      _Btn('√(',   type: _T.sci),
      _Btn('x²', insert: '^2', type: _T.sci),
    ],
    [
      _Btn('π',  type: _T.sci),
      _Btn('e',  type: _T.sci),
      _Btn('(',  type: _T.sci),
      _Btn(')',  type: _T.sci),
    ],
    [
      _Btn('AC', type: _T.fn),
      _Btn('⌫',  type: _T.fn),
      _Btn('^',  type: _T.op),
      _Btn('÷',  type: _T.op),
    ],
    [_Btn('7'), _Btn('8'), _Btn('9'), _Btn('×', type: _T.op)],
    [_Btn('4'), _Btn('5'), _Btn('6'), _Btn('−', type: _T.op)],
    [_Btn('1'), _Btn('2'), _Btn('3'), _Btn('+', type: _T.op)],
    [_Btn('%'), _Btn('0'), _Btn('.'), _Btn('=', type: _T.eq)],
  ];

  void _onTap(_Btn btn) {
    switch (btn.type) {
      case _T.fn:
        if (btn.label == 'AC') { _clear(); }
        else { _backspace(); }
      case _T.eq:
        _equals();
      case _T.tog:
        _toggleDeg();
      default:
        _append(btn.insert ?? btn.label);
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: const Text('공학 계산기'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: _ModeChip(isDeg: _isDeg, onTap: _toggleDeg),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _Display(expr: _expr, live: _live, cs: cs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: _rows
                    .map((row) => Expanded(
                          child: Row(
                            children: row
                                .map((b) => Expanded(
                                      child: _buildBtn(context, b),
                                    ))
                                .toList(),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }

  Widget _buildBtn(BuildContext context, _Btn btn) {
    final cs = Theme.of(context).colorScheme;
    final Color bg;
    final Color fg;

    switch (btn.type) {
      case _T.sci:
        bg = cs.secondaryContainer;
        fg = cs.onSecondaryContainer;
      case _T.op:
        bg = cs.tertiaryContainer;
        fg = cs.onTertiaryContainer;
      case _T.eq:
        bg = cs.primary;
        fg = cs.onPrimary;
      case _T.fn:
        bg = cs.surfaceContainerHighest;
        fg = cs.onSurface;
      case _T.tog:
        bg = _isDeg ? cs.primaryContainer : cs.tertiaryContainer;
        fg = _isDeg ? cs.onPrimaryContainer : cs.onTertiaryContainer;
      case _T.num:
        bg = cs.surfaceContainerHigh;
        fg = cs.onSurface;
    }

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onTap(btn),
          child: Center(
            child: Text(
              btn.label,
              style: TextStyle(
                fontSize: btn.type == _T.sci ? 13 : 18,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _Display extends StatelessWidget {
  final String expr;
  final String live;
  final ColorScheme cs;

  const _Display({required this.expr, required this.live, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expression
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              expr.isEmpty ? '0' : expr,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w300,
                color: live.isEmpty ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Live result (shown while typing)
          AnimatedOpacity(
            opacity: live.isEmpty ? 0 : 1,
            duration: const Duration(milliseconds: 150),
            child: Text(
              live.isEmpty ? ' ' : '= $live',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final bool isDeg;
  final VoidCallback onTap;
  const _ModeChip({required this.isDeg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDeg ? cs.primaryContainer : cs.tertiaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isDeg ? 'DEG' : 'RAD',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDeg ? cs.onPrimaryContainer : cs.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}

// ── Button model ──────────────────────────────────────────────

enum _T { num, sci, op, fn, eq, tog }

class _Btn {
  final String label;
  final String? insert; // null means use label
  final _T type;
  const _Btn(this.label, {this.insert, this.type = _T.num});
}
