part of neo4dart;

class NeoService {

  final _logger = new Logger("NeoService");

  NeoClient neoClient = new NeoClient();

  Future insertNode(Node node) {

    BatchTokens batch = new BatchTokens();
    batch.addNodeToBatch(node);
    batch.addNodeAndRelationsToBatch(node);

    return neoClient.executeBatch(batch.batchTokens);
  }

}



