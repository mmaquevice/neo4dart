part of neo4dart;

class CypherFindBuilder {

  final _logger = new Logger("CypherFindBuilder");

  String buildQueryToRetrieveAllRelatedNodeAndRelationshipIds(Iterable<int> nodeIds, Type type) {

    if(nodeIds == null || nodeIds.isEmpty) {
      throw 'Query cannot be built : NodeIds is empty.';
    }

    String query = "MATCH path=(p:$type)-[*..100]->() WHERE ID(p) in [${nodeIds.join(',')}] RETURN [n in nodes(path) | ID(n)] , [r in  relationships(path) | ID(r)]";
    return query;
  }

}
