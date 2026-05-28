import 'dart:math' as math;

/// Recursive-descent expression evaluator.
/// Supports: +−×÷^, sin/cos/tan/asin/acos/atan/ln/log/sqrt/abs,
/// constants π and e, parentheses, unary minus.
/// Degree mode applies to trig functions only.
class CalcEvaluator {
  late String _s;
  late int _i;
  bool isDegree;

  CalcEvaluator({this.isDegree = true});

  /// Returns [double.nan] on any parse or runtime error.
  double evaluate(String expression) {
    try {
      _s = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-')
          .replaceAll('√(', 'sqrt(')
          .replaceAll('%', '/100')
          .trim();
      _i = 0;
      if (_s.isEmpty) return double.nan;
      final v = _addSub();
      if (_i < _s.length) return double.nan; // leftover unparsed text
      return v;
    } catch (_) {
      return double.nan;
    }
  }

  // ── Grammar (precedence low → high) ─────────────────────────
  // addSub  → mulDiv  (('+' | '-') mulDiv)*
  // mulDiv  → power   (('*' | '/') power)*
  // power   → unary   ('^' unary)?        right-associative
  // unary   → '-' primary | primary
  // primary → '(' addSub ')' | fn '(' addSub ')' | π | e | number

  double _addSub() {
    double v = _mulDiv();
    while (_i < _s.length) {
      if (_s[_i] == '+') { _i++; v += _mulDiv(); }
      else if (_s[_i] == '-') { _i++; v -= _mulDiv(); }
      else { break; }
    }
    return v;
  }

  double _mulDiv() {
    double v = _power();
    while (_i < _s.length) {
      if (_s[_i] == '*') { _i++; v *= _power(); }
      else if (_s[_i] == '/') { _i++; v /= _power(); }
      else { break; }
    }
    return v;
  }

  double _power() {
    final base = _unary();
    if (_i < _s.length && _s[_i] == '^') {
      _i++;
      return math.pow(base, _unary()).toDouble();
    }
    return base;
  }

  double _unary() {
    if (_i < _s.length && _s[_i] == '-') { _i++; return -_primary(); }
    if (_i < _s.length && _s[_i] == '+') { _i++; }
    return _primary();
  }

  double _primary() {
    if (_i >= _s.length) throw const FormatException('Unexpected end');

    // Parenthesised sub-expression
    if (_s[_i] == '(') {
      _i++;
      final v = _addSub();
      if (_i < _s.length && _s[_i] == ')') _i++;
      return v;
    }

    // Named functions – longest names checked first to avoid prefix clashes
    const fns = ['sqrt', 'asin', 'acos', 'atan', 'sin', 'cos', 'tan', 'ln', 'log', 'abs'];
    for (final fn in fns) {
      if (_s.startsWith(fn, _i)) {
        _i += fn.length;
        if (_i < _s.length && _s[_i] == '(') {
          _i++;
          final arg = _addSub();
          if (_i < _s.length && _s[_i] == ')') _i++;
          return _applyFn(fn, arg);
        }
        throw FormatException('Expected ( after $fn');
      }
    }

    // π constant
    if (_s[_i] == 'π') { _i++; return math.pi; }

    // Euler's number – only when not followed by a letter (avoids 'exp' etc.)
    if (_s[_i] == 'e') {
      final nxt = _i + 1;
      if (nxt >= _s.length || !RegExp(r'[a-zA-Z(]').hasMatch(_s[nxt])) {
        _i++;
        return math.e;
      }
    }

    return _number();
  }

  double _number() {
    final start = _i;
    while (_i < _s.length && (_isDigit(_s[_i]) || _s[_i] == '.')) {
      _i++;
    }
    if (_i == start) throw FormatException('Unexpected: "${_s.substring(_i)}"');
    return double.parse(_s.substring(start, _i));
  }

  double _applyFn(String fn, double arg) {
    switch (fn) {
      case 'sin':  return math.sin(_toRad(arg));
      case 'cos':  return math.cos(_toRad(arg));
      case 'tan':  return math.tan(_toRad(arg));
      case 'asin': return _fromRad(math.asin(arg));
      case 'acos': return _fromRad(math.acos(arg));
      case 'atan': return _fromRad(math.atan(arg));
      case 'sqrt': return math.sqrt(arg);
      case 'ln':   return math.log(arg);
      case 'log':  return math.log(arg) / math.ln10;
      case 'abs':  return arg.abs();
      default:     throw FormatException('Unknown fn: $fn');
    }
  }

  double _toRad(double v) => isDegree ? v * math.pi / 180.0 : v;
  double _fromRad(double v) => isDegree ? v * 180.0 / math.pi : v;
  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}

/// Clean number formatter: removes trailing zeros, shows scientific notation
/// for very large/small values.
String formatNumber(double v) {
  if (v.isNaN) return 'Error';
  if (v.isInfinite) return v > 0 ? '∞' : '-∞';

  // Integer: show without decimal point
  if (v == v.truncateToDouble() && v.abs() < 1e15) {
    return v.toInt().toString();
  }

  // 10 significant digits
  final raw = v.toStringAsPrecision(10);

  if (raw.contains('e')) {
    // e.g. "1.234000000e+20" → "1.234e+20"
    final idx = raw.indexOf('e');
    var mantissa = raw.substring(0, idx).replaceAll(RegExp(r'0+$'), '');
    if (mantissa.endsWith('.')) mantissa = mantissa.substring(0, mantissa.length - 1);
    return '$mantissa${raw.substring(idx)}';
  }

  var s = raw.replaceAll(RegExp(r'0+$'), '');
  if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  return s;
}
