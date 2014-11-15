part of neo4dart;

class TokenInsertExecutor extends BatchExecutor {

  final _logger = new Logger("TokenInsertExecutor");

  BatchInterpreter _interpreter = new BatchInterpreter();

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

    List<AroundNodeResponse> aroundNodeResponses = _interpreter.convertResponse(response);

    Map<int, int> neoIdByRequestId = new Map();
    aroundNodeResponses.forEach((r) {
      if(r.node != null) {
        neoIdByRequestId[r.node.requestId] = r.node.idNode;
      }

      if(r.relations != null) {
        r.relations.forEach((rel) {
          neoIdByRequestId[rel.requestId] = rel.idRelation;
        });
      }
    });

    batchTokens.forEach((token) {
      if (neoIdByRequestId.containsKey(token.id)) {
        if (token.neoEntity != null) {
          token.neoEntity.id = neoIdByRequestId[token.id];
          _logger.info('Matching ${token.id} to ${token.neoEntity.id}.');
        }
      }
    });

    return true;
  }
}
