part of neo4dart;

class AroundNodeResponse {

  LabelResponse label;
  NodeResponse node;
  List<RelationResponse> relations;

  AroundNodeResponse(this.label, this.node, this.relations);
}
