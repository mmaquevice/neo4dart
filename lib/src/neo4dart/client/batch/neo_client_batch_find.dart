part of neo4dart;

// TODO mma - to refacto by tokenExecuter
class NeoClientBatchFind extends NeoClient {

  final _logger = new Logger("NeoClientBatch");

  http.Client _client;

  NeoClientBatchFind() {
    _client = new http.Client();
  }

  NeoClientBatchFind.withClient(this._client);

  Future executeBatch(Set<BatchToken> batchTokens) {

    List data = _convertBatchTokensToJsonArray(batchTokens);
    _logger.info(data);

    return _client.post("http://localhost:7474/db/data/batch", body : '${data}');
  }

  List _convertBatchTokensToJsonArray(Set<BatchToken> batchTokens) {
    return batchTokens.map((batchToken) {
      _logger.info(batchToken.body);
      return new JsonEncoder().convert(batchToken);
    }).toList();
  }

  // TODO mma - wip
  Future findNodeById(int id) {

    BatchFindTokenHandler batchHandler = new BatchFindTokenHandler();
    batchHandler.addNodeToBatch(id);

    return null;
  }
}
