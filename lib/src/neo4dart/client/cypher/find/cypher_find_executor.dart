part of neo4dart;

class CypherFindExecutor extends CypherExecutor {

  final _logger = new Logger("CypherFindExecutor");

  CypherFindExecutor() {
    client = new http.Client();
  }

  CypherFindExecutor.withClient(client) : super.withClient(client);

  Future findNodesAndRelations(Iterable<int> ids, Type type, int length) {
    return executeCypher(new CypherFindBuilder().buildQueryToRetrieveAllRelatedNodesAndRelationships(ids, type, maxLength: length));
  }
  Future findAllNodesAndRelations(Iterable<int> ids, Type type) {
    return executeCypher(new CypherFindBuilder().buildQueryToRetrieveAllRelatedNodesAndRelationships(ids, type, limit: 1));
  }

}
