part of neo4dart;

class CypherFindBuilder {

  final _logger = new Logger("CypherFindBuilder");

  String buildQueryToRetrieveAllRelatedNodesAndRelationships(Iterable<int> nodeIds, Type type, {int maxLength : 100, int limit : 100}) {

    if(nodeIds == null || nodeIds.isEmpty) {
      throw 'Query cannot be built : NodeIds is empty.';
    }

    String query =
    '''
    MATCH path=(p:$type)-[*..$maxLength]->()
    WHERE ID(p) in [${nodeIds.join(',')}]
    WITH DISTINCT(path) as path
    RETURN [n in nodes(path) | ID(n)] as nodeIds,
           [n in nodes(path)] as nodes,
           [n in nodes(path) | labels(n)] as labels,
           [r in  relationships(path) | ID(r)] as relationshipIds,
           [r in  relationships(path) | type(r)] as relationshipTypes,
           [r in  relationships(path)] as relationships
    ORDER BY length(path) DESC
    LIMIT $limit
    ''';

    return query;
  }
}
