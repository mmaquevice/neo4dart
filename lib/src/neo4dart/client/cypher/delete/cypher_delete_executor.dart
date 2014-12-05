part of neo4dart;

class CypherDeleteExecutor extends CypherExecutor {

  final _logger = new Logger("CypherDeleteExecutor");

  CypherDeleteExecutor() {
    client = new http.Client();
  }

  CypherDeleteExecutor.withClient(client) : super.withClient(client);

  Future deleteNode(Node node, {bool force: false}) {

    String query = new CypherDeleteBuilder().buildQueryToDeleteNodes([node.id], force: force);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  Future deleteNodes(Iterable<Node> nodes, {bool force: false}) {

    String query = new CypherDeleteBuilder().buildQueryToDeleteNodes(nodes.map((node) => node.id).toList(), force: force);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  Future deleteNodeById(int id, {bool force: false}) {

    String query = new CypherDeleteBuilder().buildQueryToDeleteNodes([id], force: force);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  Future deleteNodesByIds(Iterable<int> ids, {bool force: false}) {

    String query = new CypherDeleteBuilder().buildQueryToDeleteNodes(ids, force: force);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  Future deleteRelation(Relation relation) {

    String query = new CypherDeleteBuilder().buildQueryToDeleteRelations([relation.id]);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  Future deleteRelations(Iterable<Relation> relations) {

    String query = new CypherDeleteBuilder().buildQueryToDeleteRelations(relations.map((r) => r.id).toList());
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  Future deleteRelationById(int id) {

    String query = new CypherDeleteBuilder().buildQueryToDeleteRelations([id]);
    return executeCypher(query).then((response) => _checkResponse(response));
  }

  Future deleteRelationsByIds(Iterable<int> ids) {

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
