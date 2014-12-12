part of neo4dart;

class BatchUpdateBuilder {

  final _logger = new Logger("BatchUpdateBuilder");

  BatchToken createNodeToken(var node) {
    return new BatchToken("PUT", "/node/${node.id}/properties", findFieldsAnnotatedValueByKey(node, Data));
  }

  Set<BatchToken> createNodeTokens(Iterable nodes) {
    Set<BatchToken> tokens = new Set();
    nodes.forEach((node) => tokens.add(createNodeToken(node)));
    return tokens;
  }

  BatchToken createRelationToken(var relation) {
    return new BatchToken("PUT", "/relationship/${relation.id}/properties", findFieldsAnnotatedValueByKey(relation, Data));
  }

  Set<BatchToken> createRelationTokens(Iterable relations) {
    Set<BatchToken> tokens = new Set();
    relations.forEach((relation) => tokens.add(createRelationToken(relation)));
    return tokens;
  }
}
