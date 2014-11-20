part of neo4dart;

class BatchFindExecutor extends BatchExecutor {

  final _logger = new Logger("TokenFindExecutor");

  Map<int, Node> nodesWithRelationsById = {};

  Map<int, Node> nodesWithoutRelationsById = {};

  Map<int, Node> nodesInProgressById = {};

  BatchInterpreter _interpreter = new BatchInterpreter();

  BatchFindExecutor() {
    client = new http.Client();
  }

  BatchFindExecutor.withClient(client) : super.withClient(client);

  Future findNodeById(int id, Type type) {
    return executeBatch(new BatchFindBuilder().addNodeToBatch(id)).then((response) => _convertResponseToNode(response, type));
  }

  Future findNodesByIds(Iterable<int> ids, Type type) {
    return executeBatch(new BatchFindBuilder().addNodesToBatch(ids)).then((response) => _convertResponseToNodes(response, type));
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

    List<AroundNodeResponse> aroundNodes = _interpreter.convertResponse(response);

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

    return executeBatch(new BatchFindBuilder().addRelationsToBatchFromNodes([id])).then((response) {

      Set<int> nodeIds = _extractNodeIdsFromRelationResponse(response);

      Set<BatchToken> tokens = new Set();
      BatchFindBuilder builder = new BatchFindBuilder();
      tokens.addAll(builder.addNodeToBatch(id));
      tokens.addAll(builder.addRelationsToBatchFromNodes([id]));
      tokens.addAll(builder.addNodesToBatch(nodeIds));

      return executeBatch(tokens).then((response) {
        List<AroundNodeResponse> aroundNodes = _interpreter.convertResponse(response);
        _logger.info(aroundNodes);

        Map aroundNodeById = new Map.fromIterable(aroundNodes, key : (k) => k.node.idNode, value: (v) => v);
        Node nodeWithRelations = new ResponseConverter().convertResponsesToNodeWithRelations(id, aroundNodeById, typeNode: type);
        return nodeWithRelations;
      });
    });
  }

  Future findAllNodesAndRelations(int originNodeId, Type originType, Iterable<int> nodeIds, Iterable<int> relationshipIds) {

      Set<BatchToken> tokens = new Set();
      BatchFindBuilder builder = new BatchFindBuilder();
      tokens.addAll(builder.addNodeToBatch(originNodeId));
      tokens.addAll(builder.addRelationsToBatch(relationshipIds));
      tokens.addAll(builder.addNodesToBatch(nodeIds));

      return executeBatch(tokens).then((response) {
        List<AroundNodeResponse> aroundNodes = _interpreter.convertResponse(response);
        _logger.info(aroundNodes);

        Map aroundNodeById = new Map.fromIterable(aroundNodes, key : (k) => k.node.idNode, value: (v) => v);
        Node nodeWithRelations = new ResponseConverter().convertResponsesToNodeWithRelations(originNodeId, aroundNodeById, typeNode: originType);
        return nodeWithRelations;
      });
  }

  Set<int> _extractNodeIdsFromRelationResponse(var response) {

    Set<int> nodeIds = new Set();
    List<AroundNodeResponse> aroundNodes = _interpreter.convertResponse(response);

    aroundNodes.forEach((aroundNode) {
      aroundNode.relations.forEach((relation) {
        nodeIds.add(relation.idStartNode);
        nodeIds.add(relation.idEndNode);
      });
    });

    return nodeIds;
  }
}
