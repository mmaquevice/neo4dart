part of neo4dart;

class Node extends NeoEntity {

  Set<String> labels = [];

  Map toJson();

  Node() {
    ClassMirror classMirror = reflectClass(this.runtimeType);
    Symbol symbol = classMirror.simpleName;
    String simpleName = MirrorSystem.getName(symbol);
    labels.add(simpleName);
  }
}
