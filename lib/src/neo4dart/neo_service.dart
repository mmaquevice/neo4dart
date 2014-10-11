part of neo4dart;

class NeoService {

  final _logger = new Logger("NeoService");

  NeoClientGet neoClientGet = new NeoClientGet();
  NeoClientBatch neoClientBatch = new NeoClientBatch();

  Future insertNode(Node node) {

    BatchTokenHandler batchHandler = new BatchTokenHandler();
    batchHandler.addNodeToBatch(node);
    batchHandler.addNodeAndRelationsToBatch(node);
    batchHandler.addNodeAndRelationsViaToBatch(node);

    return neoClientBatch.executeBatch(batchHandler.batchTokens);
  }

  Future findNodesByType(Type type) {
    return neoClientGet.findNodesByType(type);
  }

  Future findNodesByTypeAndProperties(Type type, Map properties) {
    return neoClientGet.findNodesByTypeAndProperties(type, properties);
  }

}



