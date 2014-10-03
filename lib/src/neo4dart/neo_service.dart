part of neo4dart;

class NeoService {

  final _logger = new Logger("NeoService");

  NeoClient neoClient = new NeoClient();

  Future insertNode(Node node) {

    BatchTokens batch = new BatchTokens();
    batch.addNodeToBatch(node);
    batch.addNodeAndRelationsToBatch(node);
    batch.addNodeAndRelationsViaToBatch(node);

    return neoClient.executeBatch(batch.batchTokens);
  }

  Future findNodesByType(Type type) {
    return neoClient.executeGetByLabel(type);
  }

  Future findNodesByTypeAndProperties(Type type, Map properties) {
    return neoClient.executeGetByLabelAndProperties(type, properties);
  }

}



