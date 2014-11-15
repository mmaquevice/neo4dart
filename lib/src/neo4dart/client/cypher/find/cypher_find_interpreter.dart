part of neo4dart;

class CypherFindInterpreter {

  final _logger = new Logger("CypherFindInterpreter");

  CypherResponse convertResponse(var cypherResponse) {

    _logger.info("Response status : ${cypherResponse.statusCode}");

    if (cypherResponse.statusCode == 200) {
      _logger.info("Response body : ${cypherResponse.body}");

      Set<int> nodeIds = new Set();

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
          row.putIfAbsent(columns.asMap()[columnIndex], elementRow);
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

  Set<int> extractNodeIdsFromCypherResponse(var cypherResponse) {
    _logger.info("Response status : ${cypherResponse.statusCode}");

    if (cypherResponse.statusCode == 200) {
      _logger.info("Response body : ${cypherResponse.body}");

      Set<int> nodeIds = new Set();

      var jsonObject = new JsonDecoder().convert(cypherResponse.body);
      List results = jsonObject['results'];
      var result = results.first;
      List data = result['data'];

      for (var json in data) {
        List nodes = json['row'].first;
        nodeIds.addAll(nodes);
      }
      return nodeIds;
    } else {
      _logger.severe('Error requesting neo4j : status ${cypherResponse.statusCode} - ${cypherResponse.body}');
      throw "Error requesting neo4j : status ${cypherResponse.statusCode}";
    }
  }

  Set<int> extractRelationshipIdsFromCypherResponse(var cypherResponse) {

    _logger.info("Response status : ${cypherResponse.statusCode}");

    if (cypherResponse.statusCode == 200) {
      _logger.info("Response body : ${cypherResponse.body}");

      Set<int> relationshipIds = new Set();

      var jsonObject = new JsonDecoder().convert(cypherResponse.body);
      List results = jsonObject['results'];
      var result = results.first;
      List data = result['data'];

      for (var json in data) {
        List rows = json['row'];
        List nodes = rows.last;
        relationshipIds.addAll(nodes);
      }
      return relationshipIds;
    } else {
      _logger.severe('Error requesting neo4j : status ${cypherResponse.statusCode} - ${cypherResponse.body}');
      throw "Error requesting neo4j : status ${cypherResponse.statusCode}";
    }
  }

}
