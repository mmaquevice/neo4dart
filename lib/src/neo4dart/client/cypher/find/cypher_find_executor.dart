part of neo4dart;

class CypherFindExecutor extends CypherExecutor {

  final _logger = new Logger("CypherFindExecutor");

  CypherFindExecutor() {
    client = new http.Client();
  }

  CypherFindExecutor.withClient(client) : super.withClient(client);

  Future findAllNodeAndRelationIds(Iterable<int> ids, Type type) {
    return executeCypher(new CypherFindBuilder().buildQueryToRetrieveAllRelatedNodeAndRelationshipIds(ids, type));
  }

  Future findAllNodesAndRelations(Iterable<int> ids, Type type) {
    return executeCypher(new CypherFindBuilder().buildQueryToRetrieveAllRelatedNodesAndRelationships(ids, type));
  }

}
