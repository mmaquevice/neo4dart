part of neo4dart;

class BatchUpdateBuilder {

  final _logger = new Logger("BatchUpdateBuilder");

  BatchToken createNodeToken(Node node) {
    return new BatchToken("PUT", "/node/${node.id}/properties", findFieldsAnnotatedValueByKey(node, Data));
  }

  Set<BatchToken> createNodeTokens(Iterable<Node> nodes) {
    Set<BatchToken> tokens = new Set();
    nodes.forEach((node) => tokens.add(createNodeToken(node)));
    return tokens;
  }

  BatchToken createRelationToken(Relation relation) {
    return new BatchToken("PUT", "/relationship/${relation.id}/properties", relation.toJson());
  }

  Set<BatchToken> createRelationTokens(Iterable<Relation> relations) {
    Set<BatchToken> tokens = new Set();
    relations.forEach((relation) => tokens.add(createRelationToken(relation)));
    return tokens;
  }
}
