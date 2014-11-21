part of neo4dart;

class NeoServiceFind {

  final _logger = new Logger("NeoServiceFind");

  NeoClientGet neoClientGet = new NeoClientGet();

  BatchInsertExecutor tokenInsertExecutor = new BatchInsertExecutor();
  BatchFindExecutor tokenFindExecutor = new BatchFindExecutor();

  CypherFindInterpreter cypherFindInterpreter = new CypherFindInterpreter();
  CypherFindExecutor cypherFindExecutor = new CypherFindExecutor();

  Future findNodes(Type type, {Map properties}) {

    if(properties == null || properties.length == 0) {
      return neoClientGet.findNodesByType(type);
    }

    return neoClientGet.findNodesByTypeAndProperties(type, properties);
  }

  Future findNodeById(int id, Type type) {
    return tokenFindExecutor.findNodeById(id, type);
  }

  Future findNodesByIds(Iterable<int> ids, Type type) {
    return tokenFindExecutor.findNodesByIds(ids, type);
  }

  Future findNodeWithNRelationsById(int id, Type type, int nbRelations) {
    return cypherFindExecutor.findNodesAndRelations([id], type, nbRelations).then((response) => _convertCypherResponseToNode(response, id, type));
  }

  Future findNodeWithRelationsById(int id, Type type) {
    return cypherFindExecutor.findNodesAndRelations([id], type, 1).then((response) => _convertCypherResponseToNode(response, id, type));
  }

  Future findNodeWithAllRelationsById(int id, Type type) {
    return cypherFindExecutor.findAllNodesAndRelations([id], type).then((response) => _convertCypherResponseToNode(response, id, type));
  }

  Node _convertCypherResponseToNode(var response, int nodeId, Type type) {

    CypherResponse cypherResponse = cypherFindInterpreter.convertResponse(response);
    List<AroundNodeResponse> aroundNodes = cypherFindInterpreter.convertCypherResponse(cypherResponse);

    Map aroundNodeById = new Map.fromIterable(aroundNodes, key : (k) => k.node.idNode, value: (v) => v);
    Node nodeWithRelations = new ResponseConverter().convertResponsesToNodeWithRelations(nodeId, aroundNodeById, typeNode: type);
    return nodeWithRelations;
  }

  Future findNodesWithNRelationsByIds(Iterable<int> ids, Type type, int nbRelations) {
    return cypherFindExecutor.findNodesAndRelations(ids, type, nbRelations).then((response) => _convertCypherResponseToNodes(response, ids, type));
  }

  Future findNodesWithRelationsByIds(Iterable<int> ids, Type type) {
    return cypherFindExecutor.findNodesAndRelations(ids, type, 1).then((response) => _convertCypherResponseToNodes(response, ids, type));
  }

  Future findNodesWithAllRelationsByIds(Iterable<int> ids, Type type) {
    return cypherFindExecutor.findAllNodesAndRelations(ids, type).then((response) => _convertCypherResponseToNodes(response, ids, type));
  }

  List<Node> _convertCypherResponseToNodes(var response, Iterable<int> ids, Type type) {

    List<Node> nodes = new List();

    CypherResponse cypherResponse = cypherFindInterpreter.convertResponse(response);
    List<AroundNodeResponse> aroundNodes = cypherFindInterpreter.convertCypherResponse(cypherResponse);

    Map aroundNodeById = new Map.fromIterable(aroundNodes, key : (k) => k.node.idNode, value: (v) => v);

    ResponseConverter responseConverter = new ResponseConverter();
    for(int id in ids) {
      nodes.add(responseConverter.convertResponsesToNodeWithRelations(id, aroundNodeById, typeNode: type));
    }
    return nodes;
  }
}
