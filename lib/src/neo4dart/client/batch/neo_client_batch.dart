part of neo4dart;

class NeoClientBatch extends NeoClient {

  final _logger = new Logger("NeoClientBatch");

  http.Client _client;

  NeoClientBatch() {
    _client = new http.Client();
  }

  NeoClientBatch.withClient(this._client);

  Future executeBatch(Set<BatchToken> batchTokens) {

    List data = _convertBatchTokensToJsonArray(batchTokens);
    _logger.info(data);

    return _client.post("http://localhost:7474/db/data/batch", body : '${data}').then((response) => _addIdToNeoEntities(response, batchTokens));
  }

  List _convertBatchTokensToJsonArray(Set<BatchToken> batchTokens) {
    return batchTokens.map((batchToken) {
      _logger.info(batchToken.body);
      return new JsonEncoder().convert(batchToken);
    }).toList();
  }

  _addIdToNeoEntities(var response, Set<BatchToken> batchTokens) {

    List<ResponseEntity> responseEntities = _convertResponseToEntities(response);
    Map<int, ResponseEntity> responsesById = new Map.fromIterable(responseEntities, key: (k) => k.id, value: (v) => v);

    batchTokens.forEach((token) {
      if(responsesById.containsKey(token.id)) {
        if(token.neoEntity != null) {
          _logger.info(token.neoEntity);
          token.neoEntity.id = responsesById[token.id].neoId;
          _logger.info('Matching ${token.id} to ${token.neoEntity.id}.');
        }
      }
    });

    return true;
  }
}
