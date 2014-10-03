part of neo4dart;

class Node {
  Map toJson();

  int id;
  Set<String> labels = [];

  Node() {
    ClassMirror classMirror = reflectClass(this.runtimeType);
    Symbol symbol = classMirror.simpleName;
    String simpleName = MirrorSystem.getName(symbol);
    labels.add(simpleName);
  }
}
