import 'package:flutter/material.dart';

import 'calculator.dart';

void main() => runApp(const CalculatorApp());

const Color kBackground = Color(0xFF05102B);
const Color kBackgroundTop = Color(0xFF0A1B4A);
const Color kCard = Color(0xFF0F2350);
const Color kNumber = Color(0xFF152C5F);
const Color kFunction = Color(0xFF0C1C42);
const Color kOperator = Color(0xFF1D4ED8);
const Color kAccent = Color(0xFF22D3EE);
const Color kDanger = Color(0xFFEF4444);
const Color kMuted = Color(0xFF8FA6D8);

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ColorScheme.fromSeed(
      seedColor: kAccent,
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'Scientific Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: base.copyWith(
          primary: kAccent,
          surface: kBackground,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: kBackground,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF16295C),
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const List<String> _functionTokens = [
    'sqrt(',
    'sin(',
    'cos(',
    'tan(',
    'log(',
    'ln(',
    'abs(',
  ];

  String _expression = '';
  String _result = '0';
  bool _isError = false;
  bool _degrees = true;

  void _refresh() {
    final expression = _expression.trim();
    if (expression.isEmpty) {
      setState(() {
        _result = '0';
        _isError = false;
      });
      return;
    }
    try {
      final value = ExpressionEvaluator(expression, degrees: _degrees).evaluate();
      setState(() {
        _result = formatNumber(value);
        _isError = false;
      });
    } catch (_) {
      setState(() {
        _result = 'Error';
        _isError = true;
      });
    }
  }

  void _insert(String text) {
    setState(() => _expression += text);
    _refresh();
  }

  void _clear() {
    setState(() {
      _expression = '';
      _result = '0';
      _isError = false;
    });
  }

  void _backspace() {
    if (_expression.isEmpty) return;
    var updated = _expression;
    for (final token in _functionTokens) {
      if (updated.endsWith(token)) {
        updated = updated.substring(0, updated.length - token.length);
        setState(() => _expression = updated);
        _refresh();
        return;
      }
    }
    updated = updated.substring(0, updated.length - 1);
    setState(() => _expression = updated);
    _refresh();
  }

  void _equals() {
    if (_expression.trim().isEmpty || _isError) return;
    setState(() => _expression = _result);
    _refresh();
  }

  String _pretty(String value) => value
      .replaceAll('*', '×')
      .replaceAll('/', '÷')
      .replaceAll('-', '−')
      .replaceAll('sqrt(', '√(');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBackgroundTop, kBackground],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF22D3EE)],
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22D3EE).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calculate_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Scientific Calculator',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    _ModeChip(
                      label: 'DEG',
                      selected: _degrees,
                      onTap: () {
                        setState(() => _degrees = true);
                        _refresh();
                      },
                    ),
                    const SizedBox(width: 6),
                    _ModeChip(
                      label: 'RAD',
                      selected: !_degrees,
                      onTap: () {
                        setState(() => _degrees = false);
                        _refresh();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 24,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            _expression.isEmpty ? ' ' : _pretty(_expression),
                            style: const TextStyle(
                              fontSize: 16,
                              color: kMuted,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _result,
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                            color: _isError ? kDanger : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(child: _buildKeypad()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final rows = <List<Widget>>[
      [
        _fn('sin', () => _insert('sin(')),
        _fn('cos', () => _insert('cos(')),
        _fn('tan', () => _insert('tan(')),
        _fn('ln', () => _insert('ln(')),
        _fn('log', () => _insert('log(')),
      ],
      [
        _fn('√', () => _insert('√(')),
        _fn('x²', () => _insert('^2')),
        _fn('^', () => _insert('^')),
        _fn('(', () => _insert('(')),
        _fn(')', () => _insert(')')),
      ],
      [
        _num('7'),
        _num('8'),
        _num('9'),
        _op('÷', () => _insert('/')),
        _special('AC', kDanger, Colors.white, _clear),
      ],
      [
        _num('4'),
        _num('5'),
        _num('6'),
        _op('×', () => _insert('*')),
        _special('⌫', kFunction, kMuted, _backspace, icon: Icons.backspace_rounded),
      ],
      [
        _num('1'),
        _num('2'),
        _num('3'),
        _op('−', () => _insert('-')),
        _fn('%', () => _insert('%')),
      ],
      [
        _num('0'),
        _num('.'),
        _fn('π', () => _insert('π')),
        _op('+', () => _insert('+')),
        _special('=', kAccent, kBackground, _equals),
      ],
    ];

    return Column(
      children: [
        for (final row in rows)
          Expanded(
            child: Row(
              children: [
                for (final key in row) Expanded(child: key),
              ],
            ),
          ),
      ],
    );
  }

  Widget _num(String label) => _button(
        label: label,
        background: kNumber,
        foreground: Colors.white,
        onTap: () => _insert(label),
        fontSize: 23,
      );

  Widget _fn(String label, VoidCallback onTap) => _button(
        label: label,
        background: kFunction,
        foreground: const Color(0xFFBFD3FF),
        onTap: onTap,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  Widget _op(String label, VoidCallback onTap) => _button(
        label: label,
        background: kOperator,
        foreground: Colors.white,
        onTap: onTap,
        fontSize: 23,
      );

  Widget _special(
    String label,
    Color background,
    Color foreground,
    VoidCallback onTap, {
    IconData? icon,
  }) =>
      _button(
        label: label,
        background: background,
        foreground: foreground,
        onTap: onTap,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        icon: icon,
      );

  Widget _button({
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: icon != null
                ? Icon(icon, size: 21, color: foreground)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: foreground,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? kAccent : kCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: selected ? kBackground : kMuted,
          ),
        ),
      ),
    );
  }
}
