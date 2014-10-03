part of neo4dart;

class NeoService {

  final _logger = new Logger("NeoService");

  NeoClientGet neoClientGet = new NeoClientGet();
  NeoClientBatch neoClientBatch = new NeoClientBatch();

  Future insertNode(Node node) {

    BatchTokens batch = new BatchTokens();
    batch.addNodeToBatch(node);
    batch.addNodeAndRelationsToBatch(node);
    batch.addNodeAndRelationsViaToBatch(node);

    return neoClientBatch.executeBatch(batch.batchTokens);
  }

  Future findNodesByType(Type type) {
    return neoClientGet.executeGetByType(type);
  }

  Future findNodesByTypeAndProperties(Type type, Map properties) {
    return neoClientGet.executeGetByTypeAndProperties(type, properties);
  }

}



