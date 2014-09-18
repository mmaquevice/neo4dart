part of neo4dart;


class NeoService {

  final _logger = new Logger("NeoService");

  NeoClient neoClient = new NeoClient();

  Future insertNode(Node node) {
    BatchToken batchToken = convertNodeToBatchToken(node);

    Set batchTokens = new Set();
    batchTokens.add(batchToken);
    return neoClient.executeBatch(batchTokens);
  }

  BatchToken convertNodeToBatchToken(Node node) {
    return new BatchToken("POST", "/node",  node.toJson());
  }

}
