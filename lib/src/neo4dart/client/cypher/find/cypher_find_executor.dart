part of neo4dart;

class CypherFindExecutor extends CypherExecutor {

  final _logger = new Logger("CypherFindExecutor");

  Future findAllNodeAndRelationIds(Iterable<int> ids, Type type) {
    return executeCypher(new CypherFindBuilder().buildQueryToRetrieveAllRelatedNodeAndRelationshipIds(ids, type));
  }

}
