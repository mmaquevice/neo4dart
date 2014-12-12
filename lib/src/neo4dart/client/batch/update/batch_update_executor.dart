part of neo4dart;

class BatchUpdateExecutor extends BatchExecutor {

  final _logger = new Logger("BatchUpdateExecutor");

  BatchUpdateExecutor() {
    client = new http.Client();
  }

  BatchUpdateExecutor.withClient(client) : super.withClient(client);

  updateNode(var node) async {
    return executeBatch(new Set.from([new BatchUpdateBuilder().createNodeToken(node)])).then((response) {
      _checkResponse(response);
      return node;
    });
  }

  updateNodes(Iterable nodes) async {
    return executeBatch(new BatchUpdateBuilder().createNodeTokens(nodes)).then((response) {
      _checkResponse(response);
      return nodes;
    });
  }

  updateRelation(var relation) async {
    return executeBatch(new Set.from([new BatchUpdateBuilder().createRelationToken(relation)])).then((response) {
      _checkResponse(response);
      return relation;
    });
  }

  updateRelations(Iterable relations) async {
    return executeBatch(new BatchUpdateBuilder().createRelationTokens(relations)).then((response) {
      _checkResponse(response);
      return relations;
    });
  }

  _checkResponse(response) {
    _logger.info("Response status : ${response.statusCode}");

    if (response.statusCode != 200) {
      _logger.severe('Error updating node : neo4j status ${response.statusCode} - ${response.body}');
      throw "Error updating node : neo4j status ${response.statusCode}";
    }

    return response;
  }
}
