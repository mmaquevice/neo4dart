part of neo4dart;

class NeoService {

  final _logger = new Logger("NeoService");

  NeoClientGet neoClientGet = new NeoClientGet();
  NeoClientBatch neoClientBatch = new NeoClientBatch();

  Future insertNode(Node node) {

    BatchTokenHandler batchHandler = new BatchTokenHandler();
    batchHandler.addNodeToBatch(node);
    batchHandler.addNodeAndRelationsToBatch(node, true);
    batchHandler.addNodeAndRelationsViaToBatch(node, true);

    return neoClientBatch.executeBatch(batchHandler.batchTokens);
  }

  Future insertNodes(Iterable<Node> nodes) {

    return null;
  }

  Future insertAllConnectedNodes(Iterable<Node> nodes) {

    return null;
  }

  Future findNodesByType(Type type) {
    return neoClientGet.findNodesByType(type);
  }

  Future findNodesByTypeAndProperties(Type type, Map properties) {
    return neoClientGet.findNodesByTypeAndProperties(type, properties);
  }

}



