part of neo4dart;

class NeoService {

  final _logger = new Logger("NeoService");

  NeoClientGet neoClientGet = new NeoClientGet();
  NeoClientBatch neoClientBatch = new NeoClientBatch();

  Future insertNode(Node node) {
    return _insertNode(node, false);
  }

  Future insertNodeInDepth(Node node) {
    return _insertNode(node, true);
  }

  Future _insertNode(Node node, bool inDepth) {

    BatchTokenHandler batchHandler = new BatchTokenHandler();
    batchHandler.addNodeToBatch(node);
    batchHandler.addNodeAndRelationsToBatch(node, inDepth);
    batchHandler.addNodeAndRelationsViaToBatch(node, inDepth);

    return neoClientBatch.executeBatch(batchHandler.batchTokens);
  }

  Future insertNodes(Iterable<Node> nodes) {
    return _insertNodes(nodes, false);
  }

  Future insertNodesInDepth(Iterable<Node> nodes) {
    return _insertNodes(nodes, true);
  }

  Future _insertNodes(Iterable<Node> nodes, bool inDepth) {

    BatchTokenHandler batchHandler = new BatchTokenHandler();
    batchHandler.addNodesToBatch(nodes);
    batchHandler.addNodesAndRelationsToBatch(nodes, inDepth);
    batchHandler.addNodesAndRelationsViaToBatch(nodes, inDepth);

    return neoClientBatch.executeBatch(batchHandler.batchTokens);
  }

  Future findNodesByType(Type type) {
    return neoClientGet.findNodesByType(type);
  }

  Future findNodesByTypeAndProperties(Type type, Map properties) {
    return neoClientGet.findNodesByTypeAndProperties(type, properties);
  }

}



