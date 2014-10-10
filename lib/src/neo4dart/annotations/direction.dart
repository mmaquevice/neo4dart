part of neo4dart;

// TODO : mma - until Dart has enum...
class Direction {

  final _value;

  const Direction._internal(this._value);

  static const OUTGOING = const Direction._internal('OUTGOING');
  static const INGOING = const Direction._internal('INGOING');
  static const BOTH = const Direction._internal('BOTH');

  toString() => 'Direction.$_value';
}
