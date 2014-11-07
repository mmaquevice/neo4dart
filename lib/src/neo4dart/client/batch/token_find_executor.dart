part of neo4dart;

class TokenFindExecutor extends NeoClient {

  final _logger = new Logger("TokenFindExecutor");

  Map<int, Node> nodesById = {
  };

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

        Node nodeWithRelations = _convertResponsesToNodeWithRelations(id, aroundNodes, type);
        return nodeWithRelations;
      });
    });
  }

  Node _convertResponsesToNodeWithRelations(int id, List<AroundNodeResponse> aroundNodes, Type type) {

    Map aroundNodeById = new Map.fromIterable(aroundNodes, key : (k) => k.node.idNode, value: (v) => v);
    AroundNodeResponse aroundNode = aroundNodeById[id];

    Node node = _convertToNode(type, aroundNode.node.data, aroundNode.node.idNode);
    nodesById[node.id] = node;
    InstanceMirror instanceNode = reflect(node);

    aroundNode.relations.forEach((relationResponse) {

      VariableMirror nodeFieldForRelation = _findRelationField(type, relationResponse.type);

      var nodeFieldForRelationInstance = instanceNode.getField(nodeFieldForRelation.simpleName).reflectee;
      if (nodeFieldForRelationInstance is Iterable) {

        if (nodeFieldForRelationInstance is Set || nodeFieldForRelationInstance is List) {

          Type typeRelation = nodeFieldForRelation.type.typeArguments.map((t) => t.reflectedType).first;
          Relation relation = _createRelationWithNodes(typeRelation, relationResponse, aroundNodeById[relationResponse.idStartNode], aroundNodeById[relationResponse.idEndNode]);

          nodeFieldForRelationInstance.add(relation);

        } else {
          throw 'Field $nodeFieldForRelation not handled.';
        }
      }
    });

    return node;
  }

  Relation _createRelationWithNodes(Type typeRelation, RelationResponse relationResponse, AroundNodeResponse startAroundNodeResponse, AroundNodeResponse endAroundNodeResponse) {

    Relation relation = convertToRelation(typeRelation, relationResponse);

    Node startNode = _retrieveNodeWithAroundNodeResponseData(relationResponse.idStartNode, _findTypesAnnotatedBy(StartNode, relation).first, startAroundNodeResponse);
    Node endNode = _retrieveNodeWithAroundNodeResponseData(relationResponse.idEndNode, _findTypesAnnotatedBy(EndNode, relation).first, endAroundNodeResponse);

    InstanceMirror relationMirror = reflect(relation);
    relationMirror.setField(_findSymbolsAnnotatedBy(StartNode, relation).first, startNode);
    relationMirror.setField(_findSymbolsAnnotatedBy(EndNode, relation).first, endNode);

    return relation;
  }

  Node _retrieveNodeWithAroundNodeResponseData(int idNode, Type typeNode, AroundNodeResponse aroundNode) {

    if (nodesById.containsKey(idNode)) {
      return nodesById[idNode];
    }

    Node node = _convertToNode(typeNode, aroundNode.node.data, aroundNode.node.idNode);
    nodesById[idNode] = node;
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

  Node _convertResponseToNodeWithRelations(var response, Type type) {

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

    return nodes.first;
  }
}
