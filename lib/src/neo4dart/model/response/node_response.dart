part of neo4dart;

class NodeResponse extends NeoResponse {

  int idNode;
  Map data;

  NodeResponse(this.idNode, this.data, {int requestId}) : super(requestId: requestId);
}
