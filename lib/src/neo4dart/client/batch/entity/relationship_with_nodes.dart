part of neo4dart;

class RelationshipWithNodes {

  Node startNode;
  Relationship relationship;
  Node endNode;

  Relation initialRelationship;

  RelationshipWithNodes(this.startNode, this.relationship, this.endNode, {this.initialRelationship});
}
