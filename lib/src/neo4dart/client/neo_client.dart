part of neo4dart;

class NeoClient {

  final _logger = new Logger("NeoClient");

  http.Client _client;

  NeoClient() {
    _client = new http.Client();
  }

  NeoClient.withClient(this._client);

  Future executeBatch(Set<BatchToken> batchTokens) {

    List data = _convertBatchTokensToJsonArray(batchTokens);
    _logger.info(data);

    return _client.post("http://localhost:7474/db/data/batch", body : '${data}').then((response) {
      _logger.info("Response status : ${response.statusCode}");
      _logger.info("Response body : ${response.body}");

      if (response.statusCode == 200) {
        return new Future.value(true);
      } else {
        return new Future.value(false);
      }

    }).catchError((error, stackTrace) {
      _logger.info(error);
      _logger.info(stackTrace);
    });
  }

  List _convertBatchTokensToJsonArray(Set<BatchToken> batchTokens) {
    return batchTokens.map((batchToken) {
      _logger.info(batchToken.body);
      return new JsonEncoder().convert(batchToken);
    }).toList();
  }

  Future executeGetByLabel(String label) {

    String url = "http://localhost:7474/db/data/label/${label}/nodes";

    _logger.info("Url : ${url}");

    return _client.get(url).then((response) {
      _logger.info("Response status : ${response.statusCode}");
      _logger.info("Response body : ${response.body}");

      if (response.statusCode == 200) {
        return new Future.value(true);
      } else {
        return new Future.value(false);
      }

    }).catchError((error, stackTrace) {
      _logger.info(error);
      _logger.info(stackTrace);
    });
  }

  Future executeGetByLabelAndProperties(String label, Map properties) {

    String propertyKey = properties.keys.first;
    String propertyValue = "\"${properties[propertyKey]}\"";

    String url = "http://localhost:7474/db/data/label/${label}/nodes?${propertyKey}=${propertyValue}";

    _logger.info("Url : ${url}");

    return _client.get(url).then((response) {
      _logger.info("Response status : ${response.statusCode}");
      _logger.info("Response body : ${response.body}");

      if (response.statusCode == 200) {
        return new Future.value(true);
      } else {
        return new Future.value(false);
      }

    }).catchError((error, stackTrace) {
      _logger.info(error);
      _logger.info(stackTrace);
    });
  }
}
