part of neo4dart;

class BatchInsertExecutor extends BatchExecutor {

  final _logger = new Logger("TokenInsertExecutor");

  BatchInterpreter _interpreter = new BatchInterpreter();

  BatchInsertExecutor() {
    client = new http.Client();
  }

  BatchInsertExecutor.withClient(client) : super.withClient(client);

  insertNode(var node, {bool inDepth: false}) async {

    BatchInsertBuilder tokenInsertBuilder = new BatchInsertBuilder();
    Set<BatchToken> tokens = tokenInsertBuilder.buildTokens([node], inDepth: inDepth);
    return executeBatch(tokens).then((response) => _addIdToNeoEntities(response, tokens));
  }

  insertNodes(Iterable nodes, {bool inDepth: false}) async {

    BatchInsertBuilder tokenInsertBuilder = new BatchInsertBuilder();
    Set<BatchToken> tokens = tokenInsertBuilder.buildTokens(nodes, inDepth: inDepth);
    return executeBatch(tokens).then((response) => _addIdToNeoEntities(response, tokens));
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
