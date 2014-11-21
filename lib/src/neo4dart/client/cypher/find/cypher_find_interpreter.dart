part of neo4dart;

class CypherFindInterpreter {

  final _logger = new Logger("CypherFindInterpreter");

  CypherResponse convertResponse(var cypherResponse) {

    _logger.info("Response status : ${cypherResponse.statusCode}");

    if (cypherResponse.statusCode == 200) {
      _logger.info("Response body : ${cypherResponse.body}");

      var jsonObject = new JsonDecoder().convert(cypherResponse.body);
      List results = jsonObject['results'];
      var result = results.first;

      List columns = result['columns'];
      List rowsJson = result['data'];

      List<Map<String, dynamic>> rows = new List();
      for (var rowJson in rowsJson) {
        Map<String, dynamic> row = new Map();
        int columnIndex = 0;
        for (var elementRow in rowJson['row']) {
          String column = columns.asMap()[columnIndex];
          row[column] = elementRow;
          columnIndex++;
        }
        rows.add(row);
      }
      return new CypherResponse(columns, rows);
    } else {
      _logger.severe('Error requesting neo4j : status ${cypherResponse.statusCode} - ${cypherResponse.body}');
      throw "Error requesting neo4j : status ${cypherResponse.statusCode}";
    }
  }

  Set<dynamic> extractColumnFromResponse(CypherResponse cypherResponse, String column) {

    Set<dynamic> values = new Set();

    for (Map<String, dynamic> row in cypherResponse.rows) {
      if (row[column] == null) {
        throw 'Cypher response - row does not contain column <$column>';
      }

      if (row[column] is Iterable) {
        values.addAll(row[column]);
      } else {
        values.add(row[column]);
      }
    }

    return values;
  }

  List<AroundNodeResponse> convertCypherResponse(CypherResponse cypherResponse) {
    Map<int, AroundNodeResponse> nodesById = extractAroundNodesFromCypherResponse(cypherResponse);
    return new List.from(nodesById.values);
  }

  Map<int, AroundNodeResponse> extractAroundNodesFromCypherResponse(CypherResponse cypherResponse) {

    Map<int, AroundNodeResponse> aroundNodesById = new Map();

    for (Map<String, dynamic> row in cypherResponse.rows) {
      List nodeIds = row["nodeIds"];
      List nodes = row["nodes"];
      var labels = row["labels"];

      var relationshipIds = row["relationshipIds"];
      var relationshipTypes = row["relationshipTypes"];
      var relationships = row["relationships"];

      int nodeIdIndex = 0;
      for (int nodeId in nodeIds) {

        if (!aroundNodesById.containsKey(nodeId)) {
          NodeResponse nodeResponse = new NodeResponse(nodeId, nodes.asMap()[nodeIdIndex]);
          var labelList = labels.asMap()[nodeIdIndex];
          LabelResponse labelResponse = new LabelResponse(nodeId, labelList);
          aroundNodesById[nodeId] = new AroundNodeResponse(labelResponse, nodeResponse, new List());
        }

        if (nodeIdIndex < nodeIds.length - 1) {
          AroundNodeResponse aroundNode = aroundNodesById[nodeId];
          int idRelation = relationshipIds[nodeIdIndex];

          Map relationsById = new Map.fromIterable(aroundNode.relations, key : (k) => k.idRelation, value: (v) => v);
          if (!relationsById.containsKey(idRelation)) {
            int startNode = nodeId;
            int endNode = nodeIds.asMap()[nodeIdIndex + 1];
            String typeRelation = relationshipTypes.asMap()[nodeIdIndex];
            var dataRelation = relationships.asMap()[nodeIdIndex];
            RelationResponse relationResponse = new RelationResponse(idRelation, startNode, endNode, typeRelation, dataRelation);

            aroundNode.relations.add(relationResponse);
          }
        }

        nodeIdIndex++;
      }
    }

    return aroundNodesById;

  }
}
