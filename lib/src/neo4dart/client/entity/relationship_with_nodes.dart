part of neo4dart;

class RelationshipWithNodes {

  Node startNode;
  Relationship relationship;
  Node endNode;

  RelationshipWithNodes(this.startNode, this.relationship, this.endNode);

  Map toJson();
}
