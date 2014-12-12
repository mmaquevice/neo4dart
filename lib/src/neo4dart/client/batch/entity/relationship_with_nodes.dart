part of neo4dart;

class RelationshipWithNodes {

  dynamic startNode;
  Relationship relationship;
  dynamic endNode;

  dynamic initialRelationship;

  RelationshipWithNodes(this.startNode, this.relationship, this.endNode, {this.initialRelationship});
}
