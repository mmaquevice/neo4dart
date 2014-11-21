part of neo4dart;

class CypherFindExecutor extends CypherExecutor {

  final _logger = new Logger("CypherFindExecutor");

  CypherFindExecutor() {
    client = new http.Client();
  }

  CypherFindExecutor.withClient(client) : super.withClient(client);

  Future findNodesAndRelationsByIds(Iterable<int> ids, Type type, int length) {
    return executeCypher(new CypherFindBuilder().buildQueryToFindNodesAndRelationsByIds(ids, type, maxLength: length));
  }
  Future findAllNodesAndRelationsByIds(Iterable<int> ids, Type type) {
    return executeCypher(new CypherFindBuilder().buildQueryToFindNodesAndRelationsByIds(ids, type, limit: 1));
  }

  Future findNodesAndRelations(Type type, int length, {Map properties}) {
    return executeCypher(new CypherFindBuilder().buildQueryToFindNodesAndRelations(type, properties: properties, maxLength: length));
  }
  // TODO mma - executeCypher and properties...
  Future findAllNodesAndRelations(Type type, {Map properties}) {
    return executeCypher(new CypherFindBuilder().buildQueryToFindNodesAndRelations(type, properties: properties, limit: 1), properties: properties);
  }
}
