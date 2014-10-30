part of neo4dart;

class TokenFindBuilder {

  final _logger = new Logger("TokenFindBuilder");

//  Set<BatchToken> batchTokens = new Set();

  Set<BatchToken> addNodeToBatch(int nodeId) {
    return new Set.from([new BatchToken("GET", "/node/${nodeId}", null),
                         new BatchToken("GET", "/node/${nodeId}/labels", null)]) ;
  }



}
