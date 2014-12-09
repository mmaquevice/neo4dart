part of neo4dart;

class BatchExecutor {

  final _logger = new Logger("BatchExecutor");

  http.Client client;

  BatchExecutor() {
    client = new http.Client();
  }

  BatchExecutor.withClient(this.client);

  executeBatch(Set<BatchToken> batchTokens) async {

    List data = _convertBatchTokensToJsonArray(batchTokens);
    _logger.info(data);

    return client.post("http://localhost:7474/db/data/batch", body : '${data}');
  }

  List _convertBatchTokensToJsonArray(Set<BatchToken> batchTokens) {
    return batchTokens.map((batchToken) {
      _logger.info(batchToken.body);
      return new JsonEncoder().convert(batchToken);
    }).toList();
  }
}
