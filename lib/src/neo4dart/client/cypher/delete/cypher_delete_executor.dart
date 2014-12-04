part of neo4dart;

class CypherDeleteExecutor extends CypherExecutor {

  final _logger = new Logger("CypherDeleteExecutor");

  CypherDeleteExecutor() {
    client = new http.Client();
  }

  CypherDeleteExecutor.withClient(client) : super.withClient(client);

  Future deleteNode(Node node, Type type, {bool force: false}) {

    String query = new CypherDeleteBuilder().buildQueryToDeleteNodes([node.id], type, force: force);
    return executeCypher(query).then((response) {
      _checkResponse(response);
    });
  }

  Future deleteNodes(Iterable<Node> nodes) {
    return null;
  }

  Future deleteRelation(Relation relation) {
    return null;
  }

  Future deleteRelations(Iterable<Relation> relations) {
    return null;
  }

  _checkResponse(response) {
    _logger.info("Response status : ${response.statusCode}");

    if (response.statusCode != 200) {
      _logger.severe('Error deleting node : neo4j status ${response.statusCode} - ${response.body}');
      throw "Error deleting node : neo4j status ${response.statusCode}";
    }

    var body = new JsonDecoder().convert(response.body);
    if (body['errors'].isNotEmpty) {
      throw "Error deleting node : neo4j status ${response.statusCode} - ${body['errors'].join(', ')}";
    }

    return response;
  }


}
