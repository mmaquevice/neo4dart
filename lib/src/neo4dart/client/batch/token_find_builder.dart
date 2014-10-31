part of neo4dart;

class TokenFindBuilder {

  final _logger = new Logger("TokenFindBuilder");

  Set<BatchToken> addNodeToBatch(int nodeId) {
    return new Set.from([new BatchToken("GET", "/node/${nodeId}", null),
                         new BatchToken("GET", "/node/${nodeId}/labels", null)]) ;
  }

  Set<BatchToken> addNodesToBatch(Iterable<int> nodeIds) {
    Set<BatchToken> tokens = new Set();
    nodeIds.forEach((id) => tokens.addAll(addNodeToBatch(id)));
    return tokens;
  }

  BatchToken addRelationsToBatch(int nodeId) {
    return new BatchToken("GET", "/node/${nodeId}/relationships/all", null);
  }
}
