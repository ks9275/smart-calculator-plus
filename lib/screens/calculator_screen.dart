import 'package:flutter/material.dart';
import '../widgets/ad_banner.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double _operand1 = 0;
  String _operator = '';
  bool _shouldReplace = false;

  void _onDigit(String digit) {
    setState(() {
      if (_shouldReplace || _display == '0') {
        _display = digit;
        _shouldReplace = false;
      } else {
        if (_display.length < 15) _display += digit;
      }
    });
  }

  void _onDot() {
    setState(() {
      if (_shouldReplace) {
        _display = '0.';
        _shouldReplace = false;
        return;
      }
      if (!_display.contains('.')) _display += '.';
    });
  }

  void _onOperator(String op) {
    setState(() {
      _operand1 = double.tryParse(_display) ?? 0;
      _operator = op;
      _expression = '${_formatResult(_operand1)} $op';
      _shouldReplace = true;
    });
  }

  void _onEquals() {
    if (_operator.isEmpty) return;
    final operand2 = double.tryParse(_display) ?? 0;
    double result = 0;
    switch (_operator) {
      case '+': result = _operand1 + operand2; break;
      case '−': result = _operand1 - operand2; break;
      case '×': result = _operand1 * operand2; break;
      case '÷':
        result = operand2 != 0 ? _operand1 / operand2 : double.nan;
        break;
    }
    setState(() {
      _expression = '${_formatResult(_operand1)} $_operator ${_formatResult(operand2)} =';
      _display = result.isNaN ? 'Error' : _formatResult(result);
      _operator = '';
      _shouldReplace = true;
    });
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _expression = '';
      _operand1 = 0;
      _operator = '';
      _shouldReplace = false;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_shouldReplace || _display == '0' || _display == 'Error') {
        _display = '0';
        _shouldReplace = false;
        return;
      }
      _display = _display.length > 1 ? _display.substring(0, _display.length - 1) : '0';
    });
  }

  void _onToggleSign() {
    setState(() {
      final v = double.tryParse(_display) ?? 0;
      _display = _formatResult(-v);
    });
  }

  void _onPercent() {
    setState(() {
      final v = double.tryParse(_display) ?? 0;
      _display = _formatResult(v / 100);
    });
  }

  String _formatResult(double v) {
    if (v == v.truncateToDouble()) {
      final i = v.toInt();
      return i.toString();
    }
    String s = v.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: const Text('일반 계산기'),
      ),
      body: Column(
        children: [
          // Display
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: TextStyle(fontSize: 18, color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _display,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Keypad
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  _buildRow(context, [
                    _Btn('AC', _onClear, type: _BtnType.fn),
                    _Btn('+/-', _onToggleSign, type: _BtnType.fn),
                    _Btn('%', _onPercent, type: _BtnType.fn),
                    _Btn('÷', () => _onOperator('÷'), type: _BtnType.op),
                  ]),
                  _buildRow(context, [
                    _Btn('7', () => _onDigit('7')),
                    _Btn('8', () => _onDigit('8')),
                    _Btn('9', () => _onDigit('9')),
                    _Btn('×', () => _onOperator('×'), type: _BtnType.op),
                  ]),
                  _buildRow(context, [
                    _Btn('4', () => _onDigit('4')),
                    _Btn('5', () => _onDigit('5')),
                    _Btn('6', () => _onDigit('6')),
                    _Btn('−', () => _onOperator('−'), type: _BtnType.op),
                  ]),
                  _buildRow(context, [
                    _Btn('1', () => _onDigit('1')),
                    _Btn('2', () => _onDigit('2')),
                    _Btn('3', () => _onDigit('3')),
                    _Btn('+', () => _onOperator('+'), type: _BtnType.op),
                  ]),
                  _buildRow(context, [
                    _Btn('⌫', _onBackspace, type: _BtnType.fn),
                    _Btn('0', () => _onDigit('0')),
                    _Btn('.', _onDot),
                    _Btn('=', _onEquals, type: _BtnType.eq),
                  ]),
                ],
              ),
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<_Btn> btns) {
    return Expanded(
      child: Row(
        children: btns.map((b) => Expanded(child: _buildBtn(context, b))).toList(),
      ),
    );
  }

  Widget _buildBtn(BuildContext context, _Btn btn) {
    final cs = Theme.of(context).colorScheme;
    Color bg, fg;
    switch (btn.type) {
      case _BtnType.fn:
        bg = cs.secondaryContainer;
        fg = cs.onSecondaryContainer;
        break;
      case _BtnType.op:
        bg = cs.tertiaryContainer;
        fg = cs.onTertiaryContainer;
        break;
      case _BtnType.eq:
        bg = cs.primary;
        fg = cs.onPrimary;
        break;
      case _BtnType.num:
        bg = cs.surfaceContainerHigh;
        fg = cs.onSurface;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: btn.onTap,
          child: Center(
            child: Text(
              btn.label,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: fg),
            ),
          ),
        ),
      ),
    );
  }
}

enum _BtnType { num, fn, op, eq }

class _Btn {
  final String label;
  final VoidCallback onTap;
  final _BtnType type;
  const _Btn(this.label, this.onTap, {this.type = _BtnType.num});
}
