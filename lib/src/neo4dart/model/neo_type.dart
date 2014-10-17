part of neo4dart;

// TODO : mma - until Dart has enum...
class NeoType {

  final String _value;

  const NeoType._internal(this._value);

  static const NODE = const NeoType._internal('NODE');
  static const RELATIONSHIP = const NeoType._internal('RELATIONSHIP');
  static const LABEL = const NeoType._internal('LABEL');

  toString() => 'NeoType.$_value';
}
