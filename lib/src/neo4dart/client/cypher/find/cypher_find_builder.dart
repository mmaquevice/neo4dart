part of neo4dart;

class CypherFindBuilder {

  final _logger = new Logger("CypherFindBuilder");

  String buildQueryToRetrieveAllRelatedNodeAndRelationshipIds(Iterable<int> nodeIds, Type type) {

    if(nodeIds == null || nodeIds.isEmpty) {
      throw 'Query cannot be built : NodeIds is empty.';
    }

    String query = "MATCH path=(p:$type)-[*..100]->() WHERE ID(p) in [${nodeIds.join(',')}] RETURN [n in nodes(path) | ID(n)] as nodeIds, [r in  relationships(path) | ID(r)] as relationshipIds";
    return query;
  }

  String buildQueryToRetrieveAllRelatedNodesAndRelationships(Iterable<int> nodeIds, Type type) {

    if(nodeIds == null || nodeIds.isEmpty) {
      throw 'Query cannot be built : NodeIds is empty.';
    }

    String query =
    '''
    MATCH path=(p:$type)-[*..100]->()
    WHERE ID(p) in [${nodeIds.join(',')}]
    WITH DISTINCT(path) as path
    RETURN [n in nodes(path) | ID(n)] as nodeIds,
           [n in nodes(path)] as nodes,
           [n in nodes(path) | labels(n)] as labels,
           [r in  relationships(path) | ID(r)] as relationshipIds,
           [r in  relationships(path) | type(r)] as relationshipTypes,
           [r in  relationships(path)] as relationships
    ORDER BY length(path) DESC
    ''';

    return query;
  }
}
