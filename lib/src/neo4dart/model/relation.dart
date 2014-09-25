part of neo4dart;

class Relation {

  Node startNode;
  Relationship relationship;
  Node endNode;

  Relation(this.startNode, this.relationship, this.endNode);

  Map toJson();
}
