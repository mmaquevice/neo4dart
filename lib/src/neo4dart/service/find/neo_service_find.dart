part of neo4dart;

class NeoServiceFind {

  final _logger = new Logger("NeoServiceFind");

  NeoClientGet neoClientGet = new NeoClientGet();

  BatchInsertExecutor tokenInsertExecutor = new BatchInsertExecutor();
  BatchFindExecutor tokenFindExecutor = new BatchFindExecutor();

  CypherFindInterpreter cypherFindInterpreter = new CypherFindInterpreter();
  CypherFindExecutor cypherFindExecutor = new CypherFindExecutor();

  findNodes(Type type, {Map properties}) async {

    if (properties == null || properties.length == 0) {
      return neoClientGet.findNodesByType(type);
    }

    return neoClientGet.findNodesByTypeAndProperties(type, properties);
  }

  findNodeById(int id, Type type) async {
    return tokenFindExecutor.findNodeById(id, type);
  }

  findNodesByIds(Iterable<int> ids, Type type) async {
    return tokenFindExecutor.findNodesByIds(ids, type);
  }

  findNodeWithRelationsById(int id, Type type, {int nbTransitiveRelations}) async {
    return cypherFindExecutor.findNodesAndRelationsByIds([id], type, nbTransitiveRelations: nbTransitiveRelations).then((response) => _convertCypherResponseToNode(response, id, type));
  }

  Node _convertCypherResponseToNode(var response, int nodeId, Type type) {

    CypherResponse cypherResponse = cypherFindInterpreter.convertResponse(response);
    List<AroundNodeResponse> aroundNodes = cypherFindInterpreter.convertCypherResponse(cypherResponse);

    Map aroundNodeById = new Map.fromIterable(aroundNodes, key : (k) => k.node.idNode, value: (v) => v);
    Node nodeWithRelations = new ResponseConverter().convertResponsesToNodeWithRelations(nodeId, aroundNodeById, typeNode: type);
    return nodeWithRelations;
  }

  findNodesWithRelationsByIds(Iterable<int> ids, Type type, {int nbTransitiveRelations}) async {
    return cypherFindExecutor.findNodesAndRelationsByIds(ids, type, nbTransitiveRelations: nbTransitiveRelations).then((response) => _convertCypherResponseToNodesByIds(response, ids, type));
  }

  List<Node> _convertCypherResponseToNodesByIds(var response, Iterable<int> ids, Type type) {

    List<Node> nodes = new List();

    CypherResponse cypherResponse = cypherFindInterpreter.convertResponse(response);
    List<AroundNodeResponse> aroundNodes = cypherFindInterpreter.convertCypherResponse(cypherResponse);

    Map aroundNodeById = new Map.fromIterable(aroundNodes, key : (k) => k.node.idNode, value: (v) => v);

    ResponseConverter responseConverter = new ResponseConverter();
    for (int id in ids) {
      nodes.add(responseConverter.convertResponsesToNodeWithRelations(id, aroundNodeById, typeNode: type));
    }
    return nodes;
  }

  findNodesWithRelations(Type type, {Map properties, int nbTransitiveRelations}) async {
    return cypherFindExecutor.findNodesAndRelations(type, properties: properties, nbTransitiveRelations: nbTransitiveRelations).then((response) => _convertCypherResponseToNodes(response, type, properties: properties));
  }

  List<Node> _convertCypherResponseToNodes(var response, Type type, {Map properties}) {

    List<Node> nodes = new List();

    CypherResponse cypherResponse = cypherFindInterpreter.convertResponse(response);
    List<AroundNodeResponse> aroundNodes = cypherFindInterpreter.convertCypherResponse(cypherResponse);

    Map aroundNodeById = new Map.fromIterable(aroundNodes, key : (k) => k.node.idNode, value: (v) => v);

    Set<int> ids = new Set();

    for (AroundNodeResponse aroundNode in aroundNodes) {
      if (aroundNode.label.labels.contains("$type")) {
        if (properties == null || properties.isEmpty) {
          ids.add(aroundNode.node.idNode);
        } else {
          if (_arePropertiesMatching(properties, aroundNode.node.data)) {
            ids.add(aroundNode.node.idNode);
          }
        }
      }
    }

    ResponseConverter responseConverter = new ResponseConverter();
    for (int id in ids) {
      nodes.add(responseConverter.convertResponsesToNodeWithRelations(id, aroundNodeById, typeNode: type));
    }
    return nodes;
  }

  bool _arePropertiesMatching(Map requestProperties, Map nodeProperties) {

    for (String key in requestProperties.keys) {
      if (nodeProperties.containsKey(key)) {
        if (nodeProperties[key] != requestProperties[key]) {
          return false;
        }
      } else {
        return false;
      }
    }

    return true;
  }
}
