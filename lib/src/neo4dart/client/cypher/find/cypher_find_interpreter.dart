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

  Set<int> extractNodeIdsFromCypherResponse(CypherResponse cypherResponse) {
    return extractColumnFromResponse(cypherResponse, 'nodeIds');
  }

  Set<dynamic> extractColumnFromResponse(CypherResponse cypherResponse, String column) {

    Set<dynamic> values = new Set();

    for (Map<String, dynamic> row in cypherResponse.rows) {
      if(row[column] == null) {
        throw 'Cypher response - row does not contain column <$column>';
      }

      if(row[column] is Iterable) {
        values.addAll(row[column]);
      } else {
        values.add(row[column]);
      }
    }

    return values;
  }

  Set<int> extractRelationshipIdsFromCypherResponse(CypherResponse cypherResponse) {
    return extractColumnFromResponse(cypherResponse, 'relationshipIds');
  }

  List<AroundNodeResponse> convertCypherResponse(CypherResponse cypherResponse) {


    return null;
  }
}
