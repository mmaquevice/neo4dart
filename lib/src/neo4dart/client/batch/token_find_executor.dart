part of neo4dart;

class TokenFindExecutor extends NeoClient {

  final _logger = new Logger("TokenFindExecutor");

  Map<int, Node> nodesWithRelationsById = {};

  Map<int, Node> nodesWithoutRelationsById = {};

  Map<int, Node> nodesInProgressById = {};

  TokenFindExecutor() {
    client = new http.Client();
  }

  TokenFindExecutor.withClient(client) : super.withClient(client);

  Future findNodeById(int id, Type type) {
    return executeBatch(new TokenFindBuilder().addNodeToBatch(id)).then((response) => _convertResponseToNode(response, type));
  }

  Future findNodesByIds(Iterable<int> ids, Type type) {
    return executeBatch(new TokenFindBuilder().addNodesToBatch(ids)).then((response) => _convertResponseToNodes(response, type));
  }

  Node _convertResponseToNode(var response, Type type) {

    Set<Node> nodes = _convertResponseToNodes(response, type);

    if (nodes.isEmpty) {
      return null;
    }

    if (nodes.length > 1) {
      throw "Response contains more than one node : $nodes.";
    }

    return nodes.first;
  }

  Set<Node> _convertResponseToNodes(var response, Type type) {

    Set<Node> nodes = new Set();

    List<AroundNodeResponse> aroundNodes = _convertResponse(response);

    aroundNodes.forEach((aroundNode) {

      LabelResponse labelResponse = aroundNode.label;
      List<String> labels = labelResponse.labels;

      if (labels.length == 0) {
        throw "Node <${aroundNode.node.idNode}> is not labelled.";
      }
      if (labels.length > 1) {
        throw "Node <${aroundNode.node.idNode}> has multiple labels, this is not currently supported.";
      }
      if (!type.toString().endsWith(labels.first)) {
        throw "Node <${aroundNode.node.idNode}> has a label <${labels.first}> not matching its type <${type.toString()}>.";
      }

      NodeResponse nodeResponse = aroundNode.node;
      Node node = convertToNode(type, nodeResponse);
      nodes.add(node);
    });

    return nodes;
  }

  Future findNodeAndRelationsById(int id, Type type) {

    return executeBatch(new Set.from([new TokenFindBuilder().addRelationsToBatch(id)])).then((response) {

      Set<int> nodeIds = _extractNodeIdsFromRelationResponse(response);

      Set<BatchToken> tokens = new Set();
      TokenFindBuilder builder = new TokenFindBuilder();
      tokens.addAll(builder.addNodeToBatch(id));
      tokens.add(builder.addRelationsToBatch(id));
      tokens.addAll(builder.addNodesToBatch(nodeIds));

      return executeBatch(tokens).then((response) {
        List<AroundNodeResponse> aroundNodes = _convertResponse(response);
        _logger.info(aroundNodes);

        Map aroundNodeById = new Map.fromIterable(aroundNodes, key : (k) => k.node.idNode, value: (v) => v);
        Node nodeWithRelations = _convertResponsesToNodeWithRelations(id, aroundNodeById, typeNode: type);
        return nodeWithRelations;
      });
    });
  }

  Node _convertResponsesToNodeWithRelations(int id, Map<int, AroundNodeResponse> aroundNodeById, {Type typeNode}) {

    if (nodesWithRelationsById.containsKey(id)) {
      return nodesWithRelationsById[id];
    }

    if (nodesInProgressById.containsKey(id)) {
      return nodesInProgressById[id];
    }

    if(!aroundNodeById.containsKey(id)) {
      return null;
    }

    AroundNodeResponse aroundNode = aroundNodeById[id];
    Node node = _retrieveNodeWithAroundNodeResponseData(id, aroundNode, typeNode: typeNode);
    nodesInProgressById[id] = node;

    aroundNode.relations.forEach((relationResponse) {
      if(aroundNodeById.containsKey(relationResponse.idStartNode) && aroundNodeById.containsKey(relationResponse.idEndNode)) {
        _bindResponseToNode(node, relationResponse, aroundNodeById[relationResponse.idStartNode], aroundNodeById[relationResponse.idEndNode]);

        if(id != relationResponse.idStartNode) {
          _convertResponsesToNodeWithRelations(relationResponse.idStartNode, aroundNodeById);
        }

        if(id != relationResponse.idEndNode) {
          _convertResponsesToNodeWithRelations(relationResponse.idEndNode, aroundNodeById);
        }
      }
    });

    nodesWithRelationsById[id] = node;
    return node;
  }

  Node _bindResponseToNode(Node node, RelationResponse relationResponse, AroundNodeResponse startNode, AroundNodeResponse endNode) {

    VariableMirror nodeFieldForRelation = _findRelationField(reflect(node).type.reflectedType, relationResponse.type);
    if (nodeFieldForRelation.type.isSubtypeOf(reflectType(Iterable))) {

      if (nodeFieldForRelation.type.isAssignableTo(reflectType(Set)) || nodeFieldForRelation.type.isAssignableTo(reflectType(List))) {
        // TODO mma : check if typeNeoEntity is really a neo entity
        Type typeNeoEntity = nodeFieldForRelation.type.typeArguments.map((t) => t.reflectedType).first;
        NeoEntity neoEntity = _convertToNeoEntity(node, reflectType(typeNeoEntity), relationResponse,  startNode,  endNode);
        _addNeoEntityToCollectionField(node, nodeFieldForRelation, neoEntity);
      }
    } else {
      NeoEntity neoEntity = _convertToNeoEntity(node, nodeFieldForRelation.type, relationResponse,  startNode,  endNode);
      reflect(node).setField(nodeFieldForRelation.simpleName, neoEntity);
    }

    return node;
  }

  NeoEntity _convertToNeoEntity(Node node, TypeMirror typeNeoEntity, RelationResponse relationResponse, AroundNodeResponse startNode, AroundNodeResponse endNode) {
    if (typeNeoEntity.isSubtypeOf(reflectType(Node))) {
      // TODO mma : check Direction
      if (node.id != relationResponse.idEndNode) {
        return _retrieveNodeWithAroundNodeResponseData(relationResponse.idEndNode, endNode, typeNode: typeNeoEntity.reflectedType);
      }
    }

    if (typeNeoEntity.isSubtypeOf(reflectType(Relation))) {
      return _createRelationWithNodes(typeNeoEntity.reflectedType, relationResponse, startNode, endNode);
    }

    return null;
  }

  _addNeoEntityToCollectionField(Node node, VariableMirror field, NeoEntity neoEntity) {
    var nodeFieldForRelationInstance = reflect(node).getField(field.simpleName).reflectee;
    if (nodeFieldForRelationInstance == null) {
      if (field.type.isAssignableTo(reflectType(Set))) {
        Set set = new Set.from([neoEntity]);
        reflect(node).setField(field.simpleName, set);
      }

      if (field.type.isAssignableTo(reflectType(List))) {
        reflect(node).setField(field.simpleName, [neoEntity]);
      }
    } else {
      nodeFieldForRelationInstance.add(neoEntity);
    }
  }


  Relation _createRelationWithNodes(Type typeRelation, RelationResponse relationResponse, AroundNodeResponse startAroundNodeResponse, AroundNodeResponse endAroundNodeResponse) {

    Relation relation = convertToRelation(typeRelation, relationResponse);

    Node startNode = _retrieveNodeWithAroundNodeResponseData(relationResponse.idStartNode, startAroundNodeResponse, typeNode : _findTypesAnnotatedBy(StartNode, relation).first);
    Node endNode = _retrieveNodeWithAroundNodeResponseData(relationResponse.idEndNode, endAroundNodeResponse, typeNode : _findTypesAnnotatedBy(EndNode, relation).first);

    InstanceMirror relationMirror = reflect(relation);
    relationMirror.setField(_findSymbolsAnnotatedBy(StartNode, relation).first, startNode);
    relationMirror.setField(_findSymbolsAnnotatedBy(EndNode, relation).first, endNode);

    return relation;
  }

  Node _retrieveNodeWithAroundNodeResponseData(int idNode, AroundNodeResponse aroundNode, {Type typeNode}) {

    if (nodesWithoutRelationsById.containsKey(idNode)) {
      return nodesWithoutRelationsById[idNode];
    }

    if(typeNode == null) {
      throw 'Node type is  null for node <$idNode>.';
    }

    Node node = _convertToNode(typeNode, aroundNode.node.data, aroundNode.node.idNode);
    nodesWithoutRelationsById[idNode] = node;
    return node;
  }

  Set<int> _extractNodeIdsFromRelationResponse(var response) {

    Set<int> nodeIds = new Set();
    List<AroundNodeResponse> aroundNodes = _convertResponse(response);

    aroundNodes.forEach((aroundNode) {
      aroundNode.relations.forEach((relation) {
        nodeIds.add(relation.idStartNode);
        nodeIds.add(relation.idEndNode);
      });
    });

    return nodeIds;
  }
}
