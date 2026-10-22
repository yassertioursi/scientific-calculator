import 'dart:math' as math;

/// Dependency-free scientific expression evaluator.
///
/// Supports +, -, *, /, ^, postfix %, parentheses, unary signs,
/// implicit multiplication (2π, 3(4+1)), constants π and e,
/// and the functions sin, cos, tan, ln, log, sqrt (also written √).
class ExpressionEvaluator {
  ExpressionEvaluator(String input, {this.degrees = true}) : _input = input;

  final String _input;
  final bool degrees;
  int _i = 0;

  double evaluate() {
    final value = _expression();
    _skipSpaces();
    if (_i != _input.length) {
      throw FormatException('Unexpected "${_input[_i]}"');
    }
    if (value.isNaN || value.isInfinite) {
      throw const FormatException('Undefined result');
    }
    return value;
  }

  void _skipSpaces() {
    while (_i < _input.length && _input[_i] == ' ') {
      _i++;
    }
  }

  bool _match(String char) {
    _skipSpaces();
    if (_i < _input.length && _input[_i] == char) {
      _i++;
      return true;
    }
    return false;
  }

  String? get _current {
    _skipSpaces();
    return _i < _input.length ? _input[_i] : null;
  }

  double _expression() {
    var value = _term();
    while (true) {
      _skipSpaces();
      if (_match('+')) {
        value += _term();
      } else if (_match('-')) {
        value -= _term();
      } else {
        break;
      }
    }
    return value;
  }

  double _term() {
    var value = _unary();
    while (true) {
      _skipSpaces();
      if (_match('*')) {
        value *= _unary();
      } else if (_match('/')) {
        value /= _unary();
      } else if (_startsPrimary()) {
        value *= _unary();
      } else {
        break;
      }
    }
    return value;
  }

  bool _startsPrimary() {
    final c = _current;
    if (c == null) return false;
    return c == '(' ||
        c == 'π' ||
        c == '√' ||
        (c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39) ||
        c == '.' ||
        RegExp(r'[a-zA-Z]').hasMatch(c);
  }

  double _unary() {
    _skipSpaces();
    if (_match('-')) return -_unary();
    if (_match('+')) return _unary();
    return _power();
  }

  double _power() {
    final base = _postfix();
    _skipSpaces();
    if (_match('^')) {
      return math.pow(base, _unary()).toDouble();
    }
    return base;
  }

  double _postfix() {
    var value = _primary();
    while (_match('%')) {
      value /= 100;
    }
    return value;
  }

  double _primary() {
    _skipSpaces();
    final c = _current;
    if (c == null) throw const FormatException('Missing value');

    if (c == '(') {
      _i++;
      final value = _expression();
      if (!_match(')')) throw const FormatException('Missing ")"');
      return value;
    }

    if (c == 'π') {
      _i++;
      return math.pi;
    }

    if (c == '√') {
      _i++;
      return math.sqrt(_primary());
    }

    if (c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39 || c == '.') {
      return _number();
    }

    if (RegExp(r'[a-zA-Z]').hasMatch(c)) {
      return _named();
    }

    throw FormatException('Unexpected "$c"');
  }

  double _number() {
    final start = _i;
    var seenDot = false;
    while (_i < _input.length) {
      final c = _input[_i];
      if (c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39) {
        _i++;
      } else if (c == '.' && !seenDot) {
        seenDot = true;
        _i++;
      } else {
        break;
      }
    }
    final text = _input.substring(start, _i);
    final value = double.tryParse(text);
    if (value == null) throw FormatException('Bad number "$text"');
    return value;
  }

  double _named() {
    final start = _i;
    while (_i < _input.length && RegExp(r'[a-zA-Z]').hasMatch(_input[_i])) {
      _i++;
    }
    final name = _input.substring(start, _i).toLowerCase();

    if (name == 'e') return math.e;
    if (name == 'pi') return math.pi;

    if (!_match('(')) {
      throw FormatException('Expected "(" after $name');
    }
    final argument = _expression();
    if (!_match(')')) throw const FormatException('Missing ")"');

    switch (name) {
      case 'sin':
        return math.sin(_toRadians(argument));
      case 'cos':
        return math.cos(_toRadians(argument));
      case 'tan':
        return math.tan(_toRadians(argument));
      case 'ln':
        return math.log(argument);
      case 'log':
        return math.log(argument) / math.ln10;
      case 'sqrt':
        return math.sqrt(argument);
      case 'abs':
        return argument.abs();
      default:
        throw FormatException('Unknown function "$name"');
    }
  }

  double _toRadians(double value) => degrees ? value * math.pi / 180 : value;
}

/// Formats a double the way a calculator display would.
String formatNumber(double value) {
  if (value.isNaN || value.isInfinite) return 'Error';
  if (value == value.roundToDouble() && value.abs() < 1e15) {
    return value.round().toString();
  }
  var text = value.toStringAsPrecision(12);
  if (text.contains('e')) {
    return text;
  }
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    if (text.endsWith('.')) {
      text = text.substring(0, text.length - 1);
    }
  }
  return text;
}
