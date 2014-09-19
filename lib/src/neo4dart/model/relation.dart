part of neo4dart;

class Relation {

  Node startNode;
  Node endNode;

  Relation(this.startNode, this.endNode);

  Map toJson();
}
