part of neo4dart;

class CypherFindExecutor extends CypherExecutor {

  final _logger = new Logger("CypherFindExecutor");

  CypherFindExecutor() {
    client = new http.Client();
  }

  CypherFindExecutor.withClient(client) : super.withClient(client);

  Future findNodesAndRelationsByIds(Iterable<int> ids, Type type, {int nbTransitiveRelations}) {

    String query = "";
    if(nbTransitiveRelations != null) {
      query = new CypherFindBuilder().buildQueryToFindNodesAndRelationsByIds(ids, type, maxLength: nbTransitiveRelations);
    } else {
      query = new CypherFindBuilder().buildQueryToFindNodesAndRelationsByIds(ids, type, limit: 1);
    }

    return executeCypher(query);
  }

  Future findNodesAndRelations(Type type, {Map properties, int nbTransitiveRelations}) {
    String query = "";
    if(nbTransitiveRelations != null) {
      query = new CypherFindBuilder().buildQueryToFindNodesAndRelations(type, properties: properties, maxLength: nbTransitiveRelations);
    } else {
      query = new CypherFindBuilder().buildQueryToFindNodesAndRelations(type, properties: properties, limit: 1);
    }

    return executeCypher(query);
  }
}
