part of neo4dart;

class BatchFindBuilder {

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

  Set<BatchToken> addRelationsToBatch(Iterable<int> relationIds) {
    Set<BatchToken> tokens = new Set();
    relationIds.forEach((id) => tokens.add(new BatchToken("GET", "/relationship/${id}", null)));
    return tokens;
  }

  Set<BatchToken> addRelationsToBatchFromNodes(Iterable<int> nodeIds) {
    Set<BatchToken> tokens = new Set();
    nodeIds.forEach((id) => tokens.add(new BatchToken("GET", "/node/${id}/relationships/all", null)));
    return tokens;
  }
}
