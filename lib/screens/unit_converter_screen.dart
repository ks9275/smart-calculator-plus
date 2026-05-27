import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/ad_banner.dart';

enum _Category { length, weight, temperature, area }

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  _Category _category = _Category.length;
  final _inputCtrl = TextEditingController();
  String _fromUnit = '';
  String _toUnit = '';
  String _result = '';

  static const _units = {
    _Category.length: ['km', 'm', 'cm', 'mm', 'mi', 'yd', 'ft', 'in'],
    _Category.weight: ['kg', 'g', 'mg', 'lb', 'oz', 't'],
    _Category.temperature: ['°C', '°F', 'K'],
    _Category.area: ['km²', 'm²', 'cm²', '평', '坪(tsubo)', 'acre', 'ha'],
  };

  // Conversion to SI base:
  // length → meters, weight → grams, area → m²
  static const _toBase = {
    'km': 1000.0, 'm': 1.0, 'cm': 0.01, 'mm': 0.001,
    'mi': 1609.344, 'yd': 0.9144, 'ft': 0.3048, 'in': 0.0254,
    'kg': 1000.0, 'g': 1.0, 'mg': 0.001,
    'lb': 453.592, 'oz': 28.3495, 't': 1e6,
    'km²': 1e6, 'm²': 1.0, 'cm²': 1e-4,
    '평': 3.30579, '坪(tsubo)': 3.30579, 'acre': 4046.86, 'ha': 10000.0,
  };

  @override
  void initState() {
    super.initState();
    _resetUnits();
  }

  void _resetUnits() {
    final list = _units[_category]!;
    _fromUnit = list[0];
    _toUnit = list[1];
    _result = '';
    _inputCtrl.clear();
  }

  void _convert() {
    final val = double.tryParse(_inputCtrl.text);
    if (val == null) { setState(() => _result = ''); return; }

    double result;
    if (_category == _Category.temperature) {
      result = _convertTemp(val, _fromUnit, _toUnit);
    } else {
      final base = _toBase[_fromUnit]!;
      final target = _toBase[_toUnit]!;
      result = val * base / target;
    }

    setState(() {
      _result = _fmt(result);
    });
  }

  double _convertTemp(double v, String from, String to) {
    double celsius;
    switch (from) {
      case '°C': celsius = v; break;
      case '°F': celsius = (v - 32) * 5 / 9; break;
      case 'K':  celsius = v - 273.15; break;
      default:   celsius = v;
    }
    switch (to) {
      case '°C': return celsius;
      case '°F': return celsius * 9 / 5 + 32;
      case 'K':  return celsius + 273.15;
      default:   return celsius;
    }
  }

  String _fmt(double v) {
    if (v.abs() >= 1e10 || (v.abs() < 1e-4 && v != 0)) {
      return v.toStringAsExponential(4);
    }
    String s = v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    return s;
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final unitList = _units[_category]!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: const Text('단위 변환기'),
      ),
      body: Column(
        children: [
          // Category chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _Category.values.map((c) {
                  final labels = {
                    _Category.length: '📏 길이',
                    _Category.weight: '⚖️ 무게',
                    _Category.temperature: '🌡 온도',
                    _Category.area: '📐 넓이',
                  };
                  final selected = _category == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(labels[c]!),
                      selected: selected,
                      onSelected: (_) {
                        setState(() { _category = c; _resetUnits(); });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Input row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
                          style: tt.headlineSmall,
                          decoration: InputDecoration(
                            labelText: '값 입력',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: cs.surfaceContainerLow,
                          ),
                          onChanged: (_) => _convert(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _UnitDropdown(
                        value: _fromUnit,
                        items: unitList,
                        onChanged: (v) { setState(() { _fromUnit = v!; _convert(); }); },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Swap button
                  Center(
                    child: IconButton.filledTonal(
                      icon: const Icon(Icons.swap_vert_rounded),
                      iconSize: 28,
                      onPressed: () {
                        setState(() {
                          final tmp = _fromUnit;
                          _fromUnit = _toUnit;
                          _toUnit = tmp;
                          _convert();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Result row
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _result.isEmpty ? '—' : _result,
                            style: tt.headlineMedium?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _UnitDropdown(
                          value: _toUnit,
                          items: unitList,
                          onChanged: (v) { setState(() { _toUnit = v!; _convert(); }); },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // All conversions
                  if (_inputCtrl.text.isNotEmpty) _AllConversions(
                    value: double.tryParse(_inputCtrl.text) ?? 0,
                    fromUnit: _fromUnit,
                    category: _category,
                    unitList: unitList,
                    toBase: _toBase,
                    convertTemp: _convertTemp,
                    fmt: _fmt,
                  ),
                ],
              ),
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _UnitDropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(8),
        color: cs.surfaceContainerLow,
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _AllConversions extends StatelessWidget {
  final double value;
  final String fromUnit;
  final _Category category;
  final List<String> unitList;
  final Map<String, double> toBase;
  final double Function(double, String, String) convertTemp;
  final String Function(double) fmt;

  const _AllConversions({
    required this.value, required this.fromUnit, required this.category,
    required this.unitList, required this.toBase,
    required this.convertTemp, required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('전체 변환', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        ...unitList.where((u) => u != fromUnit).map((u) {
          double result;
          if (category == _Category.temperature) {
            result = convertTemp(value, fromUnit, u);
          } else {
            result = value * (toBase[fromUnit] ?? 1) / (toBase[u] ?? 1);
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(u, style: TextStyle(color: cs.onSurfaceVariant)),
                Text(fmt(result), style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
