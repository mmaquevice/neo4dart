part of neo4dart;

class CypherFindBuilder {

  final _logger = new Logger("CypherFindBuilder");

  String buildQueryToFindNodesAndRelations(Type type, {Map properties, int maxLength : 100, int limit : 100}) {

    List<String> propertiesInline = new List();
    if (properties != null && !properties.isEmpty) {
      for (String key in properties.keys) {
        propertiesInline.add("$key: {$key}");
      }
    }

    String query =
      '''
    MATCH path=(p:$type ${propertiesInline.isEmpty ? '': "{${propertiesInline.join(', ')}}"})-[*..$maxLength]->()
    WITH DISTINCT(path) as path
    RETURN 'path' as rowType,
           [n in nodes(path) | ID(n)] as nodeIds,
           [n in nodes(path)] as nodes,
           [n in nodes(path) | labels(n)] as labels,
           [r in  relationships(path) | ID(r)] as relationshipIds,
           [r in  relationships(path) | type(r)] as relationshipTypes,
           [r in  relationships(path)] as relationships
    ORDER BY length(path) DESC
    LIMIT $limit
    UNION ALL
    MATCH (n:$type ${propertiesInline.isEmpty ? '': "{${propertiesInline.join(', ')}}"})
    RETURN  'node' as rowType,
            ID(n) as nodeIds,
            n as nodes,
            labels(n) as labels,
            '' as relationshipIds,
            '' as relationshipTypes,
            '' as relationships;
    ''';

    return query;
  }

  String buildQueryToFindNodesAndRelationsByIds(Iterable<int> nodeIds, Type type, {int maxLength : 100, int limit : 100}) {

    if (nodeIds == null || nodeIds.isEmpty) {
      throw 'Query cannot be built : NodeIds is empty.';
    }

    String query =
    '''
    MATCH path=(p:$type)-[*..$maxLength]->()
    WHERE ID(p) in [${nodeIds.join(',')}]
    WITH DISTINCT(path) as path
    RETURN 'path' as rowType,
           [n in nodes(path) | ID(n)] as nodeIds,
           [n in nodes(path)] as nodes,
           [n in nodes(path) | labels(n)] as labels,
           [r in  relationships(path) | ID(r)] as relationshipIds,
           [r in  relationships(path) | type(r)] as relationshipTypes,
           [r in  relationships(path)] as relationships
    ORDER BY length(path) DESC
    LIMIT $limit
    UNION ALL
    MATCH (n:$type)
    WHERE ID(n) in [${nodeIds.join(',')}]
    RETURN  'node' as rowType,
            ID(n) as nodeIds,
            n as nodes,
            labels(n) as labels,
            '' as relationshipIds,
            '' as relationshipTypes,
            '' as relationships;
    ''';

    return query;
  }
}
