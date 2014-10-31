part of neo4dart;

class RelationResponse extends NeoResponse {

  int idRelation;
  int idStartNode;
  int idEndNode;
  String type;
  Map data;

  RelationResponse(this.idRelation, this.idStartNode, this.idEndNode, this.type, this.data, {int requestId}) : super(requestId: requestId);
}
