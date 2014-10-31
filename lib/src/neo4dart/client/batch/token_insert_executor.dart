part of neo4dart;

class TokenInsertExecutor extends NeoClient {

  final _logger = new Logger("TokenInsertExecutor");

  TokenInsertExecutor() {
    client = new http.Client();
  }

  TokenInsertExecutor.withClient(client) : super.withClient(client);

  Future insertNode(Node node, bool inDepth) {

    TokenInsertBuilder tokenInsertBuilder = new TokenInsertBuilder();
    tokenInsertBuilder.addNodeToBatch(node);
    tokenInsertBuilder.addNodeAndRelationsToBatch(node, inDepth);
    tokenInsertBuilder.addNodeAndRelationsViaToBatch(node, inDepth);
    return executeBatch(tokenInsertBuilder.batchTokens).then((response) => _addIdToNeoEntities(response, tokenInsertBuilder.batchTokens));
  }

  Future insertNodes(Iterable<Node> nodes, bool inDepth) {

    TokenInsertBuilder tokenInsertBuilder = new TokenInsertBuilder();
    tokenInsertBuilder.addNodesToBatch(nodes);
    tokenInsertBuilder.addNodesAndRelationsToBatch(nodes, inDepth);
    tokenInsertBuilder.addNodesAndRelationsViaToBatch(nodes, inDepth);
    return executeBatch(tokenInsertBuilder.batchTokens).then((response) => _addIdToNeoEntities(response, tokenInsertBuilder.batchTokens));
  }

  _addIdToNeoEntities(var response, Set<BatchToken> batchTokens) {

    List<ResponseEntity> responseEntities = _convertResponseToEntities(response);
    Map<int, ResponseEntity> responsesById = new Map.fromIterable(responseEntities, key: (k) => k.id, value: (v) => v);

    batchTokens.forEach((token) {
      if (responsesById.containsKey(token.id)) {
        if (token.neoEntity != null) {
          _logger.info(token.neoEntity);
          token.neoEntity.id = responsesById[token.id].neoId;
          _logger.info('Matching ${token.id} to ${token.neoEntity.id}.');
        }
      }
    });

    return true;
  }
}
