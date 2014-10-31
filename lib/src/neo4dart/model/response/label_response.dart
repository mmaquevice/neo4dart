part of neo4dart;

class LabelResponse extends NeoResponse {

  int idNode;
  List<String> labels;

  LabelResponse(this.idNode, this.labels, {int requestId}) : super(requestId: requestId);
}
