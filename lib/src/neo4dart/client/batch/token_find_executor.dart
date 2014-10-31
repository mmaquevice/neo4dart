part of neo4dart;

class TokenFindExecutor extends NeoClient {

  final _logger = new Logger("TokenFindExecutor");

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
      });
    });
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
