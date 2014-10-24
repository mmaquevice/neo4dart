part of neo4dart;

abstract class Node extends NeoEntity {

  List<String> labels = new List();

  Map toJson();

  Node() {
    ClassMirror classMirror = reflectClass(this.runtimeType);
    Symbol symbol = classMirror.simpleName;
    String simpleName = MirrorSystem.getName(symbol);
    labels.add(simpleName);
  }
}
