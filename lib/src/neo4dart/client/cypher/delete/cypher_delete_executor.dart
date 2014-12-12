part of neo4dart;

class CypherDeleteExecutor extends CypherExecutor {

  final _logger = new Logger("CypherDeleteExecutor");

  CypherDeleteExecutor() {
    client = new http.Client();
  }

  CypherDeleteExecutor.withClient(client) : super.withClient(client);

  deleteNode(var node, {bool force: false}) async {

    String query = new CypherDeleteBuilder().buildQueryToDeleteNodes([node.id], force: force);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  deleteNodes(Iterable nodes, {bool force: false}) async {

    String query = new CypherDeleteBuilder().buildQueryToDeleteNodes(nodes.map((node) => node.id).toList(), force: force);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  deleteNodeById(int id, {bool force: false}) async {

    String query = new CypherDeleteBuilder().buildQueryToDeleteNodes([id], force: force);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  deleteNodesByIds(Iterable<int> ids, {bool force: false}) async {

    String query = new CypherDeleteBuilder().buildQueryToDeleteNodes(ids, force: force);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  deleteRelation(var relation) async {

    String query = new CypherDeleteBuilder().buildQueryToDeleteRelations([relation.id]);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  deleteRelations(Iterable relations) async {

    String query = new CypherDeleteBuilder().buildQueryToDeleteRelations(relations.map((r) => r.id).toList());
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  deleteRelationById(int id) async {

    String query = new CypherDeleteBuilder().buildQueryToDeleteRelations([id]);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  deleteRelationsByIds(Iterable<int> ids) async {

    String query = new CypherDeleteBuilder().buildQueryToDeleteRelations(ids);
    return executeCypher(query).then((response) => _checkResponse(response));
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
